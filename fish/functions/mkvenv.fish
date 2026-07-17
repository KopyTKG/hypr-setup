function mkvenv --description 'Create + activate a python venv (default .venv)'
    set -l dir $argv[1]
    test -z "$dir"; and set dir .venv
    python -m venv $dir
    source $dir/bin/activate.fish
    pip install --upgrade pip
end
