# Music Assistant service
{ config, pkgs, ... }:
{
  services.music-assistant = {
    enable = true;
    settings = {
      # Server configuration
      host = "0.0.0.0";
      port = 8095;
      
      # Database configuration
      database_url = "sqlite:///var/lib/music-assistant/music_assistant.db";
      
      # Logging
      log_level = "INFO";
      
      # Home Assistant integration
      ha_token = "your_home_assistant_token_here";
      ha_url = "http://localhost:8123";
    };
  };

  # Create data directory
  systemd.tmpfiles.rules = [
    "d /var/lib/music-assistant 0755 music-assistant music-assistant -"
  ];

  # Firewall configuration
  networking.firewall.allowedTCPPorts = [ 8095 ];

  # User for music-assistant service
  users.users.music-assistant = {
    isSystemUser = true;
    group = "music-assistant";
    home = "/var/lib/music-assistant";
    createHome = true;
  };

  users.groups.music-assistant = {};
}
