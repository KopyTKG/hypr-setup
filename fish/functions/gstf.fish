function gstf --description 'fzf stash picker (Enter: apply, Ctrl-D: drop)'
    git rev-parse --git-dir >/dev/null 2>&1; or begin
        echo "gstf: not a git repo" >&2
        return 1
    end
    set -l s (git stash list \
        | fzf --prompt='stash> ' --delimiter ':' \
            --preview 'git stash show -p --color=always {1}' \
            --bind 'ctrl-d:execute-silent(git stash drop {1})+abort' \
            --header 'Enter: apply   Ctrl-D: drop')
    or return
    git stash apply (string replace -r ':.*' '' -- $s)
end
