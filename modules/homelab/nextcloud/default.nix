{ config, lib, pkgs, ... }:
{
  systemd.services.nextcloud-setup = {
    after = [ "postgresql-setup.service" ];
    requires = [ "postgresql-setup.service" ];
  };

  services.postgresql.authentication = lib.mkOverride 10 ''
    local  all  all  trust
    host   all  all  127.0.0.1/32  trust
    host   all  all  ::1/128      trust
  '';

  services.nextcloud = {
    enable = true;
    hostName = "cloud.${if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName}";
    https = false;
    maxUploadSize = "512M";
    package = pkgs.nextcloud34;

    database.createLocally = false;
    config = {
      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbpassFile = config.sops.secrets."nextcloud-db-pass".path;
    };

    settings = let
      base = if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName;
    in {
      trusted_domains = [ "cloud.${base}" base config.networking.hostName ];
      overwriteprotocol = "http";
      default_phone_region = "NO";
    };
  };

  # Append to existing Postgres config (home-assistant etc. set ensureDatabases/ensureUsers too)
  services.postgresql.ensureDatabases = lib.mkAfter [ "nextcloud" ];
  services.postgresql.ensureUsers = lib.mkAfter [
    { name = "nextcloud"; ensureDBOwnership = true; }
  ];

  sops.secrets."nextcloud-db-pass" = {
    key = "nextcloud_db_pass";
    owner = "nextcloud";
    mode = "0600";
  };
}
