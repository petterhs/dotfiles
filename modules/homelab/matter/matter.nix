{ ... }:
{
  services.matter-server.enable = true;

  services.openthread-border-router = {
    enable = true;

    # littleboy interfaces seen in hardware config: eno1, wlo2
    backboneInterfaces = [ "eno1" ];

    # SLZB-MR4U over IP 
    radio.url = "spinel+tcp://192.168.68.60:6638";

    web.enable = true;
  };
}
