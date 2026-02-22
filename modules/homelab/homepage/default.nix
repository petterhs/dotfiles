{ config, lib, pkgs, ... }:
let
  base = if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName;
  proxy = port: {
    proxyPass = "http://127.0.0.1:${toString port}";
    proxyWebsockets = true;
    extraConfig = "proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme;";
  };
  vhost = name: port: {
    serverName = name;
    locations."/" = proxy port;
  };
  vhosts = {
    "home.${base}" = vhost "home.${base}" 8082;
    "qb.${base}" = vhost "qb.${base}" 8080;
    "syncthing.${base}" = vhost "syncthing.${base}" 8384;
    "immich.${base}" = vhost "immich.${base}" 2283;
    "hass.${base}" = vhost "hass.${base}" 8123;
    "z2m.${base}" = vhost "z2m.${base}" 8521;
    "radarr.${base}" = vhost "radarr.${base}" 7878;
    "sonarr.${base}" = vhost "sonarr.${base}" 8989;
    "prowlarr.${base}" = vhost "prowlarr.${base}" 9696;
    "bazarr.${base}" = vhost "bazarr.${base}" 6767;
    "jellyfin.${base}" = vhost "jellyfin.${base}" 8096;
    "audiobookshelf.${base}" = vhost "audiobookshelf.${base}" 13378;
    "calibre.${base}" = vhost "calibre.${base}" 8083;
    "music.${base}" = vhost "music.${base}" 8095;
  };
  url = path: "http://${path}";
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = vhosts;
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = false;

    bookmarks = [
      {
        Homelab = [
          { "Dashboard" = [ { abbr = "Home"; href = url "home.${base}"; } ]; }
          { "Nextcloud" = [ { abbr = "NC"; href = url "cloud.${base}"; } ]; }
          { "Syncthing" = [ { abbr = "Sync"; href = url "syncthing.${base}"; } ]; }
          { "qBittorrent" = [ { abbr = "qB"; href = url "qb.${base}"; } ]; }
          { "Home Assistant" = [ { abbr = "HASS"; href = url "hass.${base}"; } ]; }
          { "Zigbee2MQTT" = [ { abbr = "Z2M"; href = url "z2m.${base}"; } ]; }
          { "Immich" = [ { abbr = "Imm"; href = url "immich.${base}"; } ]; }
          { "Jellyfin" = [ { abbr = "Jelly"; href = url "jellyfin.${base}"; } ]; }
          { "Audiobookshelf" = [ { abbr = "ABS"; href = url "audiobookshelf.${base}"; } ]; }
          { "Calibre" = [ { abbr = "Cal"; href = url "calibre.${base}"; } ]; }
          { "Music Assistant" = [ { abbr = "MASS"; href = url "music.${base}"; } ]; }
          { "Radarr" = [ { abbr = "Rad"; href = url "radarr.${base}"; } ]; }
          { "Sonarr" = [ { abbr = "Son"; href = url "sonarr.${base}"; } ]; }
          { "Prowlarr" = [ { abbr = "Pro"; href = url "prowlarr.${base}"; } ]; }
          { "Bazarr" = [ { abbr = "Baz"; href = url "bazarr.${base}"; } ]; }
        ];
      }
    ];
  };
}
