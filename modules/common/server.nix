# Common server configuration (headless)
{ config, pkgs, ... }:
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/Oslo";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "no";

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Hardware
  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  services.blueman.enable = true;

  # Common services
  services.openssh.enable = true;
  services.tailscale.enable = true;
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Avahi (mDNS) for .local resolution and mDNS service discovery
  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  # Default user shell
  users.defaultUserShell = pkgs.fish;

  # Server environment packages (minimal)
  environment.systemPackages = with pkgs; [
    # Basic system tools
    vim
    wget
    git
    fish
    # System monitoring
    htop
    iotop
    iftop
    # Network tools
    nmap
    tcpdump
    # File management
    rsync
    tree
    # Avahi client utilities for avahi-browse
    avahi
    # System utilities
    pciutils # lspci
    usbutils # lsusb
    psmisc # killall/pstree/prtstat/fuser/...
  ];

  # Common environment variables
  environment.variables = {
    EDITOR = "vim";
  };

  # Common programs
  programs.fish.enable = true;

  # System state version
  system.stateVersion = "23.05";
}
