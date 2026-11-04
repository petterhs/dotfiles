# no-kon-lx-016 specific configuration
{ config, pkgs, inputs, ... }:
{
  # Hostname
  networking.hostName = "no-kon-lx-016";

  # Allow unsupported system
  nixpkgs.config.allowUnsupportedSystem = true;

  # Needed for work SSTP VPN until networkmanager-sstp is patched (CVE-2026-91838:
  # local privilege escalation via unsanitized VPN profile fields → root pppd).
  # Only meaningful if an untrusted local user can create/edit VPN profiles.
  nixpkgs.config.permittedInsecurePackages = [
    "NetworkManager-sstp-gnome-1.3.2"
  ];

  # NetworkManager with SSTP plugin
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-sstp ];
  };

  # Queue worker. Reuse the encrypted queue environment; it must contain
  # QUEUE_TOKEN, as configured for littleboy.
  sops.secrets."family-recipe-importer-worker.env" = {
    key = "family_recipe_importer_env";
    path = "/run/secrets/family-recipe-importer-worker.env";
    owner = "s27731";
    group = "users";
    mode = "0400";
  };

  systemd.services.recipe-video-worker = {
    description = "Family recipe video import worker";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      User = "s27731";
      Group = "users";
      EnvironmentFile = "/run/secrets/family-recipe-importer-worker.env";
      ExecStart = "${inputs.family-recipe-importer.packages.${pkgs.system}.default}/bin/recipe-video-worker --queue http://littleboy:8088 --worker-id no-kon-lx-016";
      Restart = "on-failure";
      RestartSec = 30;
      TimeoutStopSec = 30;
    };
  };

  # User configuration
  users.users.s27731 = {
    isNormalUser = true;
    description = "petter";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "docker"
      "wireshark"
      "adbusers"
    ];
    packages = with pkgs; [
      firefox
    ];
  };

  # XDG Portal GTK service configuration
  systemd.user.services.xdg-desktop-portal-gtk = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  # Nix trusted users
  nix.extraOptions = ''
    trusted-users = root s27731
  '';

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "s27731";
    group = "users";
    dataDir = "/home/s27731/.local/share/syncthing";
    configDir = "/home/s27731/.config/syncthing";
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];
}
