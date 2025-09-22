{ pkgs, ... }:

{
  imports = [
    ./programs/dunst
    ./xdg.nix
    ./theming.nix
  ];

  home.file."wallpaper" = {
    source = ../wallpaper;
    recursive = true;
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Desktop-specific packages
  home.packages = with pkgs; [
    # Desktop applications
    alacritty
    protonmail-desktop
    bitwarden
    firefox
    chromium
    imv
    vlc
    super-productivity

    # Desktop file managers and utilities
    xfce.thunar
    xfce.exo
    xterm
    udiskie

    # Desktop fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.inconsolata

    # Desktop programs
    rofi
    spotify-player
  ];

  # Desktop-specific programs
  programs = {
    imv.enable = true;
    rofi.enable = true;
    spotify-player.enable = true;
  };
}
