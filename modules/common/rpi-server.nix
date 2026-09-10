# Lean headless config for Raspberry Pi (no EFI systemd-boot / desktop services)
{ lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Oslo";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "no";

  services.openssh.enable = true;
  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  users.defaultUserShell = pkgs.fish;

  # flashrom unit tests fail on aarch64 (nixpkgs#558302); skip if still pulled in
  nixpkgs.overlays = [
    (final: prev: {
      flashrom = prev.flashrom.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fish
    htop
    iotop
    iftop
    nmap
    tcpdump
    rsync
    tree
    avahi
    pciutils
    usbutils
    psmisc
    libraspberrypi
    # raspberrypi-eeprom depends on flashrom; omit on this lean Hermes image
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  programs.fish.enable = true;

  # Avoid building ZFS on aarch64 Pi images
  boot.supportedFilesystems.zfs = lib.mkForce false;

  system.stateVersion = "24.11";
}
