# Common graphical applications and file management
{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
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
  programs.file-roller.enable = true;

  services.tumbler.enable = true;
  services.flatpak.enable = true;
}
