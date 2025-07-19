# Fish shell configuration - Simple and clean

# Remove greeting
set -g fish_greeting

# Environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim

# Modern tool aliases
alias ls='eza --color=auto --group-directories-first'
alias ll='eza -la --color=auto --group-directories-first'
alias la='eza -a --color=auto --group-directories-first'
alias lt='eza --tree --color=auto'

alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'
alias rm='trash'
alias vim='nvim'
alias vi='nvim'

# Convenient aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# System aliases
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gs='git status'

# Yazi integration
function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if test -f "$tmp"
        set cwd (cat "$tmp")
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd "$cwd"
        end
    end
    rm -f "$tmp"
end

# Initialize tools
if command -v zoxide >/dev/null
    zoxide init fish | source
end

if command -v starship >/dev/null
    starship init fish | source
end
