function fzf_complete --description 'Tab completion through fzf when there is more than one candidate'
    # Fish's own completion engine (`complete -C`) supplies the candidates, so
    # this works for every command fish knows: cd, cat, ssh, git, systemctl...
    set -l line (commandline -cp)
    set -l token (commandline -ct)
    set -l candidates (complete -C -- $line)

    # 0 or 1 candidate: let fish handle it natively (inserts / does nothing)
    if test (count $candidates) -le 1
        commandline -f complete
        return
    end

    set -l picked (printf '%s\n' $candidates | fzf \
        --delimiter \t --with-nth 1,2 --nth 1 --tabstop 24 \
        --query (string unescape -- $token) \
        --select-1 --exit-0 \
        --bind 'tab:down,btab:up' \
        --preview-window 'right:50%:wrap' \
        --preview 'set -l p (string unescape -- {1}); test -d "$p"; and ls -1A --color=always "$p"; or test -f "$p"; and head -c 4000 "$p"; or echo {2}')
    # fzf exits non-zero on Esc/Ctrl-C (status must come from fzf, not a later pipe stage)
    or begin
        commandline -f repaint
        return
    end
    set -l choice (string replace -r '\t.*' '' -- $picked[1])

    # Escape for the shell, but keep a leading ~/ or $var expandable
    if string match -q -- '~/*' $choice
        set choice '~/'(string escape --style=script -- (string sub -s 3 -- $choice))
    else if not string match -q -- '$*' $choice
        set choice (string escape --style=script -- $choice)
    end

    # Directories and key= candidates continue; everything else gets a space
    if not string match -qr -- '[/=]$' $choice
        set choice "$choice "
    end

    commandline -t -- $choice
    commandline -f repaint
end
