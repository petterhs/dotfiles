{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
    ];
  };

  programs.xfconf.enable = true;
  programs.file-roller.enable = true;

  services.tumbler.enable = true;
}
