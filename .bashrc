# ===================================================================
# BASHRC - Development Workstation
# User: Kopy (Martin)
# Dev Stack: Java, Kotlin, C# (.NET), React Native, Expo, Preact, Go, LaTeX
# ===================================================================

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# ===================================================================
# LOCAL CUSTOMIZATIONS (EARLY LOAD)
# ===================================================================
[ -f ~/.bashrc.local.pre ] && source ~/.bashrc.local.pre

# ===================================================================
# OH-MY-BASH CONFIGURATION
# ===================================================================
if [[ -d "$HOME/.oh-my-bash" ]]; then
    export OSH='/home/kopy/.oh-my-bash'

    OSH_THEME="lambda"
    ENABLE_CORRECTION="true"
    COMPLETION_WAITING_DOTS="true"
    HIST_STAMPS='yyyy-mm-dd'
    OMB_USE_SUDO=true
    OMB_PROMPT_SHOW_PYTHON_VENV=true
    OMB_PROMPT_SHOW_SPACK_ENV=true

    completions=(
      git
      ssh
      npm
      docker
    )

    aliases=(
      general
    )

    plugins=(
      git
      bashmarks
    )

    source "$OSH"/oh-my-bash.sh
fi

# ===================================================================
# EDITOR CONFIGURATION
# ===================================================================
export EDITOR='nvim'
export VISUAL='nvim'
export SUDO_EDITOR='nvim'
export TERM='linux'

# ===================================================================
# HISTORY CONFIGURATION
# ===================================================================
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:ll:cd:pwd:bg:fg:history:clear"
export HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s cmdhist
PROMPT_COMMAND='history -a'

# ===================================================================
# SHELL OPTIONS
# ===================================================================
shopt -s checkwinsize
shopt -s cdspell
shopt -s autocd
shopt -s dirspell
shopt -s globstar
shopt -s nocaseglob

# ===================================================================
# ENHANCED TAB COMPLETION
# ===================================================================
# Show all completions immediately
bind 'set show-all-if-ambiguous on'

# Case-insensitive tab completion
bind 'set completion-ignore-case on'

# Treat hyphens and underscores as equivalent
bind 'set completion-map-case on'

# Display matches in columns
bind 'set completion-display-width 0'

# Show common prefix before cycling through completions
bind 'set menu-complete-display-prefix on'

# Cycle through completions with Tab (forward) and Shift+Tab (backward)
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'

# Add a trailing slash to completed directory symlinks
bind 'set mark-symlinked-directories on'

# Color completions
bind 'set colored-stats on'
bind 'set visible-stats on'
bind 'set mark-directories on'
bind 'set colored-completion-prefix on'

# ===================================================================
# SUDO COMPLETION
# ===================================================================
_sudo_completion() {
    local cur prev words cword
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")
    cword=$COMP_CWORD

    # If we're on the first word after sudo, complete commands
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -c -- "$cur") )
        return 0
    fi

    # Otherwise, try to find the actual command and use its completion
    local actual_cmd="${words[1]}"

    # Check if there's a completion function for the command
    local comp_func
    comp_func=$(complete -p "$actual_cmd" 2>/dev/null | sed -n 's/.*-F \([^ ]*\).*/\1/p')

    if [[ -n "$comp_func" ]]; then
        # Temporarily adjust COMP_* variables to look like we're completing the actual command
        local old_words=("${COMP_WORDS[@]}")
        local old_cword=$COMP_CWORD

        COMP_WORDS=("${words[@]:1}")
        COMP_CWORD=$((cword - 1))

        # Call the completion function
        $comp_func

        # Restore original COMP_* variables
        COMP_WORDS=("${old_words[@]}")
        COMP_CWORD=$old_cword

        return 0
    fi

    # Fallback: just complete files
    COMPREPLY=( $(compgen -f -- "$cur") )
}

complete -F _sudo_completion sudo

