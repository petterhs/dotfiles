# travis — Raspberry Pi 4 + Hermes

Headless NixOS host for [Hermes Agent](https://hermes-agent.nousresearch.com/) with `signal-cli`, talking to Mealie on littleboy over Tailscale.

Yes: flash a generic NixOS aarch64 SD image first, boot, then switch to this flake (`.#travis`). That is the normal Raspberry Pi workflow. Fan/case need no special Nix settings.

## 1. Flash the SD card

1. Download the current **NixOS aarch64 SD image** (see [NixOS on ARM / Raspberry Pi](https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi)).
2. Decompress if needed (`.img.zst` → `zstd -d …`).
3. Write to the card (**double-check the device** — this wipes the target):

```bash
# Example — replace /dev/sdX with your SD device (not a partition like sdX1)
sudo dd if=nixos-sd-image-*-aarch64-linux.img of=/dev/sdX bs=64K status=progress conv=fsync
```

4. Insert the card, connect **ethernet** + power, boot the Pi 4.

## 2. First boot / SSH

On the stock SD image, set a password or inject your SSH public key so you can log in (image-dependent). Prefer ethernet for bring-up.

From another machine (shared key is already in this repo as `secrets/id_ed25519.pub` for later travis configs):

```bash
ssh root@<travis-ip>   # or nixos@… depending on the image
```

Clone this flake on the Pi (or rebuild remotely later):

```bash
git clone <your-dotfiles-url> ~/dotfiles
cd ~/dotfiles
```

## 3. Onboard sops (host age key)

Travis decrypts secrets with its **SSH host key** (same pattern as littleboy/fatman). After first boot on the stock image (or after the first switch that creates host keys):

**On travis:**

```bash
sudo cat /etc/ssh/ssh_host_ed25519_key.pub
```

**On a machine that can edit this repo:**

```bash
nix run nixpkgs#ssh-to-age -- < /path/to/travis_ssh_host_ed25519_key.pub
# → age1xxxxxxxx…
```

1. Add the age pubkey to [`.sops.yaml`](../.sops.yaml) as `&travis` under `keys:`.
2. Uncomment / add `*travis` under the `secrets/travis.yaml` creation rule (and optionally `secrets/secrets.yaml` if travis should read shared secrets later).
3. Re-encrypt travis secrets so travis can decrypt them.

   Sops in this repo uses each machine’s **SSH host key** as the age identity (`age.sshKeyPaths`), not `~/.ssh/id_ed25519` (that is only for SSH login).

   On no-kon / littleboy / fatman, **do not** rely on `SOPS_AGE_SSH_PRIVATE_KEY_FILE` alone under sudo — it often fails. Convert the host private key to a native age identity (`SOPS_AGE_KEY`), and clear leftover `SOPS_AGE_*` env vars (empty values or a stray `SOPS_AGE_RECIPIENTS` can break decryption):

```bash
cd ~/dotfiles
sudo bash -lc '
  unset SOPS_AGE_KEY_FILE SOPS_AGE_RECIPIENTS SOPS_AGE_SSH_PRIVATE_KEY_FILE
  export SOPS_AGE_KEY="$(nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key)"
  cd /home/s27731/dotfiles
  sudo -u s27731 -E env SOPS_AGE_KEY="$SOPS_AGE_KEY" \
    nix run nixpkgs#sops -- updatekeys secrets/travis.yaml
'
```

   Diagnostic (same as the audiobookshelf script): `sudo ./scripts/setup-audiobookshelf-public.sh --check-sops`

4. Fill real values (API key + Signal numbers):

```bash
sudo bash -lc '
  unset SOPS_AGE_KEY_FILE SOPS_AGE_RECIPIENTS SOPS_AGE_SSH_PRIVATE_KEY_FILE
  export SOPS_AGE_KEY="$(nix run nixpkgs#ssh-to-age -- -private-key -i /etc/ssh/ssh_host_ed25519_key)"
  cd /home/s27731/dotfiles
  sudo -u s27731 -E env \
    SOPS_AGE_KEY="$SOPS_AGE_KEY" \
    EDITOR=/etc/profiles/per-user/s27731/bin/nvim \
    nix run nixpkgs#sops -- secrets/travis.yaml
'
```

(`EDITOR=nano` also works if you prefer not to point at the user profile binary.)

Edit:

- `hermes_env` — dotenv block, at least:
  - `OPENROUTER_API_KEY=…` (or `ANTHROPIC_API_KEY=…`)
  - `SIGNAL_HTTP_URL=http://127.0.0.1:8080`
  - `SIGNAL_ACCOUNT=+47…` (E.164)
  - `SIGNAL_ALLOWED_USERS=+47…,+47…` (you + spouse)
- `signal_cli_account` — same E.164 as `SIGNAL_ACCOUNT`
- `travis_ssh_private_key` — already seeded (travis-only outbound identity)

Travis keeps the **shared** `secrets/id_ed25519.pub` in `authorizedKeys`, so your existing machines can still SSH in. Outbound `~/.ssh/id_ed25519` on travis is the travis-only key.

## 4. Switch to this flake

On the Pi (native build — slow but simple):

```bash
cd ~/dotfiles
sudo nixos-rebuild switch --flake '.#travis'
```

Or from an x86_64 NixOS box with emulation (e.g. fatman):

```nix
# on the build machine
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

```bash
nixos-rebuild switch --flake '.#travis' --target-host petter@travis --use-remote-sudo
```

## 5. Link signal-cli (once)

`signal-cli` runs as user `signal-cli` with `HOME=/var/lib/signal-cli`. Link it as a secondary Signal device:

```bash
sudo -u signal-cli -H signal-cli link -n travis
```

Scan the QR code in Signal → Settings → Linked devices.

Then:

```bash
sudo systemctl restart signal-cli hermes-agent
curl -s http://127.0.0.1:8080/api/v1/check
systemctl status signal-cli hermes-agent
journalctl -u hermes-agent -f
```

Send a Signal DM from an allowlisted number to smoke-test.

## 6. Mealie (later)

Mealie stays on littleboy. Point Hermes at it over the tailnet when ready (put the Bearer token in `hermes_env`, not in Nix):

- `http://mealie.lab.hoem.tech` or `http://littleboy:9000`
- Create a long-lived token in Mealie at `/user/profile/api-tokens`

## Layout in this repo

| Path | Role |
|------|------|
| `flake.nix` → `nixosConfigurations.travis` | aarch64 host |
| `modules/common/rpi-server.nix` | Lean headless Pi base |
| `modules/hosts/travis.nix` | Hostname, user, SSH identity |
| `modules/hosts/travis/hermes.nix` | Hermes + signal-cli |
| `hosts/travis/hardware-configuration.nix` | SD filesystem labels |
| `secrets/travis.yaml` | Encrypted travis secrets |
| `secrets/travis_id_ed25519.pub` | Travis outbound public key |
