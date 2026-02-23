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
        "Overview" = [
          {
            "Home" = {
              href = url "home.${base}";
              icon = "house";
              description = "This dashboard";
            };
          }
        ];
      }
      {
        "Cloud & Sync" = [
          {
            "Nextcloud" = {
              href = url "cloud.${base}";
              icon = "nextcloud";
              description = "Cloud storage";
            };
          }
          {
            "Syncthing" = {
              href = url "syncthing.${base}";
              icon = "syncthing";
              description = "File sync";
            };
          }
        ];
      }
      {
        "Downloads" = [
          {
            "qBittorrent" = {
              href = url "qb.${base}";
              icon = "qbittorrent";
              description = "Torrent client";
            };
          }
        ];
      }
      {
        "Smart Home" = [
          {
            "Home Assistant" = {
              href = url "hass.${base}";
              icon = "home-assistant";
              description = "Home automation";
            };
          }
          {
            "Zigbee2MQTT" = {
              href = url "z2m.${base}";
              icon = "zigbee2mqtt";
              description = "Zigbee bridge";
            };
          }
        ];
      }
      {
        "Media" = [
          {
            "Jellyfin" = {
              href = url "jellyfin.${base}";
              icon = "jellyfin";
              description = "Movies & TV";
            };
          }
          {
            "Audiobookshelf" = {
              href = url "audiobookshelf.${base}";
              icon = "audiobookshelf";
              description = "Audiobooks";
            };
          }
          {
            "Calibre" = {
              href = url "calibre.${base}";
              icon = "calibre-web";
              description = "E-books";
            };
          }
          {
            "Music Assistant" = {
              href = url "music.${base}";
              icon = "music-assistant";
              description = "Music library";
            };
          }
        ];
      }
      {
        "*arr Stack" = [
          {
            "Radarr" = {
              href = url "radarr.${base}";
              icon = "radarr";
              description = "Movies";
            };
          }
          {
            "Sonarr" = {
              href = url "sonarr.${base}";
              icon = "sonarr";
              description = "TV series";
            };
          }
          {
            "Prowlarr" = {
              href = url "prowlarr.${base}";
              icon = "prowlarr";
              description = "Indexer manager";
            };
          }
          {
            "Bazarr" = {
              href = url "bazarr.${base}";
              icon = "bazarr";
              description = "Subtitles";
            };
          }
        ];
      }
    ];

    # Dark theme and layout for grouped sections
    settings = {
      theme = "dark";
      color = "slate";
      layout = {
        "Overview" = { style = "row"; columns = 4; };
        "Cloud & Sync" = { style = "row"; columns = 4; };
        "Downloads" = { style = "row"; columns = 4; };
        "Smart Home" = { style = "row"; columns = 4; };
        "Media" = { style = "row"; columns = 4; };
        "*arr Stack" = { style = "row"; columns = 4; };
      };
    };

    # Catppuccin Mocha–inspired custom CSS (base, surface, text, accents)
    customCSS = ''
      :root {
        --ctp-rosewater: #f5e0dc;
        --ctp-flamingo: #f2cdcd;
        --ctp-pink: #f5c2e7;
        --ctp-mauve: #cba6f7;
        --ctp-red: #f38ba8;
        --ctp-maroon: #eba0ac;
        --ctp-peach: #fab387;
        --ctp-yellow: #f9e2af;
        --ctp-green: #a6e3a1;
        --ctp-teal: #94e2d5;
        --ctp-sky: #89dceb;
        --ctp-sapphire: #74c7ec;
        --ctp-blue: #89b4fa;
        --ctp-lavender: #b4befe;
        --ctp-text: #cdd6f4;
        --ctp-subtext1: #bac2de;
        --ctp-subtext0: #a6adc8;
        --ctp-overlay2: #9399b2;
        --ctp-overlay1: #7f849c;
        --ctp-overlay0: #6c7086;
        --ctp-surface2: #585b70;
        --ctp-surface1: #45475a;
        --ctp-surface0: #313244;
        --ctp-base: #1e1e2e;
        --ctp-mantle: #181825;
        --ctp-crust: #11111b;
      }
      [data-theme="dark"], .dark {
        --bg-primary: var(--ctp-base) !important;
        --bg-secondary: var(--ctp-mantle) !important;
        --bg-tertiary: var(--ctp-crust) !important;
        --text-primary: var(--ctp-text) !important;
        --text-secondary: var(--ctp-subtext1) !important;
        --accent: var(--ctp-blue) !important;
        --accent-hover: var(--ctp-sapphire) !important;
      }
      body { background-color: var(--ctp-base) !important; }
      [class*="bg-"].dark\\:bg-gray-800 { background-color: var(--ctp-surface0) !important; }
      [class*="bg-"].dark\\:bg-gray-900 { background-color: var(--ctp-mantle) !important; }
      .rounded-xl { border-radius: 12px; }
      a[class*="rounded"]:hover { background-color: var(--ctp-surface1) !important; }
      h1, h2, [class*="text-gray"] { color: var(--ctp-text) !important; }
      p, span[class*="text-gray"] { color: var(--ctp-subtext1) !important; }
    '';
  };
}
