{ config, ... }:
let
  base =
    if config.homelab.labDomain != null then config.homelab.labDomain else config.networking.hostName;
in
{
  services.mealie = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9000;
    settings = {
      BASE_URL = "http://mealie.${base}";
      ALLOW_SIGNUP = "true";
    };
  };

  networking.firewall.allowedTCPPorts = [ 9000 ];
}
