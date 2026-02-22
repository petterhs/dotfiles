# Homepage dashboard + nginx gateway: one nginx on port 80, hostname-based vhosts to all homelab web UIs.
# Access: http://home.littleboy (dashboard), http://qb.littleboy, http://cloud.littleboy (Nextcloud), etc.
# Each vhost is added separately so Nextcloud's cloud.littleboy vhost (from nextcloud module) is preserved.
{ config, lib, pkgs, ... }:
let
  proxy = port: {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    extraConfig = "proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme;";
  };
  vhost = name: port: {
    serverName = name;
    locations."/" = proxy port;
  };
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "home.littleboy" = vhost "home.littleboy" 8082;
      "qb.littleboy" = vhost "qb.littleboy" 8080;
      "syncthing.littleboy" = vhost "syncthing.littleboy" 8384;
      "immich.littleboy" = vhost "immich.littleboy" 2283;
      "hass.littleboy" = vhost "hass.littleboy" 8123;
      "z2m.littleboy" = vhost "z2m.littleboy" 8521;
      "radarr.littleboy" = vhost "radarr.littleboy" 7878;
      "sonarr.littleboy" = vhost "sonarr.littleboy" 8989;
      "prowlarr.littleboy" = vhost "prowlarr.littleboy" 9696;
      "bazarr.littleboy" = vhost "bazarr.littleboy" 6767;
      "jellyfin.littleboy" = vhost "jellyfin.littleboy" 8096;
      "audiobookshelf.littleboy" = vhost "audiobookshelf.littleboy" 13378;
      "calibre.littleboy" = vhost "calibre.littleboy" 8083;
      "music.littleboy" = vhost "music.littleboy" 8095;
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = false;

    bookmarks = [
      {
        Homelab = [
          { "Dashboard" = [ { abbr = "Home"; href = "http://home.littleboy"; } ]; }
          { "Nextcloud" = [ { abbr = "NC"; href = "http://cloud.littleboy"; } ]; }
          { "Syncthing" = [ { abbr = "Sync"; href = "http://syncthing.littleboy"; } ]; }
          { "qBittorrent" = [ { abbr = "qB"; href = "http://qb.littleboy"; } ]; }
          { "Home Assistant" = [ { abbr = "HASS"; href = "http://hass.littleboy"; } ]; }
          { "Zigbee2MQTT" = [ { abbr = "Z2M"; href = "http://z2m.littleboy"; } ]; }
          { "Immich" = [ { abbr = "Imm"; href = "http://immich.littleboy"; } ]; }
          { "Jellyfin" = [ { abbr = "Jelly"; href = "http://jellyfin.littleboy"; } ]; }
          { "Audiobookshelf" = [ { abbr = "ABS"; href = "http://audiobookshelf.littleboy"; } ]; }
          { "Calibre" = [ { abbr = "Cal"; href = "http://calibre.littleboy"; } ]; }
          { "Music Assistant" = [ { abbr = "MASS"; href = "http://music.littleboy"; } ]; }
          { "Radarr" = [ { abbr = "Rad"; href = "http://radarr.littleboy"; } ]; }
          { "Sonarr" = [ { abbr = "Son"; href = "http://sonarr.littleboy"; } ]; }
          { "Prowlarr" = [ { abbr = "Pro"; href = "http://prowlarr.littleboy"; } ]; }
          { "Bazarr" = [ { abbr = "Baz"; href = "http://bazarr.littleboy"; } ]; }
        ];
      }
    ];
  };
}
