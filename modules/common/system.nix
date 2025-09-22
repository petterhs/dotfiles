# Common system configuration
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

  # Common environment packages (system-level only)
  # User packages are managed by home-manager in home/common.nix
  environment.systemPackages = with pkgs; [
    # System-level packages that need to be available system-wide
    libnotify
    pavucontrol
    playerctl
    pulsemixer
    avahi
    # File chooser portal support
    gtk3
    gtk4
    libadwaita
    # Additional portal support packages
    xdg-desktop-portal-gtk
    xdg-utils
  ];

  # Common environment variables
  environment.variables = {
    EDITOR = "nvim";
    XCURSOR_THEME = "Catppuccin-Mocha-Lavender-Cursors";
    XCURSOR_SIZE = "32";
  };

  # Common programs
  programs.fish.enable = true;

  # System state version
  system.stateVersion = "23.05";
}
