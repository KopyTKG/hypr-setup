#!/usr/bin/env bash
# Deploy this repo onto a system:
#   1. config/  -> ~/.config/                  (symlink by default, --copy to copy)
#   2. bin/     -> ~/.local/bin/               (so launch-webapp et al. are on PATH)
# Existing files are backed up with a timestamp suffix.
#
# After install, the optional follow-up steps:
#   ./bin/install-webapps.sh    # register Chromium PWAs from webapps.list
#   mise install                # install dev tools declared in config/mise/config.toml

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$REPO_DIR/config"
BIN_SRC="$REPO_DIR/bin"
CONFIG_DST="$HOME/.config"
BIN_DST="$HOME/.local/bin"

MODE=symlink   # or "copy"
DRY=false

for arg in "$@"; do
  case "$arg" in
    --copy) MODE=copy ;;
    --symlink) MODE=symlink ;;
    --dry-run|-n) DRY=true ;;
    -h|--help)
      sed -n '2,10p' "$0"
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

deploy() {
  local src="$1" dst="$2"
  [ -d "$src" ] || return 0
  $DRY || mkdir -p "$dst"

  while IFS= read -r path; do
    local rel="${path#$src/}"
    local target="$dst/$rel"
    local parent
    parent="$(dirname "$target")"

    if $DRY; then
      say "DRY: would deploy $rel -> $target"
      continue
    fi
    mkdir -p "$parent"

    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ "$MODE" = symlink ] && [ -L "$target" ] && [ "$(readlink "$target")" = "$path" ]; then
        say "skip (already linked): $rel"
        continue
      fi
      mv "$target" "$target.bak.$ts"
      say "backup: $rel -> $rel.bak.$ts"
    fi

    if [ "$MODE" = symlink ]; then
      ln -s "$path" "$target"
      say "link: $rel"
    else
      cp -a "$path" "$target"
      say "copy: $rel"
    fi
  done < <(find "$src" \( -type f -o -type l \))
}

echo ">> Deploying config/ -> $CONFIG_DST"
deploy "$CONFIG_SRC" "$CONFIG_DST"

echo ""
echo ">> Deploying bin/ -> $BIN_DST"
deploy "$BIN_SRC" "$BIN_DST"

echo ""
if $DRY; then
  echo "Dry run complete."
  exit 0
fi

# Refresh font cache so Geist substitution kicks in
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -f >/dev/null 2>&1 || true
  echo "Font cache refreshed."
fi

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  ./bin/install-webapps.sh                 # register Chromium PWAs"
echo "  mise install                             # install dev tools (mise required)"
echo ""
echo "Reload running components:"
echo "  hyprctl reload && hyprctl configerrors"
echo "  killall -SIGUSR2 waybar"
echo "  makoctl reload"
