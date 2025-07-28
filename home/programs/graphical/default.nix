{ pkgs, ... }:
{

  home.packages = with pkgs; [
    obs-studio
    obsidian
    gossip

    code-cursor
    popsicle
    rustdesk
  ];
}
