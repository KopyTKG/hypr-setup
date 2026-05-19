# ===================================================================
# EDITOR CONFIGURATION
# ===================================================================
export EDITOR='nvim'
export VISUAL='nvim'
export SUDO_EDITOR='nvim'

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
export PATH="$PATH:$HOME/.dotnet/tools"

# Deno initialization
[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Mise (tool version manager) - activates shims, hooks, and command_not_found suggestions
if command -v mise &> /dev/null; then
    eval "$(mise activate bash)"
fi
