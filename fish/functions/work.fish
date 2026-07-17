function work --description 'cd into a workspace under $WORK_DIR'
    if test -z "$argv[1]"
        cd "$WORK_DIR"
    else
        cd "$WORK_DIR/$argv[1]"
    end
end
