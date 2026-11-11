function glf --description 'fzf git log browser (Enter: full diff, Ctrl-Y: copy hash)'
    git rev-parse --git-dir >/dev/null 2>&1; or begin
        echo "glf: not a git repo" >&2
        return 1
    end
    set -l show 'git show --color=always {1}'
    type -q delta; and set show "$show | delta"
    git log --color=always --format='%C(auto)%h%d %s %C(dim)%an, %cr' $argv \
        | fzf --ansi --no-sort --prompt='log> ' \
            --preview "$show" --preview-window 'right:60%' \
            --bind "enter:execute($show | less -R)" \
            --bind 'ctrl-y:execute-silent(echo -n {1} | wl-copy)+abort' \
            --header 'Enter: diff   Ctrl-Y: copy hash'
end
