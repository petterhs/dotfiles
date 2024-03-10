{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
  ];


  home.username = "petter-work";
  home.homeDirectory = "/home/petter-work";


  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Petter Hoem Sletsjøe";
    userEmail = "petter.hoem.sletsjoe@semcon.com";
  };


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    teams-for-linux
    # citrix_workspace
  ];
}
