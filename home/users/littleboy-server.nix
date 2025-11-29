# Server-specific home configuration for littleboy
{ config, pkgs, ... }:

{
  imports = [
    ../common.nix
    # No desktop environment imports
  ];

  home.username = "petter";
  home.homeDirectory = "/home/petter";

  programs.git.settings = {
    user.name = "petterhs";
    user.email = "39340152+petterhs@users.noreply.github.com";
  };

  # Server-specific packages
  home.packages = with pkgs; [
    # Server monitoring and management tools
    htop
    iotop
    iftop
    nmap
    tcpdump
    # File management
    rsync
    tree
    # Network tools
    curl
    wget
    # System utilities
    pciutils
    usbutils
    psmisc
  ];

  # Server-specific programs
  programs = {
    # Keep essential programs but remove desktop ones
    bat.enable = true;
    fzf.enable = true;
    fd.enable = true;
    # Remove desktop programs like imv, rofi, btop
  };

  # Remove desktop-specific configurations
  # No xresources, no desktop themes, etc.
}
