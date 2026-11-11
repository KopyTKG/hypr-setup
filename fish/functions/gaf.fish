function gaf --description 'fzf stage picker for modified/untracked files (Tab = multi-select)'
    git rev-parse --git-dir >/dev/null 2>&1; or begin
        echo "gaf: not a git repo" >&2
        return 1
    end
    set -l picked (git ls-files -m -o --exclude-standard \
        | fzf --multi --prompt='stage> ' \
            --preview 'git diff --color=always -- {} | head -200; test -n "$(git ls-files -o --exclude-standard -- {})" && head -100 {}' \
            --header 'Tab: select  Enter: git add')
    or return
    git add -- $picked
    and git status -s
end
