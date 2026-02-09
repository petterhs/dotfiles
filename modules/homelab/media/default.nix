{ pkgs, lib, ... }:
let
  user = {
    name = "petter";
  };
in
{
  services = {
    qbittorrent = {
      enable = true;
      user = "${user.name}";
    };
    radarr = {
      enable = true;
      user = "${user.name}";
      dataDir = "/mediaconfs/radarr";
    };
    sonarr = {
      enable = true;
      user = "${user.name}";
      dataDir = "/mediaconfs/sonarr";
    };
    bazarr = {
      enable = true;
      user = "${user.name}";
    };
    prowlarr = {
      enable = true;
    };
    jellyfin = {
      enable = true;
      openFirewall = true;
      user = "${user.name}";
    };
    audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      user = "${user.name}";
    };
  };

  systemd.services.qbittorrent = {
    serviceConfig = {
      NoNewPrivileges = lib.mkForce false;
      ProtectHome = lib.mkForce false; # allows access to /home
      ReadWritePaths = [ "/home/petter/Media/Downloads" ]; # explicit write access
    };
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg


    # Publish to home assistant when torrent finishes
    (pkgs.writeShellScriptBin "qb-on-finish" ''
      exec ${pkgs.curl}/bin/curl \
        -H "Content-Type: application/json" \
        --data "$(printf '{"torrent":"%s"}' "$1")" \
        http://127.0.0.1:8123/api/webhook/qbittorrent
    '')
  ];
}
