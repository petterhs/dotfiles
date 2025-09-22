# Immich photo backup service
{ config, pkgs, ... }:
{
  services.immich = {
    enable = true;
    settings = {
      # Database configuration
      DB_HOSTNAME = "localhost";
      DB_PORT = 5432;
      DB_USERNAME = "immich";
      DB_PASSWORD = "immich";
      DB_DATABASE_NAME = "immich";
      
      # Redis configuration
      REDIS_HOSTNAME = "localhost";
      REDIS_PORT = 6379;
      
      # Server configuration
      SERVER_PORT = 2283;
      NODE_ENV = "production";
      
      # File upload configuration
      UPLOAD_LOCATION = "/var/lib/immich/upload";
      
      # JWT configuration
      JWT_SECRET = "immich_jwt_secret_key";
      
      # Logging
      LOG_LEVEL = "simple";
    };
  };

  # PostgreSQL database for Immich
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "immich" ];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
  };

  # Redis for caching
  services.redis = {
    servers."".enable = true;
  };

  # Create upload directory
  systemd.tmpfiles.rules = [
    "d /var/lib/immich/upload 0755 immich immich -"
  ];

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 2283 ];
}
