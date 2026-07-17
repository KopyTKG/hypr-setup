function proj --description 'cd into a project under $PROJECTS_DIR'
    if test -z "$argv[1]"
        cd "$PROJECTS_DIR"
    else
        cd "$PROJECTS_DIR/$argv[1]"
    end
end
