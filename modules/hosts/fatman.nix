# fatman specific configuration
{ config, pkgs, inputs, ... }:
{
  # Hostname
  networking.hostName = "fatman";

  # Build aarch64 (travis) closures here instead of on the Pi
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # LUKS encryption
  boot.initrd.luks.devices."luks-30163cea-ed7e-4ef0-abb7-d860a687d7af".device =
    "/dev/disk/by-uuid/30163cea-ed7e-4ef0-abb7-d860a687d7af";

  # NVIDIA configuration
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;

  # Queue worker. Reuse the encrypted queue environment; it must contain
  # QUEUE_TOKEN, as configured for littleboy.
  sops.secrets."family-recipe-importer-worker.env" = {
    key = "family_recipe_importer_env";
    path = "/run/secrets/family-recipe-importer-worker.env";
    owner = "petter";
    group = "users";
    mode = "0400";
  };

  systemd.services.recipe-video-worker = {
    description = "Family recipe video import worker";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "petter";
      Group = "users";
      EnvironmentFile = "/run/secrets/family-recipe-importer-worker.env";
      ExecStart = "${inputs.family-recipe-importer.packages.${pkgs.system}.default}/bin/recipe-video-worker --queue http://littleboy:8088 --worker-id fatman";
      Restart = "on-failure";
      RestartSec = 30;
      TimeoutStopSec = 30;
    };
  };

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
