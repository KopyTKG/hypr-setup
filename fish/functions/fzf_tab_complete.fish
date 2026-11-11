function fzf_tab_complete --description 'Tab completion through fzf: fish completions, or a recursive search for cd and `**`'
    # Two sources of candidates:
    #
    #  1. Deep search (fd, streamed into fzf) when
    #       - the command is cd/pushd: Tab searches every directory below the
    #         one you typed (or `.`), so a fragment of a deep name is enough;
    #       - the token contains `**`, bash-style, for any command:
    #           vim src/**<Tab>      files and directories under src/
    #           cd ~/Projects/**<Tab> directories under ~/Projects/
    #     Tunables (set -U):
    #       FZF_COMPLETE_EXCLUDE    names to skip (default: .git node_modules .cache
    #                               __pycache__ .npm .cargo .gradle .m2 .venv go/pkg)
    #       FZF_COMPLETE_MAX_DEPTH  how deep to look (default: unlimited)
    #       FZF_COMPLETE_FOLLOW=1   follow symlinks (off by default: a Wine prefix's
    #                               z: -> / makes that scan the whole filesystem)
    #     ~ scans in about half a second.
    #
    #  2. Otherwise fish's own completion engine (`complete -C`), which works for
    #     every command fish knows (git, ssh, systemctl, ...) but only ever lists
    #     one directory level.
    set -l line (commandline -cp)
    set -l token (commandline -ct)
    set -l tok (string unescape -- $token)
    set -l words (commandline -opc)
    set -l cmd $words[1]

    set -l dirs_only 0
    contains -- "$cmd" cd pushd; and set dirs_only 1

    set -l deep 0
    set -l root_typed ''
    set -l query ''
    if string match -q -- '*\*\**' $tok
        set deep 1
        set -l parts (string split -m1 -- '**' $tok)
        set root_typed $parts[1]
        set query "$parts[2]"
    else if test $dirs_only = 1; and test (count $words) -eq 1
        set deep 1
        if string match -q -- '*/' $tok
            set root_typed $tok
        else if string match -q -- '*/*' $tok
            set root_typed (string replace -r '[^/]*$' '' -- $tok)
            set query (string replace -r '^.*/' '' -- $tok)
        else
            set query $tok
        end
    end

    set -l choice
    if test $deep = 1
        # The directory to search below, as typed (~ kept) and as a real path.
        test -n "$root_typed"; and not string match -q -- '*/' $root_typed; and set root_typed "$root_typed/"
        set -l root (string replace -r -- '^~' $HOME $root_typed)
        test -n "$root"; or set root ./
        if not test -d "$root"
            commandline -f complete # what was typed is not a directory: nothing to search
            return
        end

        set -l exclude $FZF_COMPLETE_EXCLUDE
        set -q FZF_COMPLETE_EXCLUDE; or set exclude .git node_modules .cache __pycache__ .npm .cargo .gradle .m2 .venv go/pkg
        set -l prompt (test $dirs_only = 1; and echo 'cd> '; or echo '**> ')

        set -l picked (begin
            if type -q fd
                set -l fdargs --base-directory $root --hidden --color=never
                set -q FZF_COMPLETE_FOLLOW; and set -a fdargs --follow
                test $dirs_only = 1; and set -a fdargs --type d
                for e in $exclude
                    set -a fdargs --exclude $e
                end
                set -q FZF_COMPLETE_MAX_DEPTH; and set -a fdargs --max-depth $FZF_COMPLETE_MAX_DEPTH
                fd $fdargs
            else
                # No fd: plain find (does not follow symlinks), same exclusions.
                set -l findargs
                for e in $exclude
                    set -a findargs -name $e -prune -o
                end
                test $dirs_only = 1; and set -a findargs -type d
                command find $root -mindepth 1 $findargs -printf '%P\n'
            end
        end | fzf --scheme=path --prompt=$prompt --query "$query" --select-1 --exit-0 \
            --bind 'tab:down,btab:up' --preview-window 'right:50%:wrap' \
            --preview "test -d "(string escape -- $root)"{}; and ls -1A --color=always "(string escape -- $root)"{}; or head -c 4000 "(string escape -- $root)"{}")
        or begin
            commandline -f repaint
            return
        end
        set choice "$root_typed$picked[1]"
        # A directory keeps going: end it with a slash
        test $dirs_only = 1; and not string match -q -- '*/' $choice; and set choice "$choice/"
    else
        set -l candidates (complete -C -- $line)

        # 0 or 1 candidate: let fish handle it natively (inserts / does nothing)
        if test (count $candidates) -le 1
            commandline -f complete
            return
        end

        set -l picked (printf '%s\n' $candidates | fzf \
            --delimiter \t --with-nth 1,2 --nth 1 --tabstop 24 \
            --query $tok \
            --select-1 --exit-0 \
            --bind 'tab:down,btab:up' \
            --preview-window 'right:50%:wrap' \
            --preview 'set -l p (string unescape -- {1}); test -d "$p"; and ls -1A --color=always "$p"; or test -f "$p"; and head -c 4000 "$p"; or echo {2}')
        # fzf exits non-zero on Esc/Ctrl-C (status must come from fzf, not a later pipe stage)
        or begin
            commandline -f repaint
            return
        end
        set choice (string replace -r '\t.*' '' -- $picked[1])
    end

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
