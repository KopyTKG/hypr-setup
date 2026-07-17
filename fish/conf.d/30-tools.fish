# ===================================================================
# TOOL INITIALISATION   (ported from bash/60-tools.bash + 90-prompt.bash + 10-env.bash)
# fish ships completions for git/ssh/npm/docker/systemctl/pacman/sudo, so the
# hand-rolled bash completions are gone — nothing to port there.
# ===================================================================

# --- fzf ------------------------------------------------------------
if type -q fzf
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    # Ctrl-T (files), Ctrl-R (history), Alt-C (cd) key bindings
    fzf --fish | source
end

# --- mise (runtime version manager): shims, hooks, command-not-found -
if type -q mise
    mise activate fish | source
end

# --- starship prompt ------------------------------------------------
if type -q starship
    starship init fish | source
end
