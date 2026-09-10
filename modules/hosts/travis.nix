# travis — Raspberry Pi 4 Hermes host
{ lib, pkgs, ... }:
{
  networking.hostName = "travis";

  # Downstream linux-rpi from nixos-hardware is no longer on cache.nixos.org —
  # building it OOMs a 4GB Pi. Mainline is fine for headless Hermes + Tailscale.
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages;

  # Absorb memory spikes if anything still builds locally
  zramSwap.enable = true;
  nix.settings = {
    max-jobs = 1;
    cores = 2;
  };

  # Travis-only outbound SSH identity; shared pub stays in authorizedKeys for login
  dotfiles.sshIdentity = {
    privateKeySopsKey = "travis_ssh_private_key";
    publicKeyPath = ../../secrets/travis_id_ed25519.pub;
    sopsFile = ../../secrets/travis.yaml;
  };

  users.users.petter = {
    isNormalUser = true;
    description = "petter";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
  ];

  nix.extraOptions = ''
    trusted-users = root petter
  '';

  # SSH + Tailscale only (Tailscale opens its own port)
  networking.firewall.allowedTCPPorts = [ 22 ];
}
