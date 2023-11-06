if status is-interactive
    # Commands to run in interactive sessions can go here
end

if type -q exa
    alias l="exa -l"
    alias ll="exa --icons --long --header --group --created --modified --git -a"
    alias ls="exa -l"
end

set -x GOPATH $HOME/go

fish_add_path $GOPATH/bin

fish_config theme choose "Catppuccin Mocha" 

# Load aliases
source $HOME/.shell_aliases

zoxide init fish | source
starship init fish | source
