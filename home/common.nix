{ config, pkgs, ... }:

{

  home.file.".config" = {
    source = ../.config;
    recursive = true;
  };

  home.file.".tmux.conf" = {
    source = ../.tmux.conf;
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


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [

    # fonts
    nerdfonts 

    neofetch
    neovim

    # archives
    zip
    unzip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    bat
    fish
    zoxide
    tmux
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

    # productivity
    glow # markdown previewer in terminal

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
  ];

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
    };
  };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
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
    viAlias = true;
    vimAlias = true;
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
