function gclean --description 'Delete local branches already merged into main/master/develop'
    git branch --merged | grep -v '\*\|master\|main\|develop' | xargs -n 1 git branch -d
end
