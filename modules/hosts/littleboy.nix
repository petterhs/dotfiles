# littleboy specific configuration
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Hostname
  networking.hostName = "littleboy";

  # Bound journal scans and disk use on the shared system/data SSD.
  services.journald.settings.Journal = {
    SystemMaxUse = "512M";
    SystemMaxFileSize = "64M";
    MaxRetentionSec = "14day";
  };

  services.postgresql = {
    # Run scripts/migrate-littleboy-postgresql.sh BEFORE switching to this version.
    package = pkgs.postgresql_18;
  };

  # The upstream module otherwise initializes an empty cluster automatically.
  systemd.services.postgresql.preStart = lib.mkBefore ''
    if [ -f /var/lib/postgresql/14/PG_VERSION ] &&
       [ ! -f ${config.services.postgresql.dataDir}/.migrated-from-14 ]; then
      echo "PostgreSQL 14 migration is required; run scripts/migrate-littleboy-postgresql.sh before switching." >&2
      exit 1
    fi
  '';

  homelab.labDomain = "lab.hoem.tech";

  homelab.audiobookshelfPublic = {
    enable = true;
    domain = "audio.hoem.app";
    tunnelId = "51b6452b-e758-456f-9b8c-e28b40d4636c";
  };

  # Queue for video recipe imports. Add the encrypted
  # family_recipe_importer_env value before switching littleboy.
  sops.secrets."family-recipe-importer.env" = {
    key = "family_recipe_importer_env";
    path = "/run/secrets/family-recipe-importer.env";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.familyRecipeImporter = {
    enable = true;
    host = "0.0.0.0";
    port = 8088;
    environmentFile = "/run/secrets/family-recipe-importer.env";
    openFirewall = true;
  };

  # Boot configuration
  boot.supportedFilesystems = [ "ntfs" ];

  # User configuration
  users.users.petter = {
    isNormalUser = true;
    description = "petter";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "docker"
      "wireshark"
      "adbusers"
    ];
    packages = with pkgs; [
      # Server packages only
    ];
  };

  # No desktop environment - headless server

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root petter
  '';

  # Additional firewall ports for homelab services
  networking.firewall.allowedTCPPorts = [
    2283 # Immich
    8095 # Music Assistant
    1400 # Sonos (for Music Assistant)
    5432 # PostgreSQL (local only)
    6379 # Redis (local only)
  ];
}
