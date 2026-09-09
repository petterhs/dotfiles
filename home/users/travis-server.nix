# Server-specific home configuration for travis (Raspberry Pi)
{ pkgs, ... }:
{
  imports = [
    ../common.nix
  ];

  home.username = "petter";
  home.homeDirectory = "/home/petter";

  home.packages = with pkgs; [
    git
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "petterhs";
      user.email = "39340152+petterhs@users.noreply.github.com";
    };
  };

  programs = {
    bat.enable = true;
    fzf.enable = true;
    fd.enable = true;
  };
}
