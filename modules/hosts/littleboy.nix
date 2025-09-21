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

  # Additional firewall ports for homelab services
  networking.firewall.allowedTCPPorts = [
    2283  # Immich
    8095  # Music Assistant
    5432  # PostgreSQL (local only)
    6379  # Redis (local only)
  ];
}
