# travis — Raspberry Pi 4 Hermes host
{ pkgs, ... }:
{
  networking.hostName = "travis";

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
