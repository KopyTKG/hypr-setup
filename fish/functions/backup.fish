function backup --description 'Timestamped copy of a file'
    command cp "$argv[1]" "$argv[1].backup-"(date +%Y%m%d-%H%M%S)
end
