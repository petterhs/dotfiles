{ pkgs, ... }:
let
in
{
  home.packages = with pkgs; [
    lsof
    sesh
  ];

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 100000;
    baseIndex = 1;
    keyMode = "vi";
    prefix = "C-Space";
    newSession = true;
    clock24 = true;
    plugins = with pkgs;
      [
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.tmux-thumbs
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.yank
        tmuxPlugins.sensible
        # must be before continuum edits right status bar
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = '' 
            set -g @catppuccin_flavour 'mocha'
            set -g @catppuccin_window_tabs_enabled on
            set -g @catppuccin_date_time "%H:%M"
          '';
        }
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            resurrect_dir="$HOME/.tmux/resurrect"
            set -g @resurrect-dir $resurrect_dir
          '';
        }
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '10'
          '';
        }

      ];
    extraConfig = ''
      set -ag terminal-overrides ",alacritty:RGB"

      # Change splits to match nvim and easier to remember
      # Open new split at cwd of current split
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # v in copy mode starts making selection
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Escape turns on copy mode
      bind Escape copy-mode

      # make Prefix p paste the buffer.
      unbind p
      bind p paste-buffer

      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
      set -g detach-on-destroy off  # don't exit from tmux when closing a session

      # Bind Keys
      bind-key -T prefix C-g split-window \
        "$SHELL --login -i -c 'navi --print | head -c -1 | tmux load-buffer -b tmp - ; tmux paste-buffer -p -t {last} -b tmp -d'"
      bind-key -T prefix C-l switch -t notes
      bind-key -T prefix C-d switch -t dotfiles
      bind-key -T prefix C-e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter

      unbind t
      bind-key "t" run-shell "sesh connect \"$(
        sesh list | fzf-tmux -p 55%,60% \
          --no-sort --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
      )\""
    '';
  };
}

