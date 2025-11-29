{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../desktop.nix
    ../programs/hyprland/hyprland.nix
    ../programs/hyprland/hyprland-nvidia.nix
    ../programs/alacritty
    ../programs/graphical
  ];

  home.username = "petter";
  home.homeDirectory = "/home/petter";

  # basic configuration of git, please change to your own
  programs.git.settings = {
    user.name = "petterhs";
    user.email = "39340152+petterhs@users.noreply.github.com";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    sparrow
  ];
}
