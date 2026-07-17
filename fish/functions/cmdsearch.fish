function cmdsearch --description 'Search available commands (functions, builtins, PATH)'
    if test -z "$argv[1]"
        echo "Usage: cmdsearch <pattern>"
        return 1
    end
    begin
        functions --names
        builtin --names
        for dir in $PATH
            test -d $dir; and command ls $dir
        end
    end | grep -i "$argv[1]" | sort -u | column
end
