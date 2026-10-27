#!/usr/bin/env bash
# Encrypt a Proton WireGuard config into secrets/secrets.yaml.
# Download it from Proton: Account → Downloads → WireGuard.
# Pick a P2P server and enable NAT-PMP. Do not commit the raw file.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
conf="${1:-}"
sops_file="${root}/secrets/secrets.yaml"
key="proton_wireguard_conf"

if [[ -z "${conf}" || ! -f "${conf}" ]]; then
  echo "Usage: $0 /path/to/proton.conf" >&2
  exit 1
fi

if ! grep -q '^\[Interface\]' "${conf}" || ! grep -q '^\[Peer\]' "${conf}"; then
  echo "Refusing: ${conf} does not look like a WireGuard config." >&2
  exit 1
fi
if ! grep -qi '^DNS[[:space:]]*=' "${conf}"; then
  echo "Refusing: Proton config is missing DNS=. Re-download it with DNS included." >&2
  exit 1
fi
if ! grep -qi '^Endpoint[[:space:]]*=' "${conf}"; then
  echo "Refusing: config is missing Endpoint=." >&2
  exit 1
fi

if ! command -v sops >/dev/null || ! command -v jq >/dev/null; then
  echo "Need sops and jq on PATH. They are system packages after a switch; until then: nix shell nixpkgs#sops nixpkgs#jq" >&2
  exit 1
fi

json_value="$(jq -Rs . < "${conf}")"
sops set "${sops_file}" "[\"${key}\"]" "${json_value}"
echo "Stored ${key} in secrets/secrets.yaml."
echo "Next, on littleboy: sudo nixos-rebuild switch --flake .#littleboy"
