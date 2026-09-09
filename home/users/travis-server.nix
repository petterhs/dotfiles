# Server-specific home configuration for travis (Raspberry Pi)
{ ... }:
{
  imports = [
    ../common.nix
  ];

  home.username = "petter";
  home.homeDirectory = "/home/petter";

  programs.git.settings = {
    user.name = "petterhs";
    user.email = "39340152+petterhs@users.noreply.github.com";
  };

  home.packages = [ ];

  programs = {
    bat.enable = true;
    fzf.enable = true;
    fd.enable = true;
  };
}
