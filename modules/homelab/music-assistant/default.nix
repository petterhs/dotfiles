# Music Assistant service
# The NixOS module sets PYTHONPATH = (package.override { providers }).pythonPath, so the
# overlay never affects the service. We force PYTHONPATH to prepend our aioaudiobookshelf 0.1.13.
{ config, pkgs, lib, ... }:
let
  aio = pkgs.python3Packages.aioaudiobookshelf;
  sitePackages = "${aio}/lib/python${pkgs.python3.pythonVersion}/site-packages";
  # Same env the module would build, so we can prepend our path to its pythonPath
  finalPackage = pkgs.music-assistant.override { providers = config.services.music-assistant.providers; };
in
{
  systemd.services.music-assistant = {
    path = [ pkgs.librespot-ma ];
    # Prepend aioaudiobookshelf 0.1.13 so import finds it before the env's 0.1.7
    environment.PYTHONPATH = lib.mkForce "${sitePackages}:${finalPackage.pythonPath}";
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
