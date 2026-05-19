# ===================================================================
# FZF CONFIGURATION
# ===================================================================
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # FZF package search for yay/pacman removal
    function _fzf_complete_yay_remove() {
        _fzf_complete --prompt="Packages> " --multi --reverse -- "$@" < <(
            pacman -Qq
        )
    }

    # Bind it to yay -R and pacman -R
    complete -F _fzf_complete_yay_remove -o default -o bashdefault yay -R
    complete -F _fzf_complete_yay_remove -o default -o bashdefault pacman -R
fi

# ===================================================================
# PACKAGE COMPLETION
# ===================================================================
_yay_remove_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If we're after -R or removal flags, complete with installed packages
    if [[ "$prev" == "-R"* ]] || [[ "${COMP_WORDS[*]}" == *" -R"* ]] || [[ "${COMP_WORDS[*]}" == *" -Rs"* ]] || [[ "${COMP_WORDS[*]}" == *" -Rns"* ]]; then
        COMPREPLY=( $(compgen -W "$(pacman -Qq 2>/dev/null)" -- "$cur") )
        return 0
    fi

    # For search/install operations, complete with repo packages
    if [[ "$prev" == "-S"* ]] || [[ "${COMP_WORDS[*]}" == *" -S"* ]]; then
        COMPREPLY=( $(compgen -W "$(pacman -Slq 2>/dev/null)" -- "$cur") )
        return 0
    fi

    # Otherwise show common options
    opts="-S -R -Rs -Rns -Ss -Si -Q -Qi -Syu -Syyu"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}

complete -F _yay_remove_completion yay
complete -F _yay_remove_completion pacman

# ===================================================================
# COMMAND SEARCH
# ===================================================================
function cmdsearch() {
    if [ -z "$1" ]; then
        echo "Usage: cmdsearch <pattern>"
        return 1
    fi
    compgen -c | grep -i "$1" | sort -u | column
}

function pkgsearch() {
    if [ -z "$1" ]; then
        pacman -Qq | column
    else
        pacman -Qq | grep -i "$1" | column
    fi
}

# ===================================================================
# BAT CONFIGURATION
# ===================================================================
if command -v bat &> /dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias bathelp='bat --plain --language=help'
    function help() {
        "$@" --help 2>&1 | bathelp
    }
fi

# ===================================================================
# EZA CONFIGURATION
# ===================================================================
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -lah --icons --git'
    alias la='eza -a --icons'
    alias lt='eza -lah --icons --git --sort=modified'
    alias tree='eza --tree --icons'
fi
