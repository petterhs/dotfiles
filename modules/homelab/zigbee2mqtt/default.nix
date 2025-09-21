{ pkgs, lib, ... }:
let
  dataDir = "/var/lib/zigbee2mqtt";
in
{
  services.zigbee2mqtt = {
    enable = lib.mkForce true;
    inherit dataDir;
    package = lib.mkForce pkgs.zigbee2mqtt_2;
    settings = lib.mkForce {
      permit_join = true;
      homeassistant = true;
      frontend.port = 8521;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://localhost:1883";
      };
      serial = {
        port = "tcp://192.168.68.56:6638";
        adapter = "ember";
        rtscts = false;
      };
    };
  };

  # state = [
  #   "${dataDir}/devices.yaml"
  #   "${dataDir}/state.json"
  # ];

  systemd.services.zigbee2mqtt = {
    environment.ZIGBEE2MQTT_DATA = dataDir;
    after = [
      "home-assistant.service"
      "mosquitto.service"
    ];
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = 10;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8521 ];
}
