{ lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Same Lua _args shape as hyprland.nix (hl.env(name, value)).
      # Plain "NAME,value" strings are hyprlang-era and break Lua generation.
      env = lib.mapAttrsToList (name: value: {
        _args = [
          name
          value
        ];
      }) {
        # https://wiki.hyprland.org/Nvidia/
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };
    };
  };
}
