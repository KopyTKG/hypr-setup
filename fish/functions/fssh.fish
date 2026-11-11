function fssh --description 'Pick an SSH host with fzf and connect (extra args are passed to ssh)'
    type -q fzf; or begin
        echo "fssh: fzf not installed" >&2
        return 1
    end

    # Hosts from ~/.ssh/config and every included file (your config uses
    # `Include ~/.ssh/*/config`), minus wildcard patterns; plus plain
    # (non-hashed) entries from known_hosts.
    set -l hosts (begin
        cat ~/.ssh/config ~/.ssh/*/config 2>/dev/null \
            | string match -rig '^\s*Host\s+(.+)$' \
            | string split -n ' ' \
            | string match -rv '[*?!]'
        cat ~/.ssh/known_hosts 2>/dev/null \
            | string match -rv '^[|#@]' \
            | string replace -r '[ ,].*' '' \
            | string replace -r '^\[(.+)\]:\d+$' '$1'
    end | sort -u)

    set -q hosts[1]; or begin
        echo "fssh: no hosts found" >&2
        return 1
    end

    set -l host (printf '%s\n' $hosts | fzf --prompt='ssh> ' \
        --preview 'ssh -G {} 2>/dev/null | grep -iE "^(hostname|user|port|identityfile) "' \
        --preview-window=right:40%)
    or return

    ssh $host $argv
end
