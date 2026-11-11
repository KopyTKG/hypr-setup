function last_history_arg --description 'Last argument of the last command (for the !$ abbreviation)'
    set -l words (string split -n ' ' -- $history[1])
    printf '%s' $words[-1]
end
