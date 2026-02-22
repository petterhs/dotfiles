{ config, lib, ... }:
{
  options.homelab.labDomain = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "lab.example.com";
    description = "Base domain for homelab (e.g. lab.example.com). DNS A record *.lab.example.com should point to this host.";
  };
}
