function y --description 'yazi that cd\'s the shell to where you quit'
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    read -z cwd <"$tmp"
    set cwd (string trim -r -c \n -- $cwd)
    if test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    # `command`: plain rm is the trash-backed wrapper and would trash the temp file
    command rm -f -- "$tmp"
end