# ===================================================================
# SYSTEMCTL COMPLETION
# ===================================================================
_systemctl_completion() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Skip sudo if present
    local offset=0
    if [[ "${COMP_WORDS[0]}" == "sudo" ]]; then
        offset=1
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        if [[ $COMP_CWORD -le 1 ]]; then
            return 0
        fi
    fi

    local commands="start stop restart reload status enable disable is-active is-enabled mask unmask list-units list-unit-files"
    local real_prev="${COMP_WORDS[$((COMP_CWORD-1))]}"

    case "$real_prev" in
        systemctl|sc)
            COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
            ;;
        start|stop|restart|reload|status|enable|disable|is-active|is-enabled|mask|unmask)
            COMPREPLY=( $(compgen -W "$(systemctl list-unit-files --no-legend --no-pager --type=service 2>/dev/null | awk '{print $1}' | sed 's/\.service$//')" -- "$cur") )
            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _systemctl_completion systemctl
complete -F _systemctl_completion sc

# ===================================================================
# ENVIRONMENT VARIABLES
# ===================================================================
export GPG_TTY=$(tty)
export ANDROID_HOME="$HOME/Android/Sdk"
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export HIP_VISIBLE_DEVICES=0
export CAPACITOR_ANDROID_STUDIO_PATH="/usr/bin/android-studio"
export PICO_SDK_PATH="$HOME/Dokumenty/pico/pico-sdk"

# ===================================================================
# PATH CONFIGURATION
# ===================================================================
export LOCAL_BIN="$HOME/.local/bin"
export BUN_INSTALL="$HOME/.bun"
export GO_PATH="$HOME/go/bin"
# Build PATH (order matters - local bins first)
export PATH="$LOCAL_BIN:$BUN_INSTALL/bin:$GO_PATH:$PATH"

# Deno initialization
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Mise (tool version manager) - activates shims, hooks, and command_not_found suggestions
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi

# ===================================================================
# SYSTEM ALIASES
# ===================================================================
# BASH
alias reload='source ~/.bashrc'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'

# Listing
alias ls='ls --color=auto'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CF'
alias lt='ls -lhtr'
alias lsize='ls -lhS'

# Safety nets
alias rm='rm -I --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Grep with color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# System monitoring
alias ports='netstat -tulanp'
alias meminfo='free -mth'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias df='df -h'
alias du='du -h'

# System management
alias update='yay -Syyu --noconfirm --useask --cleanafter'
alias vaultInfo='sudo mdadm --detail /dev/md0'
alias raidStatus='sudo mdadm --detail --scan'
alias tree='tree -C'

# ===================================================================
# GIT ALIASES
# ===================================================================
alias lz='lazygit'
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gl='git log --oneline --graph --decorate -10'
alias gd='git diff'

alias push='git push'
alias fetch='git fetch'
alias pull='git pull'

alias gss='git status -s'
alias gaa='git add --all'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gm='git merge'
alias gr='git rebase'
alias gla='git log --oneline --graph --decorate --all'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'

function gclean() {
    git branch --merged | grep -v '\*\|master\|main\|develop' | xargs -n 1 git branch -d
}

function gundo() {
    git reset --soft HEAD~1
}

function gacp() {
    git add --all && git commit -m "$1" && git push
}

# ===================================================================
# NODE/NPM/BUN/DENO ALIASES
# ===================================================================
# NPM
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nrun='npm run'
alias nstart='npm start'
alias ndev='npm run dev'
alias nbuild='npm run build'
alias ntest='npm test'
alias nup='npm update'
alias nout='npm outdated'
alias nls='npm list --depth=0'
alias nclean='rm -rf node_modules package-lock.json && npm install'

# Bun
alias bi='bun install'
alias ba='bun add'
alias bad='bun add --dev'
alias br='bun run'
alias bx='bunx'
alias bdev='bun run dev'
alias bbuild='bun run build'
alias btest='bun test'
alias bup='bun update'

# Deno
alias dr='deno run'
alias dt='deno task'
alias dtest='deno test'
alias dfmt='deno fmt'
alias dlint='deno lint'

# Yarn
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn run'
alias yup='yarn upgrade'

# pnpm
alias pi='pnpm install'
alias pa='pnpm add'
alias pr='pnpm run'

# React/Next.js
alias cra='bunx create-react-app'
alias cnext='bunx create-next-app'
alias cvite='bunx create-vite'

