{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    networkmanagerapplet
    swww
    waybar
    wofi
    # hyprshot
    wl-clipboard
    wlogout
    hyprlock
    swayidle
    grim
    hyprpicker
    hyprpaper
    hyprpolkitagent

    slurp

    libsForQt5.qt5ct
    qt6Packages.qt6ct

    hyprland-per-window-layout

    libva-utils
    pavucontrol
    pulsemixer
    alsa-utils
    mpd
    mpc
    obs-studio-plugins.wlrobs

    pyprland
  ];

  services.hyprpaper = {
    enable = true;
    settings = {

      preload = [ "~/wallpaper/nix-black-4k.png" ];
      wallpaper = [
        ",~/wallpaper/nix-black-4k.png"
      ];

    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "BROWSER,xdg-open"
        "EDITOR,nvim"
        "TERMINAL,alacritty"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        "GTK_USE_PORTAL,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "QT_QPA_PLATFORMTHEME,qt5ct" # Use qt5ct for QT theming
      ];
    };
    extraConfig = builtins.readFile ./conf/hyprland.conf;
    systemd.enable = true;
    package = null; # This is set to null because we get it from the nix module
    portalPackage = null; # This is set to null because we get it from the nix module
  };

  # XDG portal configuration is handled at the system level in hosts/no-kon-lx-016/configuration.nix

  # hyprland configs, based on https://github.com/notwidow/hyprland
  xdg.configFile = {
    "hypr/scripts" = {
      source = ./conf/scripts;
      recursive = true;
    };
    "hypr/waybar" = {
      source = ./conf/waybar;
      recursive = true;
    };
    "hypr/wlogout" = {
      source = ./conf/wlogout;
      recursive = true;
    };
    "hypr/wofi" = {
      source = ./conf/wofi;
      recursive = true;
    };
    "hypr/hyprlock.conf" = {
      source = ./conf/hyprlock/hyprlock.conf;
    };
    "hypr/mocha.conf" = {
      source = ./conf/mocha.conf;
    };
    # music player - mpd
    "mpd" = {
      source = ./conf/mpd;
      recursive = true;
    };
    # pyprland configuration
    "hypr/pyprland.toml" = {
      source = ./conf/pyprland.toml;
    };
  };
}
