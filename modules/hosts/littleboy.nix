# littleboy specific configuration
{ config, pkgs, ... }:
{
  # Hostname
  networking.hostName = "littleboy";

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
      firefox
    ];
  };

  # XDG Portal configuration (simpler for littleboy)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Garbage collection (more aggressive for homelab)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root petter
  '';
}
