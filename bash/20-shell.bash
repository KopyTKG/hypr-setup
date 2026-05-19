# ===================================================================
# SHELL OPTIONS
# ===================================================================
shopt -s checkwinsize
shopt -s cdspell
shopt -s autocd
shopt -s dirspell
shopt -s globstar
shopt -s nocaseglob

# ===================================================================
# ENHANCED TAB COMPLETION
# ===================================================================
# Show all completions immediately
bind 'set show-all-if-ambiguous on'

# Case-insensitive tab completion
bind 'set completion-ignore-case on'

# Treat hyphens and underscores as equivalent
bind 'set completion-map-case on'

# Display matches in columns
bind 'set completion-display-width 0'

# Show common prefix before cycling through completions
bind 'set menu-complete-display-prefix on'

# Cycle through completions with Tab (forward) and Shift+Tab (backward)
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'

# Add a trailing slash to completed directory symlinks
bind 'set mark-symlinked-directories on'

# Color completions
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-directories on'
bind 'set colored-completion-prefix on'

# ===================================================================
# SUDO COMPLETION
# ===================================================================
_sudo_completion() {
    local cur prev words cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD

    # If we're on the first word after sudo, complete commands
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -c -- "$cur") )
        return 0
    fi

    # Otherwise, try to find the actual command and use its completion
    local actual_cmd="${words[1]}"

    # Check if there's a completion function for the command
    local comp_func
    comp_func=$(complete -p "$actual_cmd" 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')

    if [[ -n "$comp_func" ]]; then
        # Temporarily adjust COMP_* variables to look like we're completing the actual command
        local old_words=("${COMP_WORDS[@]}")
        local old_cword=$COMP_CWORD

        COMP_WORDS=("${words[@]:1}")
        COMP_CWORD=$((cword - 1))

        # Call the completion function
        $comp_func

        # Restore original COMP_* variables
        COMP_WORDS=("${old_words[@]}")
        COMP_CWORD=$old_cword

        return 0
    fi

    # Fallback: just complete files
    COMPREPLY=( $(compgen -f -- "$cur") )
}

complete -F _sudo_completion sudo

# ===================================================================
# SYSTEMCTL COMPLETION
# ===================================================================
_systemctl_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Skip sudo if present
    local offset=0
    if [[ "${COMP_WORDS[0]}" == "sudo" ]]; then
        offset=1
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        if [[ $COMP_CWORD -le 1 ]]; then
            return 0
        fi
    fi

    local commands="start stop restart reload status enable disable is-active is-enabled mask unmask list-units list-unit-files"
    local real_prev="${COMP_WORDS[$((COMP_CWORD-1))]}"

    case "$real_prev" in
        systemctl|sc)
            COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
            ;;
        start|stop|restart|reload|status|enable|disable|is-active|is-enabled|mask|unmask)
            COMPREPLY=( $(compgen -W "$(systemctl list-unit-files --no-legend --no-pager --type=service 2>/dev/null | awk '{print $1}' | sed 's/\.service$//')" -- "$cur") )
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _systemctl_completion systemctl
complete -F _systemctl_completion sc
