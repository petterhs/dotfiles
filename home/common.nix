{ pkgs, ... }:

{
  imports = [
    ./programs/tmux.nix
  ];

  # Common packages for both desktop and server
  home.packages = with pkgs; [
    # Basic system tools
    vim
    wget
    neofetch

    # Archives
    zip
    unzip

    # Terminal utilities
    ripgrep # recursively searches directories for a regex pattern
    eza # A modern replacement for 'ls'
    du-dust
    yazi

    # Development tools
    gcc
    gnumake
    nodejs_22 # for copilot
    protobuf
    gdb

    # System monitoring
    iotop # io monitoring
    iftop # network monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    psmisc # killall/pstree/prtstat/fuser/...
    btop

    # Nix related
    nix-output-monitor
    nvd
    nixpkgs-fmt
    nixfmt-rfc-style
    devenv

    # Productivity
    glow # markdown previewer in terminal

    # Misc
    cowsay
    file
    which
    tree
  ];

  programs.git = {
    enable = true;
    difftastic = {
      enable = true;
    };

    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --topo-order --date=relative";
    };
  };

  # Common programs (no theming for server)
  programs = {
    bat.enable = true;
    fzf.enable = true;
    btop.enable = true;
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
      gs = "git status";
      cd = "z";
    };
  };

  programs.fd = {
    enable = true;
    hidden = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
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
