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
