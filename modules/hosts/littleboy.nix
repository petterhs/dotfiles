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

  # Queue for video recipe imports. Create this environment file with
  # sops before enabling the service; it must contain QUEUE_TOKEN=....
  services.familyRecipeImporter = {
    enable = true;
    host = "0.0.0.0";
    port = 8088;
    environmentFile = "/run/secrets/family-recipe-importer.env";
    openFirewall = true;
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
