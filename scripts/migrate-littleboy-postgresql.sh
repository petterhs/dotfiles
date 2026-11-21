#!/usr/bin/env bash
# Run on littleboy, BEFORE nixos-rebuild switch, from the updated checkout:
#   sudo nixos-rebuild build --flake .#littleboy
#   sudo bash scripts/migrate-littleboy-postgresql.sh
#   sudo nixos-rebuild switch --flake .#littleboy
#   sudo xargs -r -a /var/lib/postgresql/18/.migration-stopped-units systemctl start
#
# A standalone copy accepts the checkout path as its optional argument:
#   sudo bash ~/migrate-littleboy-postgresql.sh ~/dotfiles
#
# Backs up all databases, restores all except Immich into PostgreSQL 18, and leaves
# PostgreSQL 14 unchanged. No switch, deletion, or rollback is performed here.
# On failure, applications remain stopped; the script prints the backup path.
# Keep the old cluster and backups until the new deployment has been verified.
set -euo pipefail
umask 077

die() { echo "Error: $*" >&2; exit 1; }
[[ $EUID -eq 0 ]] || die "Run with sudo."
[[ $(hostname) == littleboy ]] || die "This migration is specific to littleboy."
[[ $# -le 1 ]] || die "Usage: $0 [dotfiles-checkout]"
repo=$(cd "${1:-$(dirname "${BASH_SOURCE[0]}")/..}" && pwd)
[[ -f $repo/flake.nix ]] || die "No flake.nix in $repo. Supply the dotfiles checkout path."
old_data=/var/lib/postgresql/14
new_data=/var/lib/postgresql/18
[[ -f $old_data/PG_VERSION && $(cat "$old_data/PG_VERSION") == 14 ]] || die "Expected PostgreSQL 14 data."
[[ ! -e $new_data ]] || die "$new_data already exists; inspect it before retrying."
systemctl is-active --quiet postgresql || die "The old PostgreSQL service must be running."
pid=$(systemctl show postgresql --property=MainPID --value)
old_bin=$(dirname "$(readlink -f "/proc/$pid/exe")")
[[ $("$old_bin/postgres" --version) == *' 14.'* ]] || die "Expected the running PostgreSQL 14 binary."

echo "Building PostgreSQL 18 before stopping applications..."
new_package=$(nix build --no-link --print-out-paths --no-update-lock-file \
  "$repo#nixosConfigurations.littleboy.config.services.postgresql.finalPackage")
new_bin=$new_package/bin
[[ $("$new_bin/postgres" --version) == *' 18.'* ]] || die "The checkout must select PostgreSQL 18."
old_psql() { runuser -u postgres -- "$old_bin/psql" -X -v ON_ERROR_STOP=1 -h /run/postgresql "$@"; }
[[ $(old_psql -At -d postgres -c 'SHOW data_directory') == "$old_data" ]] || die "Unexpected source data directory."
[[ $(old_psql -At -d postgres -c "SELECT count(*) FROM pg_tablespace WHERE spcname NOT IN ('pg_default','pg_global')") == 0 ]] || die "Custom tablespaces need a tailored migration."
[[ $(old_psql -At -d postgres -c "SELECT count(*) FROM pg_database WHERE NOT datallowconn AND NOT datistemplate") == 0 ]] || die "A database disallows connections."
database_list=$(old_psql -At -d postgres -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'immich' ORDER BY datname")
mapfile -t databases <<< "$database_list"
[[ ${#databases[@]} -gt 0 ]] || die "No databases found."
for database in "${databases[@]}"; do
  [[ $database =~ ^[a-zA-Z0-9_]+$ ]] || die "Database name needs manual handling: $database"
done

# Allow room for a second cluster, logical backups, and index creation.
cluster_kb=$(du -sk "$old_data" | cut -f1)
available_kb=$(df --output=avail -k /var/lib/postgresql | tail -n1)
(( available_kb > cluster_kb * 3 + 2097152 )) || die "Insufficient free space for a copied cluster and backups."
backup=/var/lib/postgresql/migration-14-to-18-$(date -u +%Y%m%dT%H%M%SZ)
install -d -m 0700 -o postgres -g postgres "$backup"
new_running=false
finish() {
  status=$?
  trap - EXIT
  if $new_running; then
    runuser -u postgres -- "$new_bin/pg_ctl" -D "$new_data" -m fast -w stop || status=1
  fi
  echo "Backups and migration logs: $backup"
  if (( status != 0 )); then
    echo "Migration failed. No switch was performed. PostgreSQL 14 data remains unchanged." >&2
    echo "Inspect the error before restarting PostgreSQL 14 and the units listed in $backup/stopped-units.txt." >&2
  fi
  exit "$status"
}
trap finish EXIT

echo "Stopping database clients; downtime begins now."
units=(home-assistant.service phpfpm-nextcloud.service nextcloud-cron.timer
  nextcloud-cron.service nextcloud-setup.service nextcloud-notify_push.service
  immich-server.service immich-machine-learning.service)
: > "$backup/stopped-units.txt"
for unit in "${units[@]}"; do
  if systemctl is-active --quiet "$unit"; then
    echo "$unit" >> "$backup/stopped-units.txt"
    systemctl stop "$unit"
  fi
done

[[ $(old_psql -At -d postgres -c "SELECT count(*) FROM pg_stat_activity WHERE backend_type='client backend' AND pid <> pg_backend_pid()") == 0 ]] || die "Other database clients remain connected; stop them before migration."

# Preserve a complete, unfiltered backup, including the legacy vectors extension.
runuser -u postgres -- "$old_bin/pg_dumpall" -h /run/postgresql \
  --file="$backup/full-postgresql-14.sql"
runuser -u postgres -- "$new_bin/pg_dumpall" -h /run/postgresql \
  --globals-only --file="$backup/globals.sql"
# initdb creates postgres already; retain its ALTER ROLE statements and passwords.
sed '/^CREATE ROLE postgres;$/d' "$backup/globals.sql" > "$backup/globals-restore.sql"
chown postgres:postgres "$backup/globals-restore.sql"

for database in "${databases[@]}" template1; do
  runuser -u postgres -- "$new_bin/pg_dump" -h /run/postgresql --format=custom \
    --file="$backup/$database.dump" --dbname="$database"
done

collate=$(old_psql -At -d postgres -c 'SHOW lc_collate')
ctype=$(old_psql -At -d postgres -c 'SHOW lc_ctype')
encoding=$(old_psql -At -d postgres -c 'SHOW server_encoding')
systemctl stop postgresql
install -d -m 0700 -o postgres -g postgres "$new_data" "$backup/socket"
runuser -u postgres -- "$new_bin/initdb" -D "$new_data" -U postgres \
  --encoding="$encoding" --lc-collate="$collate" --lc-ctype="$ctype" --auth-local=peer --auth-host=scram-sha-256
# The temporary restore server accepts only local Unix socket connections.
new_running=true
runuser -u postgres -- "$new_bin/pg_ctl" -D "$new_data" -l "$backup/restore-server.log" \
  -o "-c listen_addresses='' -c unix_socket_directories='$backup/socket' -p 55432" -w start
runuser -u postgres -- "$new_bin/psql" -X -v ON_ERROR_STOP=1 -h "$backup/socket" \
  -p 55432 -d postgres -f "$backup/globals-restore.sql"
for database in "${databases[@]}"; do
  runuser -u postgres -- "$new_bin/pg_restore" --exit-on-error --clean --if-exists \
    --create -h "$backup/socket" -p 55432 --dbname=template1 "$backup/$database.dump"
done
runuser -u postgres -- "$new_bin/pg_restore" --exit-on-error --clean --if-exists \
  -h "$backup/socket" -p 55432 --dbname=template1 "$backup/template1.dump"
runuser -u postgres -- "$new_bin/vacuumdb" -h "$backup/socket" -p 55432 --all --analyze-in-stages
runuser -u postgres -- "$new_bin/pg_ctl" -D "$new_data" -m fast -w stop
new_running=false
cp "$backup/stopped-units.txt" "$new_data/.migration-stopped-units"
touch "$new_data/.migrated-from-14"
chown postgres:postgres "$new_data/.migrated-from-14"
echo "Migration completed. PostgreSQL and its applications remain stopped."
echo "Next: sudo nixos-rebuild switch --flake $repo#littleboy"
echo "Then: sudo xargs -r -a $new_data/.migration-stopped-units systemctl start"
