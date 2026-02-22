{ config, pkgs, ... }:
{
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "petter";
    group = "users";
    dataDir = "/home/petter/.local/share/syncthing";
    configDir = "/home/petter/.config/syncthing";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
