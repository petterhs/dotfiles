# Music Assistant service
{ config, pkgs, ... }:
{
  services.music-assistant = {
    enable = true;
    
    # Providers for music services and players
    providers = [
      "hass"           # Home Assistant integration
      "hass_players"   # Home Assistant media players
      "spotify"        # Spotify music service
      "sonos"          # Sonos speakers
    ];
    
    # Additional options
    extraOptions = [
      "--config"
      "/var/lib/music-assistant"
    ];
  };

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 8095 ];
}
