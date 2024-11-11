{ pgks, ... }:

let
  dataDir = "/var/lib/zigbee2mqtt";
in
{
  services.zigbee2mqtt = {
    enable = true;
    inherit dataDir;
    settings = {
      permit_join = true;
      homeassistant = true;
      frontend.port = 8521;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://localhost:1883";
      };
      serial = {
        port = "tcp://192.168.68.54:6638";
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
      "network-online.target"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8521 ];
}
