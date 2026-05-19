# lib/colors.sh — shared ANSI color helpers for bootstrap.sh / install.sh.
#
# Source it relative to the calling script:
#   source "$(dirname "$(readlink -f "$0")")/lib/colors.sh"
#
# red() writes to stderr; the rest write to stdout.

cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
gray()  { printf '\033[90m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }
