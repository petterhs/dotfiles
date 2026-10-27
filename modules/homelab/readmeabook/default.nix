# ReadMeABook — audiobook request/download automation (Radarr/Overseerr for audiobooks).
# Image: ghcr.io/kikootwo/readmeabook
# After deploy, open http://readmeabook.<labDomain> and complete the setup wizard.
# Point Prowlarr and Audiobookshelf at host.docker.internal.
# Point qBittorrent at 192.168.15.1:8080 (Proton namespace, not the host loopback).
# Use host paths for downloads/media (mounted 1:1) so they match native qBittorrent.
{
  config,
  lib,
  ...
}:
let
  base =
    if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName;
  dataDir = "/mediaconfs/readmeabook";
  mediaRoot = "/home/petter/Media";
  # Match petter / users on littleboy (same ownership as other media services)
  puid = "1000";
  pgid = "100";
in
{
  virtualisation.oci-containers = {
    backend = "docker";
    containers.readmeabook = {
      image = "ghcr.io/kikootwo/readmeabook:latest";
      ports = [ "127.0.0.1:3030:3030" ];
      volumes = [
        "${dataDir}/config:/app/config"
        "${dataDir}/cache:/app/cache"
        "${dataDir}/pgdata:/var/lib/postgresql/data"
        "${dataDir}/redis:/var/lib/redis"
        # Identical host paths so native qBittorrent and RMAB see the same files
        "${mediaRoot}/Downloads:${mediaRoot}/Downloads"
        "${mediaRoot}/Audiobooks:${mediaRoot}/Audiobooks"
      ];
      environment = {
        PUID = puid;
        PGID = pgid;
        UMASK = "002";
        PUBLIC_URL = "http://readmeabook.${base}";
      };
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 petter users -"
    "d ${dataDir}/config 0755 petter users -"
    "d ${dataDir}/cache 0755 petter users -"
    # Image postgres UID is 102 (1.2.7+); entrypoint also corrects ownership
    "d ${dataDir}/pgdata 0700 102 users -"
    "d ${dataDir}/redis 0755 petter users -"
    "d ${mediaRoot}/Audiobooks 0775 petter users -"
  ];
}
