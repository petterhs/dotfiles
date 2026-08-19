# Public Audiobookshelf access via Cloudflare Tunnel.
# Run scripts/setup-audiobookshelf-public.sh on littleboy to create the tunnel,
# store credentials in sops, and set homelab.audiobookshelfPublic.tunnelId.
{
  config,
  lib,
  ...
}:
let
  cfg = config.homelab.audiobookshelfPublic;
in
{
  options.homelab.audiobookshelfPublic = {
    enable = lib.mkEnableOption "Public Audiobookshelf access via Cloudflare Tunnel";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "audio.hoem.app";
      description = "Public hostname for Audiobookshelf (must match Cloudflare Tunnel DNS route).";
    };

    tunnelId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "00000000-0000-0000-0000-000000000000";
      description = ''
        Cloudflare tunnel UUID from `cloudflared tunnel create`.
        When null, the tunnel service is not started (run the setup script first).
      '';
    };

    backendPort = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Local Audiobookshelf port to proxy through the tunnel.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.tunnelId != null) {
    sops.secrets."cloudflared-audiobookshelf" = {
      key = "cloudflared_audiobookshelf_creds";
      owner = "root";
      mode = "0400";
    };

    services.cloudflared = {
      enable = true;
      tunnels.${cfg.tunnelId} = {
        credentialsFile = config.sops.secrets."cloudflared-audiobookshelf".path;
        default = "http_status:404";
        ingress = {
          "${cfg.domain}" = "http://127.0.0.1:${toString cfg.backendPort}";
        };
      };
    };
  };
}
