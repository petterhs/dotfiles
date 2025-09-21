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
      # Server packages only
    ];
  };

  # No desktop environment - headless server

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
