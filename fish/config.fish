# ===================================================================
# FISH CONFIG - Development Workstation
# User: Kopy (Martin)
# Dev Stack: Java, Kotlin, C# (.NET), React Native, Expo, Preact, Go, LaTeX
#
# Ported from bash/*.bash. Fish autoloads, so this file stays thin:
#   conf.d/*.fish   → sourced on every shell, in filename order (env, abbrs,
#                     command overrides, tool init). See conf.d/README below.
#   functions/*.fish→ one function per file, lazy-loaded on first use.
#
# What was dropped vs the bash config (fish gives it for free):
#   - oh-my-bash            → native autosuggestions + syntax highlighting
#   - readline/bind tweaks  → fish completion is case-insensitive & fuzzy already
#   - hand-rolled sudo/systemctl/pacman/yay completions → fish ships better ones
#   - HISTSIZE/histappend   → fish history is unbounded & shared by default
# ===================================================================

# Host-specific override, loaded last if present (parity with ~/.bashrc.local)
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
