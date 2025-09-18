# no-kon-lx-016 specific configuration
# Most common configuration is now handled by modules in ./modules/common/
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Host-specific overrides and additions
  # (Most configuration is now in common modules)
}