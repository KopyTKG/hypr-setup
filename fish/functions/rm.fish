function rm --description 'rm that moves to the trash (trash-cli). Real delete: `command rm` or `rmperm`'
    # No trash-cli → behave like the old safety-net rm
    if not type -q trash-put
        command rm -I --preserve-root $argv
        return
    end

    # Throwaway dirs that are pointless (and huge) to keep in the trash.
    # Override with e.g.  set -U RM_NO_TRASH node_modules dist
    set -q RM_NO_TRASH; or set -l RM_NO_TRASH node_modules __pycache__ .pytest_cache

    set -l recursive 0
    set -l force 0
    set -l verbose 0
    set -l dirs 0
    set -l files
    set -l opts_done 0

    for a in $argv
        if test $opts_done = 1
            set -a files $a
            continue
        end
        switch $a
            case '--'
                set opts_done 1
            case --recursive
                set recursive 1
            case --force
                set force 1
            case --verbose
                set verbose 1
            case --dir
                set dirs 1
            case --interactive --interactive='*' --one-file-system --preserve-root --no-preserve-root
                # accepted and ignored: trashing is already reversible
            case '--*'
                echo "rm: option '$a' isn't handled in trash mode — use: command rm $argv" >&2
                return 2
            case '-'
                set -a files $a
            case '-*'
                for c in (string split '' -- (string sub -s 2 -- $a))
                    switch $c
                        case r R
                            set recursive 1
                        case f
                            set force 1
                        case v
                            set verbose 1
                        case d
                            set dirs 1
                        case i I
                            # ignored: trash is the safety net
                        case '*'
                            echo "rm: option '-$c' isn't handled in trash mode — use: command rm $argv" >&2
                            return 2
                    end
                end
            case '*'
                set -a files $a
        end
    end

    if not set -q files[1]
        test $force = 1; and return 0
        echo "rm: missing operand" >&2
        return 1
    end

    set -l rc 0
    set -l totrash
    for f in $files
        if not test -e "$f"; and not test -L "$f"
            if test $force = 0
                echo "rm: cannot remove '$f': No such file or directory" >&2
                set rc 1
            end
            continue
        end
        if test -d "$f"; and not test -L "$f"; and test $recursive = 0; and test $dirs = 0
            echo "rm: cannot remove '$f': Is a directory" >&2
            set rc 1
            continue
        end
        if test $recursive = 1; and contains -- (path basename -- $f) $RM_NO_TRASH
            command rm -rf --preserve-root (test $verbose = 1; and echo -v) -- $f; or set rc 1
            continue
        end
        set -a totrash $f
    end

    if set -q totrash[1]
        if test $verbose = 1
            trash-put -v -- $totrash; or set rc 1
        else
            trash-put -- $totrash; or set rc 1
            set_color brblack >&2
            echo "→ "(count $totrash)" item(s) in trash  (tre = restore, rmperm = real delete)" >&2
            set_color normal >&2
        end
    end
    return $rc
end
