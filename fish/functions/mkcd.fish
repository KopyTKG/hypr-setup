function mkcd --description 'mkdir -p then cd into it'
    command mkdir -p "$argv[1]"; and cd "$argv[1]"
end
