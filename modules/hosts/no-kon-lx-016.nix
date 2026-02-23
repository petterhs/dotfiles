# no-kon-lx-016 specific configuration
{ config, pkgs, ... }:
{
  # Hostname
  networking.hostName = "no-kon-lx-016";

  # Allow unsupported system
  nixpkgs.config.allowUnsupportedSystem = true;

  # NetworkManager with SSTP plugin
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-sstp ];
  };

  # User configuration
  users.users.s27731 = {
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
      firefox
    ];
  };

  # XDG Portal GTK service configuration
  systemd.user.services.xdg-desktop-portal-gtk = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root s27731
  '';

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "s27731";
    group = "users";
    dataDir = "/home/s27731/.local/share/syncthing";
    configDir = "/home/s27731/.config/syncthing";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
