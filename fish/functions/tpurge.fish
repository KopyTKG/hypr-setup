function tpurge --description 'Pick trashed files with fzf and delete them permanently (Tab = multi-select)'
    type -q fzf; or begin
        echo "tpurge: fzf not installed" >&2
        return 1
    end

    set -l items (trash-list)
    if not set -q items[1]
        echo "trash is empty"
        return 0
    end

    set -l picked (printf '%s\n' $items | fzf --multi --prompt='purge> ' \
        --header 'Tab: select  Enter: DELETE FOREVER  Esc: cancel' \
        --with-nth 3.. --tac)
    or return

    # trash-list prints "<date> <time> <original path>"
    set -l paths (string replace -r '^\S+\s+\S+\s+' '' -- $picked)

    read -l -P "Permanently delete "(count $paths)" item(s)? [y/N] " answer
    string match -qi y -- $answer; or return 1

    for p in $paths
        # trash-rm takes an fnmatch pattern; neutralise glob characters in the path
        trash-rm (string replace -ra '([*?\[])' '[$1]' -- $p)
    end
end
