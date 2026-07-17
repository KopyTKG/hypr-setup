function killport --description 'Kill whatever is listening on a port'
    if type -q lsof
        lsof -ti:$argv[1] | xargs kill -9 2>/dev/null
    else
        ss -lptn "sport = :$argv[1]" | grep -Po "pid=\K\d+" | xargs kill -9 2>/dev/null
    end
end
