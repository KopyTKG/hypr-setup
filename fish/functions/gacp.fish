function gacp --description 'git add all, commit with message, push'
    git add --all; and git commit -m "$argv[1]"; and git push
end
