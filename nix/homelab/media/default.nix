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
  };

  systemd.services.qbittorrent = {
    serviceConfig = {
      ProtectHome = lib.mkForce false; # allows access to /home
      ReadWritePaths = [ "/home/petter/Media/Downloads" ]; # explicit write access
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "${user.name}";
  };
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
}
