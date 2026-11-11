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
    # Alt-Shift-S: fuzzy-pick an SSH host and connect (functions/fssh.fish).
    bind \eS 'fssh; commandline -f repaint'
    # Tab: fzf over fish's own completions when there are several candidates
    # (cat, ssh, git, systemctl, ...); on `cd` and on any `**` token it searches
    # recursively instead (cd e<Tab>, vim src/**<Tab>). See
    # functions/fzf_tab_complete.fish for the tunables.
    # NOT named fzf_complete: `fzf --fish` (above) defines that function itself and
    # binds Shift-Tab to it (fzf's own completer, which also expands `**`). A
    # function defined in the session beats an autoloaded file, so a same-named
    # function here would silently never run. Shift-Tab keeps fzf's.
    bind \t fzf_tab_complete
end

# --- Alt-S: toggle `sudo` at the start of the current (or previous) command
bind alt-s __fish_prepend_sudo

# --- atuin: searchable shell history (Ctrl-R, replaces fzf's) -------
# Must come after the fzf block so its Ctrl-R binding wins. Up-arrow keeps
# fish's native prefix search. First run:  atuin import auto
if type -q atuin
    atuin init fish --disable-up-arrow | source
end

# --- zoxide: frecency-based cd  (z foo, zi = fzf picker) -------------
if type -q zoxide
    zoxide init fish | source
end

# --- mise (runtime version manager): shims, hooks, command-not-found -
if type -q mise
    mise activate fish | source
end

# --- direnv: per-project env (.envrc), auto load/unload on cd -------
if type -q direnv
    direnv hook fish | source
end

# --- starship prompt ------------------------------------------------
if type -q starship
    starship init fish | source
end
