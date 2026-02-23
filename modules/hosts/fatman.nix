# fatman specific configuration
{ config, pkgs, ... }:
{
  # Hostname
  networking.hostName = "fatman";

  # LUKS encryption
  boot.initrd.luks.devices."luks-30163cea-ed7e-4ef0-abb7-d860a687d7af".device =
    "/dev/disk/by-uuid/30163cea-ed7e-4ef0-abb7-d860a687d7af";

  # NVIDIA configuration
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;

  # Users
  users.users.petter = {
    isNormalUser = true;
    description = "petter";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      firefox
    ];
  };
  users.users.petter-work = {
    isNormalUser = true;
    description = "petter-work";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  # XDG Portal configuration (simpler for fatman)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Garbage collection (more aggressive for desktop)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root petter petter-work
  '';

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "petter";
    group = "users";
    dataDir = "/home/petter/.local/share/syncthing";
    configDir = "/home/petter/.config/syncthing";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
