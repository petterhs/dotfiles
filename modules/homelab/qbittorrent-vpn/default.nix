# qBittorrent only, inside a Proton WireGuard network namespace.
# Tailscale and the rest of littleboy stay on the host default route.
# 192.168.15.1 is the qBittorrent end of a virtual cable on this machine.
# littleboy's LAN address does not change.
#
# Before the first switch, encrypt a Proton P2P WireGuard config:
#   ./scripts/setup-proton-wireguard.sh /path/to/proton.conf
{
  config,
  inputs,
  lib,
  ...
}:
let
  # VPN-Confinement defaults. Not the home LAN (192.168.68.0/24).
  namespaceAddress = "192.168.15.1";
  bridgeAddress = "192.168.15.5";
  webuiPort = 8080;
in
{
  imports = [ inputs.vpn-confinement.nixosModules.default ];

  sops.secrets.proton-wireguard = {
    key = "proton_wireguard_conf";
    path = "/run/secrets/proton-wireguard";
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "proton.service" ];
  };

  vpnNamespaces.proton = {
    enable = true;
    wireguardConfigFile = config.sops.secrets.proton-wireguard.path;
    inherit namespaceAddress bridgeAddress;
    # Home Assistant on littleboy's LAN address. The bridge address itself cannot be
    # an allowedEgress destination: VPN-Confinement would add a route via that same
    # address and the namespace setup would fail. Internet traffic still only leaves
    # through Proton.
    allowedEgress = [ "192.168.68.58" ];
    portMappings = [
      {
        from = webuiPort;
        to = webuiPort;
        protocol = "tcp";
      }
    ];
  };

  systemd.services.proton = {
    after = [ "sops-install-secrets.service" ];
    wants = [ "sops-install-secrets.service" ];
  };

  # OpenThread and VPN-Confinement both set this. Same value, but the option does not merge.
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = lib.mkForce 1;

  # Keep NetworkManager off the namespace bridge it does not own.
  networking.networkmanager.unmanaged = [
    "interface-name:proton-br"
    "interface-name:veth-proton-br"
  ];

  systemd.services.qbittorrent = {
    partOf = [ "proton.service" ];
    vpnConfinement = {
      enable = true;
      vpnNamespace = "proton";
    };
    # NixOS qbittorrent sets RestrictNamespaces, which blocks NetworkNamespacePath.
    serviceConfig.RestrictNamespaces = lib.mkForce false;
  };
}
