# ===================================================================
# BASHRC - Development Workstation
# User: Kopy (Martin)
# Dev Stack: Java, Kotlin, C# (.NET), React Native, Expo, Preact, Go, LaTeX
#
# This is the boot file. It sources the rest of bash/*.bash in numeric
# order from the same directory as this file (resolved via readlink so
# ~/.bashrc can be a symlink into the repo).
# ===================================================================

# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Early-load local override (host-specific tweaks before everything else)
[ -f ~/.bashrc.local.pre ] && source ~/.bashrc.local.pre

# Source siblings: bash/00-*.bash through bash/99-*.bash
_bashrc_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
for _bashrc_part in "$_bashrc_dir"/*.bash; do
  [ -r "$_bashrc_part" ] && source "$_bashrc_part"
done
unset _bashrc_dir _bashrc_part

# Late-load local override (per-host tweaks after everything else)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
