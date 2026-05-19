# ===================================================================
# DEVELOPMENT UTILITIES
# ===================================================================
# Quick server
alias serve='python -m http.server'
alias serve-bun='bunx serve'

# Find stuff
alias fhere='find . -name'
alias grephere='grep -r'

# Process management
alias ka='killall'
alias pgrep='pgrep -l'

# ===================================================================
# PROJECT NAVIGATION
# ===================================================================
export PROJECTS_DIR="$HOME/projects"
export WORK_DIR="$HOME/work"

function proj() {
    if [ -z "$1" ]; then
        cd "$PROJECTS_DIR"
    else
        cd "$PROJECTS_DIR/$1"
    fi
}

function work() {
    if [ -z "$1" ]; then
        cd "$WORK_DIR"
    else
        cd "$WORK_DIR/$1"
    fi
}

function lsproj() {
    ls -l "$PROJECTS_DIR"
}

function lswork() {
    ls -l "$WORK_DIR"
}

# Create a new React component
function mkcomp() {
    local name=$1
    local dir=${2:-.}
    mkdir -p "$dir/$name"
    cat > "$dir/$name/$name.tsx" << EOF
import React from 'react';
import './$name.css';

interface ${name}Props {}

export const $name: React.FC<${name}Props> = () => {
  return (
    <div className="$name">
      <h1>$name Component</h1>
    </div>
  );
};
EOF
    touch "$dir/$name/$name.css"
    echo "Component $name created in $dir/$name"
}

# ===================================================================
# UTILITY FUNCTIONS
# ===================================================================
# Extract archives
function extract() {
    if [ -f "$1" ]; then
        case $1 in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make directory and cd into it
function mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Quick backup
function backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# Find and kill process by port
function killport() {
    if command -v lsof &> /dev/null; then
        lsof -ti:$1 | xargs kill -9 2>/dev/null
    else
        ss -lptn "sport = :$1" | grep -Po "pid=\K\d+" | xargs kill -9 2>/dev/null
    fi
}

# Get current IP
function myip() {
    curl -s ifconfig.me
}
