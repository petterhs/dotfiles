# Server development tools and services (no desktop components)
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

  # Development tools (server-appropriate)
  programs.adb.enable = true;
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

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
