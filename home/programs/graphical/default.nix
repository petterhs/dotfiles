{ pkgs, ... }:
{

  home.packages = with pkgs; [
    obs-studio
    obsidian
    # gossip
  ];
}
