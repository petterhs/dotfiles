{ config, pkgs, ... }:

{
  imports = [
    ./programs/tmux.nix
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

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" ];
        variant = "mocha";
      };
    };
  };

  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # fonts
    nerdfonts

    #cursors
    catppuccin-cursors.mochaLavender

    neofetch
    neovim

    # archives
    zip
    unzip
    xfce.thunar

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
    nodejs_21 #for copilot

    #browsers
    firefox

    # misc
    cowsay
    file
    which
    tree

    # nix related
    nix-output-monitor
    nvd

    # productivity
    glow # markdown previewer in terminal
    super-productivity

    btop  # replacement of htop/nmon
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
    settings = {
    };
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

  programs.neovim = {
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = [
      pkgs.tailwindcss-language-server
      pkgs.lua-language-server
    ];
  };

  # This value determines the home Manager release that your
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
