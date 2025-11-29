{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../programs/hyprland/hyprland.nix
    ../programs/alacritty
  ];

  home.username = "petter";
  home.homeDirectory = "/home/petter";

  programs.git.settings = {
    user.name = "petterhs";
    user.email = "39340152+petterhs@users.noreply.github.com";
  };

  # Packages that should be installed to the user profile.
  home.packages =
    with pkgs;
    [
    ];
}
