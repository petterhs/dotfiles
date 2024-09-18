{ pkgs, nixvim-config, ... }:

{
  imports = [
    ./programs/tmux.nix
    ./programs/dunst
    ./xdg.nix
    ./theming.nix
  ];

  home.file."wallpaper" = {
    source = ../wallpaper;
    recursive = true;
  };

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
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
    zoxide
    du-dust

    #neovim config dependencies
    gcc
    gnumake
    nodejs_22 # for copilot

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
    nixfmt-rfc-style

    # productivity
    glow # markdown previewer in terminal
    super-productivity

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

  # Themed with catppuccin via catppuccin/nix 
  programs = {
    bat.enable = true;
    fzf.enable = true;
    imv.enable = true;
    rofi.enable = true;
    # btop.enable = true;
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # custom settings
    settings = {
      aws.disabled = true;
    };
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
    interactiveShellInit = ''
      set fish_greeting # empty string to disable the welcome message
    '';
    shellAliases = {
      cat = "bat";
      ls = "eza -a";
    };
  };

  programs.fd = {
    enable = true;
    hidden = true;
  };

  programs.spotify-player = {
    enable = true;
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
