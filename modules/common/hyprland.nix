# Common Hyprland configuration
{ config, pkgs, inputs, ... }:
let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
in
{
  # Hyprland program configuration
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    systemd.setPath.enable = true;
  };

  # XDG Portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    config.hyprland = {
      default = [
        "hyprland"
        "gtk"
      ];
      "org.freedesktop.impl.portal.FileChooser" = "kde";
      "org.freedesktop.impl.portal.Print" = "kde";
    };
  };

  # Greetd configuration
  services = {
    xserver.enable = false; # disable xorg server
    greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "greeter";
          command = "${tuigreet} --time --remember --cmd Hyprland";
        };
      };
    };
  };

  services.dbus.enable = true;
  security.polkit.enable = true;

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Fix for NetworkManager
  systemd.services.NetworkManager-wait-online = {
    serviceConfig = {
      ExecStart = [
        ""
        "${pkgs.networkmanager}/bin/nm-online -q"
      ];
    };
  };

  # Fix for swaylock
  security.pam.services.swaylock = { };

  # Common environment session variables
  environment.sessionVariables = {
    TERM = "alacritty";
    NIXOS_OZONE_WL = "1";
  };
}
