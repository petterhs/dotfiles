# Music Assistant service
{ config, pkgs, ... }:
{
  systemd.services.music-assistant.path = [ pkgs.librespot-ma ];

  environment.systemPackages = with pkgs; [
    librespot-ma
  ];

  services.music-assistant = {
    enable = true;
    providers = [
      "audiobookshelf"
      "hass" # Home Assistant integration
      "hass_players" # Home Assistant media players
      "jellyfin"
      "spotify" # Spotify music service
      "spotify_connect"
      "sonos" # Sonos speakers
      "sonos_s1"
    ];
  };

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [
    8095
    8097
  ];
  networking.firewall.allowedUDPPorts = [
    8095
    8097
  ];
}
