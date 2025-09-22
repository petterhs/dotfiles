{ pkgs, ... }:
{
  services.home-assistant = {
    enable = true;
    package =
      (pkgs.home-assistant.override {
        extraPackages = py: with py; [ psycopg2 ];
      }).overrideAttrs
        (oldAttrs: {
          doInstallCheck = false;
        });
    extraComponents = [
      "airthings_ble"
      "airthings"
      "androidtv"
      "cast"
      "esphome"
      "daikin"
      "google_translate"
      "ibeacon"
      "immich"
      "mill"
      "met"
      "mqtt"
      "music_assistant"
      "myuplink"
      "radio_browser"
      "samsungtv"
      "smlight"
      "sonos"
      "systemmonitor"
      "switchbot"
      "tesla_fleet"
      "tibber"
      "xiaomi_ble"
    ];

    customComponents = with pkgs.home-assistant-custom-components; [
      waste_collection_schedule
      samsungtv-smart
      adaptive_lighting
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
      mini-media-player
      hourly-weather
      mushroom
      universal-remote-card
      # navbar-card  # Temporarily commented out - build failing with bun install error
    ];

    config = {
      default_config = { };
      recorder.db_url = "postgresql://@/hass";
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
