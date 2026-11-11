function trestore --description 'Pick trashed files with fzf and restore them (Tab = multi-select)'
    type -q fzf; or begin
        echo "trestore: fzf not installed" >&2
        return 1
    end

    # trash-restore numbers its candidates; with no stdin it just prints the list.
    # The sort order must match between listing and restoring, so pin it.
    set -l items (trash-restore --sort=date / </dev/null 2>/dev/null | string match -r '^\s*\d+ .*' | string trim)
    if not set -q items[1]
        echo "trash is empty"
        return 0
    end

    set -l picked (printf '%s\n' $items | fzf --multi --prompt='restore> ' \
        --header 'Tab: select  Enter: restore  Esc: cancel' \
        --with-nth 2.. --tac)
    or return

    set -l idx (string replace -r '\s.*' '' -- $picked)
    printf '%s\n' (string join , $idx) | trash-restore --sort=date / >/dev/null
    and echo "restored "(count $idx)" item(s)"
end
