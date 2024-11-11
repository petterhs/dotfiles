{ pkgs, ... }:
{
  imports = [
    ./home-assistant
    ./mosquitto
    ./zigbee2mqtt
    ./jellyfin
  ];
}
