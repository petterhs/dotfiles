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

    slurp

    libsForQt5.qt5ct
    qt6ct

    hyprland-per-window-layout

    libva-utils
    pavucontrol
    pulsemixer
    alsa-utils
    ncmpcpp
    mpd
    mpc-cli
    obs-studio-plugins.wlrobs
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      env = [
        "BROWSER,firefox"
        "EDITOR,nvim"
        "TERMINAL,alacritty"
        "NIXOS_OZONE_WL,1" # for any ozone-based browser & electron apps to run on wayland
        "MOZ_ENABLE_WAYLAND,1" # for firefox to run on wayland
        "MOZ_WEBRENDER,1"
        # misc
        "_JAVA_AWT_WM_NONREPARENTING,1"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "QT_QPA_PLATFORM,wayland"
        "SDL_VIDEODRIVER,wayland"
        "GDK_BACKEND,wayland"
      ];
    };
    extraConfig = builtins.readFile ./conf/hyprland.conf;
    systemd.enable = true;
  };

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
  };
}
