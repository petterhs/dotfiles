# Common development tools and services
{ config, pkgs, ... }:
{
  # Docker
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Flatpak
  services.flatpak.enable = true;

  # Development tools
  programs.adb.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Nix trusted users (host-specific, moved to individual host modules)

  # Firewall ports for development
  networking.firewall.allowedTCPPorts = [
    1420
    8081
  ];
  networking.firewall.allowedUDPPorts = [
    1420
    8081
  ];
}
