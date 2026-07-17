function gundo --description 'Undo last commit, keep changes staged'
    git reset --soft HEAD~1
end
