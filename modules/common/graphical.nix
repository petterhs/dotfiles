# Common graphical applications and file management
{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
    ];
  };

  programs = {
    steam = {
      enable = true;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  programs.xfconf.enable = true;

  services.tumbler.enable = true;
  services.flatpak.enable = true;
}
