{ pkgs, lib, ... }:
let
  # SLZB-MR4U Thread RCP exposed as Spinel-over-TCP (SLZB-OS). Upstream otbr-agent only
  # implements spinel+hdlc+uart / spi / vendor — not spinel+tcp — so we mirror the HA OTBR
  # add-on approach: socat connects TCP to a local PTY otbr-agent opens as a serial device.
  slzbThread = {
    host = "192.168.68.60";
    port = 6638;
  };
in
{
  services.matter-server.enable = true;

  services.openthread-border-router = {
    enable = true;

    # littleboy interfaces seen in hardware config: eno1, wlo2
    backboneInterfaces = [ "eno1" ];

    radio.url =
      "spinel+hdlc+uart:///run/otbr-spinel-proxy/spinel?uart-baudrate=460800";

    web = {
      enable = true;
      listenAddress = "127.0.0.1";
      listenPort = 8094;
    };

    rest = {
      listenAddress = "0.0.0.0";
      listenPort = 8081;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8081 ];

  systemd.services.otbr-spinel-tcp-proxy = {
    description = "TCP → PTY bridge for SLZB Thread RCP (otbr-agent)";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    before = [ "otbr-agent.service" ];
    serviceConfig = {
      Type = "exec";
      RuntimeDirectory = "otbr-spinel-proxy";
      Restart = "on-failure";
      RestartSec = 3;
      ExecStart = "${lib.getExe pkgs.socat} pty,raw,echo=0,link=/run/otbr-spinel-proxy/spinel TCP4:${slzbThread.host}:${toString slzbThread.port}";
    };
  };

  systemd.services.otbr-agent = {
    requires = [ "otbr-spinel-tcp-proxy.service" ];
    after = [ "otbr-spinel-tcp-proxy.service" ];
  };
}
