{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "airthings_ble"
      "airthings"
      "androidtv"
      "androidtv_remote"
      "cast"
      "esphome"
      "daikin"
      "google_translate"
      "ibeacon"
      "immich"
      "isal"
      "local_calendar"
      "local_todo"
      "mill"
      "met"
      "mqtt"
      "music_assistant"
      "myuplink"
      "qbittorrent"
      "radio_browser"
      "remote_calendar"
      "samsungtv"
      "smartthings"
      "smlight"
      "sonos"
      "systemmonitor"
      "switchbot"
      "tesla_fleet"
      "teslemetry"
      "tibber"
      "xiaomi_ble"
    ];

    # Add Python deps needed by HA (e.g., PostgreSQL driver)
    extraPackages = ps: with ps; [ psycopg2 ];

    customComponents = with pkgs.home-assistant-custom-components; [
      waste_collection_schedule
      samsungtv-smart
      adaptive_lighting
      plant
      openplantbook
      ha_washdata
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
      mini-media-player
      hourly-weather
      mushroom
      universal-remote-card
      flower-card
      decluttering-card
      weather-card
      auto-entities
      bubble-card
      button-card
      card-mod

      #from overlays
      navbar-card
      swipe-card
      my-cards-bundle

    ];

    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" "::1" ];
      };
      frontend = {
        themes = "!include_dir_merge_named themes";
      };
      recorder.db_url = "postgresql://@/hass";
      notify = [
        {
          platform = "group";
          name = "phones";
          services = [
            { action = "mobile_app_pixel_10_pro"; }
            { action = "mobile_app_elida_sofie_sin_iphone"; }
          ];
        }
      ];
      "automation nixos" = [
        # YAML automations go here
      ];
      "automation ui" = "!include automations.yaml";
      "scene ui" = "!include scenes.yaml";
      "script ui" = "!include scripts.yaml";
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "hass" ];
    ensureUsers = [
      {
        name = "hass";
        ensureDBOwnership = true;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
