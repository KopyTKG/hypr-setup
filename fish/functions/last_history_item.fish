function last_history_item --description 'Last command line (for the !! abbreviation)'
    printf '%s' $history[1]
end
