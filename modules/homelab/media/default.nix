{ pkgs, lib, ... }:
let
  user = {
    name = "petter";
    group = "users";
  };
  mediaUMask = "0002";
  mediaPaths = {
    downloads = "/home/petter/Media/Downloads";
    series = "/home/petter/Media/Series";
    movies = "/home/petter/Media/Movies";
  };
in
{
  services = {
    qbittorrent = {
      enable = true;
      user = user.name;
      group = user.group;
    };
    radarr = {
      enable = true;
      user = user.name;
      group = user.group;
      dataDir = "/mediaconfs/radarr";
    };
    sonarr = {
      enable = true;
      user = user.name;
      group = user.group;
      dataDir = "/mediaconfs/sonarr";
    };
    bazarr = {
      enable = true;
      user = user.name;
      group = user.group;
    };
    prowlarr = {
      enable = true;
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      user = user.name;
      group = user.group;
    };
    audiobookshelf = {
      enable = true;
      user = user.name;
    };
    calibre-web = {
      enable = true;
      openFirewall = true;
      user = user.name;
      group = user.group;
      listen.ip = "0.0.0.0";
      options.calibreLibrary = "/home/petter/Media/Books";
    };
  };

  systemd.services = {
    qbittorrent = {
      serviceConfig = {
        UMask = lib.mkForce mediaUMask;
        NoNewPrivileges = lib.mkForce false;
        ProtectHome = lib.mkForce false; # allows access to /home
        ReadWritePaths = [ mediaPaths.downloads ];
      };
    };

    sonarr = {
      serviceConfig = {
        UMask = lib.mkForce mediaUMask;
        NoNewPrivileges = lib.mkForce false;
        ProtectHome = lib.mkForce false; # avoid /home being remounted as tmpfs
        ReadWritePaths = [
          mediaPaths.series
          mediaPaths.downloads
        ];
      };
    };

    radarr = {
      serviceConfig = {
        UMask = lib.mkForce mediaUMask;
        NoNewPrivileges = lib.mkForce false;
        ProtectHome = lib.mkForce false;
        ReadWritePaths = [
          mediaPaths.movies
          mediaPaths.downloads
        ];
      };
    };

    jellyfin = {
      serviceConfig = {
        UMask = lib.mkForce mediaUMask;
        ProtectHome = lib.mkForce false;
        ReadWritePaths = [
          mediaPaths.series
          mediaPaths.movies
        ];
      };
    };

    calibre-web = {
      serviceConfig = {
        ProtectHome = lib.mkForce false;
      };
    };
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg

    pkgs.calibre

    # Publish to home assistant when torrent finishes
    (pkgs.writeShellScriptBin "qb-on-finish" ''
      exec ${pkgs.curl}/bin/curl \
        -H "Content-Type: application/json" \
        --data "$(printf '{"torrent":"%s"}' "$1")" \
        http://127.0.0.1:8123/api/webhook/qbittorrent
    '')
  ];
}
