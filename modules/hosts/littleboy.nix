# littleboy specific configuration
{ config, pkgs, ... }:
{
  # Hostname
  networking.hostName = "littleboy";

  homelab.labDomain = "lab.hoem.tech";

  homelab.audiobookshelfPublic = {
    enable = true;
    domain = "audio.hoem.app";
    tunnelId = "51b6452b-e758-456f-9b8c-e28b40d4636c";
  };

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

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root petter
  '';

  # Additional firewall ports for homelab services
  networking.firewall.allowedTCPPorts = [
    2283  # Immich
    8095  # Music Assistant
    1400  # Sonos (for Music Assistant)
    5432  # PostgreSQL (local only)
    6379  # Redis (local only)
  ];
}
