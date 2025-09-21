{ pkgs, ... }:
{
  imports = [
    ./home-assistant
    ./mosquitto
    ./zigbee2mqtt
    ./media
    ./immich
    ./music-assistant
  ];
}
