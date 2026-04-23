{ pkgs, ... }:
{
  imports = [
    ./lab-domain
    ./home-assistant
    ./mosquitto
    ./zigbee2mqtt
    ./matter/matter.nix
    ./media
    # ./immich
    ./music-assistant
    ./nextcloud
    ./syncthing
    ./homepage
  ];
}
