{
  config,
  lib,
  pkgs,
  ...
}:
let
  base =
    if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName;
  url = path: "http://${path}";
in
{
  # Nextcloud module enables nginx and adds cloud.* vhost. Override that vhost to listen only on 81
  # so Caddy can bind to 80 and proxy cloud.* to nginx.
  services.nginx.virtualHosts."cloud.${base}" = {
    listen = [
      {
        port = 81;
        addr = "127.0.0.1";
      }
    ];
  };

  services.caddy = {
    enable = true;
    globalConfig = "auto_https off";
    virtualHosts = {
      "http://home.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8082";
      };
      "http://qb.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8080";
      };
      "http://syncthing.${base}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8384 {
            header_up Host 127.0.0.1
          }
        '';
      };
      "http://hass.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8123";
      };
      "http://z2m.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8521";
      };
      "http://radarr.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:7878";
      };
      "http://sonarr.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8989";
      };
      "http://prowlarr.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:9696";
      };
      "http://bazarr.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:6767";
      };
      "http://jellyfin.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8096";
      };
      "http://audiobookshelf.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8000";
      };
      "http://calibre.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8083";
      };
      "http://music.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:8095";
      };
      "http://cloud.${base}" = {
        extraConfig = "reverse_proxy 127.0.0.1:81";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = false;
    allowedHosts = "home.${base},127.0.0.1,localhost";

    services = [
      {
        Homelab = [
          {
            "Dashboard" = [
              {
                abbr = "Home";
                href = url "home.${base}";
                icon = "home";
              }
            ];
          }
          {
            "Nextcloud" = [
              {
                abbr = "NC";
                href = url "cloud.${base}";
                icon = "cloud";
              }
            ];
          }
          {
            "Syncthing" = [
              {
                abbr = "Sync";
                href = url "syncthing.${base}";
                icon = "sync";
              }
            ];
          }
          {
            "qBittorrent" = [
              {
                abbr = "qB";
                href = url "qb.${base}";
                icon = "download";
              }
            ];
          }
          {
            "Home Assistant" = [
              {
                abbr = "HASS";
                href = url "hass.${base}";
                icon = "home-assistant";
              }
            ];
          }
          {
            "Zigbee2MQTT" = [
              {
                abbr = "Z2M";
                href = url "z2m.${base}";
                icon = "zigbee";
              }
            ];
          }
          {
            "Jellyfin" = [
              {
                abbr = "Jelly";
                href = url "jellyfin.${base}";
                icon = "jellyfin";
              }
            ];
          }
          {
            "Audiobookshelf" = [
              {
                abbr = "ABS";
                href = url "audiobookshelf.${base}";
                icon = "audiobookshelf";
              }
            ];
          }
          {
            "Calibre" = [
              {
                abbr = "Cal";
                href = url "calibre.${base}";
                icon = "calibre";
              }
            ];
          }
          {
            "Music Assistant" = [
              {
                abbr = "MASS";
                href = url "music.${base}";
                icon = "music-assistant";
              }
            ];
          }
          {
            "Radarr" = [
              {
                abbr = "Rad";
                href = url "radarr.${base}";
                icon = "radarr";
              }
            ];
          }
          {
            "Sonarr" = [
              {
                abbr = "Son";
                href = url "sonarr.${base}";
                icon = "sonarr";
              }
            ];
          }
          {
            "Prowlarr" = [
              {
                abbr = "Pro";
                href = url "prowlarr.${base}";
                icon = "prowlarr";
              }
            ];
          }
          {
            "Bazarr" = [
              {
                abbr = "Baz";
                href = url "bazarr.${base}";
                icon = "bazarr";
              }
            ];
          }
        ];
      }
    ];
  };
}