# ===================================================================
# PYTHON ALIASES
# ===================================================================
alias py='python'
alias py3='python3'
alias pip='pip3'
alias venv='python -m venv'
alias activate='source venv/bin/activate'

function mkvenv() {
    python -m venv ${1:-.venv}
    source ${1:-.venv}/bin/activate
    pip install --upgrade pip
}

# ===================================================================
# GO ALIASES
# ===================================================================
alias gor='go run'
alias gob='go build'
alias got='go test'
alias goi='go install'
alias gom='go mod'
alias gomt='go mod tidy'
alias gomv='go mod vendor'
alias gog='go get'

# ===================================================================
# JAVA ALIASES
# ===================================================================
alias jr='java'
alias jc='javac'
# Maven
alias mvnc='mvn clean'
alias mvnci='mvn clean install'
alias mvnt='mvn test'
alias mvnp='mvn package'
# Gradle (project wrapper preferred)
alias gw='./gradlew'

# ===================================================================
# KOTLIN ALIASES
# ===================================================================
alias ktc='kotlinc'
alias ktrun='kotlin'

# ===================================================================
# C# / .NET ALIASES
# ===================================================================
alias dn='dotnet'
alias dnr='dotnet run'
alias dnb='dotnet build'
alias dnt='dotnet test'
alias dnn='dotnet new'
alias dnw='dotnet watch run'
alias dnp='dotnet publish'
alias dnres='dotnet restore'

# ===================================================================
# REACT NATIVE ALIASES
# ===================================================================
alias rn='npx react-native'
alias rna='npx react-native run-android'
alias rni='npx react-native run-ios'
alias rns='npx react-native start'
alias rnc='npx @react-native-community/cli init'

# ===================================================================
# EXPO ALIASES
# ===================================================================
alias ex='npx expo'
alias exs='npx expo start'
alias exa='npx expo run:android'
alias exi='npx expo run:ios'
alias exb='npx expo prebuild'
alias eas='npx eas-cli'

# ===================================================================
# PREACT ALIASES
# ===================================================================
alias cpreact='bunx create-preact'

# ===================================================================
# LATEX ALIASES
# ===================================================================
alias tex='pdflatex'
alias xtex='xelatex'
alias lutex='lualatex'
alias bib='bibtex'
alias texmk='latexmk -pdf'
alias texmkclean='latexmk -c'

# ===================================================================
# C++ ALIASES
# ===================================================================
alias g++='g++ -std=c++20 -Wall -Wextra'
alias cmake-build='cmake -B build && cmake --build build'

# ===================================================================
# DOCKER ALIASES
# ===================================================================
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dlog='docker logs -f'
    alias dex='docker exec -it'
    alias dstop='docker stop'
    alias dstart='docker start'
    alias drm='docker rm'
    alias drmi='docker rmi'
    alias dlogs='docker logs -f'
    alias dprune='docker system prune -af'
    alias dstat='docker stats --no-stream'
fi

# Docker Compose
if command -v docker-compose &> /dev/null; then
    alias dc='docker-compose'
    alias dcup='docker-compose up -d'
    alias dcdown='docker-compose down'
    alias dclog='docker-compose logs -f'
    alias dcrestart='docker-compose restart'
fi

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

# ===================================================================
# FZF CONFIGURATION
# ===================================================================
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # FZF package search for yay/pacman removal
    function _fzf_complete_yay_remove() {
        _fzf_complete --prompt="Packages> " --multi --reverse -- "$@" < <(
            pacman -Qq
        )
    }

    # Bind it to yay -R and pacman -R
    complete -F _fzf_complete_yay_remove -o default -o bashdefault yay -R
    complete -F _fzf_complete_yay_remove -o default -o bashdefault pacman -R
fi

