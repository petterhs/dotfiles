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

    radio.url = "spinel+hdlc+uart:///run/otbr-spinel-proxy/spinel?uart-baudrate=460800";

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
    # Bring the agent back after a radio outage and a successful proxy reconnect.
    upholds = [ "otbr-agent.service" ];
    postStart = ''
      # Type=exec alone does not wait for socat to create the serial device.
      while [ ! -c /run/otbr-spinel-proxy/spinel ]; do
        sleep 0.1
      done
    '';
    serviceConfig = {
      Type = "exec";
      RuntimeDirectory = "otbr-spinel-proxy";
      Restart = "on-failure";
      RestartSec = 10;
      TimeoutStartSec = 20;
      # Open TCP first so the PTY only appears once the radio is reachable.
      ExecStart = "${lib.getExe pkgs.socat} TCP4:${slzbThread.host}:${toString slzbThread.port},connect-timeout=10 pty,raw,echo=0,link=/run/otbr-spinel-proxy/spinel";
    };
  };

  systemd.services.otbr-agent = {
    requires = [ "otbr-spinel-tcp-proxy.service" ];
    bindsTo = [ "otbr-spinel-tcp-proxy.service" ];
    after = [ "otbr-spinel-tcp-proxy.service" ];
  };
}
