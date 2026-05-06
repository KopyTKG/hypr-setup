#!/usr/bin/env bash
# Symlink (or copy) config/* into ~/.config/
# Existing files are backed up with a timestamp suffix.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO_DIR/config"
DST="$HOME/.config"

MODE=symlink   # or "copy"
DRY=false

for arg in "$@"; do
  case "$arg" in
    --copy) MODE=copy ;;
    --symlink) MODE=symlink ;;
    --dry-run|-n) DRY=true ;;
    -h|--help)
      sed -n '2,5p' "$0"
      echo ""
      echo "Usage: $0 [--symlink|--copy] [--dry-run]"
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 1
      ;;
  esac
done

ts="$(date +%s)"
say() { printf '  %s\n' "$*"; }
run() { if $DRY; then say "DRY: $*"; else eval "$@"; fi; }

if [ ! -d "$SRC" ]; then
  echo "config/ not found at $SRC" >&2
  exit 1
fi

mkdir -p "$DST"

# Walk every file/symlink in config/, deploy to matching ~/.config/ path.
while IFS= read -r path; do
  rel="${path#$SRC/}"
  target="$DST/$rel"
  parent="$(dirname "$target")"

  run mkdir -p "\"$parent\""

  if [ -e "$target" ] || [ -L "$target" ]; then
    # If already pointing where we'd put it, skip
    if [ "$MODE" = symlink ] && [ -L "$target" ] && [ "$(readlink "$target")" = "$path" ]; then
      say "skip (already linked): $rel"
      continue
    fi
    run mv "\"$target\"" "\"$target.bak.$ts\""
    say "backup: $rel -> $rel.bak.$ts"
  fi

  if [ "$MODE" = symlink ]; then
    run ln -s "\"$path\"" "\"$target\""
    say "link: $rel"
  else
    run cp -a "\"$path\"" "\"$target\""
    say "copy: $rel"
  fi
done < <(find "$SRC" \( -type f -o -type l \))

echo ""
echo "Done. Restart components that don't auto-reload:"
echo "  hyprctl reload && hyprctl configerrors"
echo "  omarchy restart waybar walker terminal"
