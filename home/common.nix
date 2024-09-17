{ config, pkgs, nixvim-config, ... }:

{
  imports = [
    ./programs/tmux.nix
    ./programs/dunst
    ./xdg.nix
  ];

  home.file.".config" = {
    source = ../.config;
    recursive = true;
  };

  home.file."wallpaper" = {
    source = ../wallpaper;
    recursive = true;
  };

  home.file.".shell_aliases" = {
    source = ../.shell_aliases;
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  fonts.fontconfig.enable = true;


  catppuccin = {
    flavor = "mocha";
    accent = "pink";
    pointerCursor = {
      enable = true;
      flavor = "mocha";
      accent = "lavender";
    };
  };

  gtk = {
    enable = true;
    catppuccin = {
      enable = true;
    };
  };

  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    #nixvim config
    nixvim-config.packages.${system}.default

    # fonts
    nerdfonts

    # ProtonMail and friends
    protonmail-desktop

    bitwarden

    #cursors
    catppuccin-cursors.mochaLavender

    neofetch

    # archives
    zip
    unzip
    xfce.thunar
    xfce.exo

    xterm

    # utils
    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    bat
    fish
    zoxide
    rofi
    du-dust

    #neovim config dependencies
    gcc
    gnumake
    nodejs_22 #for copilot

    #browsers
    firefox
    chromium

    # Simple image viewer
    imv

    # Video player
    vlc

    # Audio analyzer
    sonic-visualiser

    # misc
    cowsay
    file
    which
    tree

    # nix related
    nix-output-monitor
    nvd
    nixpkgs-fmt

    # productivity
    glow # markdown previewer in terminal
    super-productivity

    btop # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    psmisc # killall/pstree/prtstat/fuser/...
    udiskie
  ];

  programs.git = {
    enable = true;
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --topo-order --date=relative";
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = { };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    shellAliases = {
      cat = "bat";
    };
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
      ls = "eza -a";
    };
  };

  programs.fd = {
    enable = true;
    hidden = true;
  };

  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