# ===================================================================
# PACKAGE COMPLETION
# ===================================================================
_yay_remove_completion() {
    local cur prev opts
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # If we're after -R or removal flags, complete with installed packages
    if [[ "$prev" == "-R"* ]] || [[ "${COMP_WORDS[*]}" == *" -R"* ]] || [[ "${COMP_WORDS[*]}" == *" -Rs"* ]] || [[ "${COMP_WORDS[*]}" == *" -Rns"* ]]; then
        COMPREPLY=( $(compgen -W "$(pacman -Qq 2>/dev/null)" -- "$cur") )
        return 0
    fi

    # For search/install operations, complete with repo packages
    if [[ "$prev" == "-S"* ]] || [[ "${COMP_WORDS[*]}" == *" -S"* ]]; then
        COMPREPLY=( $(compgen -W "$(pacman -Slq 2>/dev/null)" -- "$cur") )
        return 0
    fi

    # Otherwise show common options
    opts="-S -R -Rs -Rns -Ss -Si -Q -Qi -Syu -Syyu"
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
}

complete -F _yay_remove_completion yay
complete -F _yay_remove_completion pacman

# ===================================================================
# COMMAND SEARCH
# ===================================================================
function cmdsearch() {
    if [ -z "$1" ]; then
        echo "Usage: cmdsearch <pattern>"
        return 1
    fi
    compgen -c | grep -i "$1" | sort -u | column
}

function pkgsearch() {
    if [ -z "$1" ]; then
        pacman -Qq | column
    else
        pacman -Qq | grep -i "$1" | column
    fi
}

# ===================================================================
# BAT CONFIGURATION
# ===================================================================
if command -v bat &> /dev/null; then
    alias cat='bat --style=plain --paging=never'
    alias bathelp='bat --plain --language=help'
    function help() {
        "$@" --help 2>&1 | bathelp
    }
fi

# ===================================================================
# EZA CONFIGURATION
# ===================================================================
if command -v eza &> /dev/null; then
    alias ls='eza --icons'
    alias ll='eza -lah --icons --git'
    alias la='eza -a --icons'
    alias lt='eza -lah --icons --git --sort=modified'
    alias tree='eza --tree --icons'
fi

# ===================================================================
# STARSHIP PROMPT
# ===================================================================
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# ===================================================================
# LOCAL CUSTOMIZATIONS
# ===================================================================
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# ===================================================================
# WELCOME MESSAGE
# ===================================================================
if [[ -t 1 ]]; then
    echo -e "\n🚀 Welcome back, Kopy!\n"
    echo "Dev Stack Ready:"
    command -v java     &> /dev/null && echo "  ✓ Java $(java -version 2>&1 | head -n1 | awk -F'\"' '{print $2}')"
    command -v kotlin   &> /dev/null && echo "  ✓ Kotlin $(kotlin -version 2>&1 | awk '{print $3}')"
    command -v dotnet   &> /dev/null && echo "  ✓ .NET $(dotnet --version)"
    command -v go       &> /dev/null && echo "  ✓ Go $(go version | awk '{print $3}')"
    command -v node     &> /dev/null && echo "  ✓ Node $(node -v)"
    command -v bun      &> /dev/null && echo "  ✓ Bun $(bun -v)"
    command -v pdflatex &> /dev/null && echo "  ✓ LaTeX $(pdflatex --version | head -n1 | awk '{print $2}')"

    if command -v mise &> /dev/null; then
        active_count=$(mise current 2>/dev/null | grep -c .)
        installed_count=$(mise ls --installed 2>/dev/null | grep -c .)
        echo ""
        echo "Mise ($active_count active · $installed_count installed):"
        { mise current      2>/dev/null | sed 's/^/CUR /';
          mise ls --installed 2>/dev/null | sed 's/^/ALL /'; } | \
        awk '
            $1=="CUR" { active[$2] = $3; next }
            $1=="ALL" {
                tool = $2; ver = $3
                if (!(tool in seen)) { order[++n] = tool; seen[tool] = 1 }
                sep = (tool in versions ? ", " : "")
                if (ver == active[tool]) versions[tool] = versions[tool] sep "\033[1m" ver "\033[0m"
                else                     versions[tool] = versions[tool] sep ver
            }
            END {
                for (i = 1; i <= n; i++) printf "  ▸ %-8s %s\n", order[i], versions[order[i]]
            }'
        unset active_count installed_count
    fi
    echo ""
fi
export PATH="$PATH:$HOME/.dotnet/tools"
