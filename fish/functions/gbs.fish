function gbs --description 'fzf branch switcher (local + remote, newest first)'
    git rev-parse --git-dir >/dev/null 2>&1; or begin
        echo "gbs: not a git repo" >&2
        return 1
    end
    set -l b (git for-each-ref --sort=-committerdate --format='%(refname:short)' refs/heads refs/remotes \
        | string match -rv '(^|/)HEAD$' \
        | fzf --prompt='branch> ' --no-sort \
            --preview 'git log --oneline --graph --color=always -20 {}')
    or return
    # origin/foo → foo, so git creates a local tracking branch
    for r in (git remote)
        set b (string replace -r "^$r/" '' -- $b)
    end
    git switch $b
end
