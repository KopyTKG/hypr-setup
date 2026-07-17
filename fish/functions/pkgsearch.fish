function pkgsearch --description 'Search installed pacman packages'
    if test -z "$argv[1]"
        pacman -Qq | column
    else
        pacman -Qq | grep -i "$argv[1]" | column
    end
end
