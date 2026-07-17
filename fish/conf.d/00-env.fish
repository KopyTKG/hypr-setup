# ===================================================================
# ENVIRONMENT + PATH   (ported from bash/10-env.bash)
# ===================================================================

# --- Editor ---------------------------------------------------------
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim

# --- Misc environment ----------------------------------------------
set -gx GPG_TTY (tty)
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx WEBKIT_DISABLE_DMABUF_RENDERER 1
set -gx HIP_VISIBLE_DEVICES 0
set -gx CAPACITOR_ANDROID_STUDIO_PATH "/usr/bin/android-studio"
set -gx PICO_SDK_PATH "$HOME/Dokumenty/pico/pico-sdk"

# Project navigation roots (used by proj/work functions)
set -gx PROJECTS_DIR "$HOME/projects"
set -gx WORK_DIR "$HOME/work"

# Toolchain homes (kept for tools that read the env var directly)
set -gx BUN_INSTALL "$HOME/.bun"

# --- PATH -----------------------------------------------------------
# High priority first (prepended). -g keeps these session-scoped and
# re-derived from this file each launch, so they never leak into fish's
# universal vars out of repo control.
fish_add_path -g "$HOME/.local/bin"
fish_add_path -g "$BUN_INSTALL/bin"
fish_add_path -g "$HOME/go/bin"
fish_add_path -g "$HOME/.deno/bin"
# Lower priority (appended)
fish_add_path -ga "$HOME/.dotnet/tools"
fish_add_path -ga "$HOME/.maestro/bin"
