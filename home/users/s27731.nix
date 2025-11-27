{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    ../desktop.nix
    ../programs/hyprland/hyprland.nix
    ../programs/alacritty
    ../programs/graphical
  ];

  home.username = "s27731";
  home.homeDirectory = "/home/s27731";

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings = {
      user.name = "Petter Hoem Sletsjøe";
      user.email = "petter.hoem.sletsjoe@semcon.com";
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    teams-for-linux
    sox # audio file processing
  ];
}
