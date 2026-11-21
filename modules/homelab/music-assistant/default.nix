# Music Assistant service
{ pkgs, ... }:
{
  systemd.services.music-assistant = {
    path = [ pkgs.librespot-ma ];
    # NetworkManager can finish startup before a usable LAN address exists.
    # Retry transient discovery failures instead of staying failed until reboot.
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 10;
    };
  };

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
      "sendspin"
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
