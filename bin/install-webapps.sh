#!/usr/bin/env bash
# Read webapps.list and create .desktop entries in ~/.local/share/applications/
# so the apps show up in walker (and any XDG-compliant launcher).
#
# Usage: install-webapps.sh [--remove] [--list FILE]

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIST="$REPO_DIR/webapps.list"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$APP_DIR/icons/webapps"
LAUNCHER="$REPO_DIR/bin/launch-webapp"
REMOVE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --remove) REMOVE=true ;;
    --list) LIST="$2"; shift ;;
    -h|--help)
      sed -n '2,7p' "$0"
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
  shift
done

[ -f "$LIST" ] || { echo "webapps list not found: $LIST" >&2; exit 1; }
[ -x "$LAUNCHER" ] || { echo "launcher not executable: $LAUNCHER" >&2; exit 1; }

mkdir -p "$APP_DIR" "$ICON_DIR"

slugify() { printf '%s' "$1" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-'; }

while IFS='|' read -r name url categories; do
  # Skip blanks and comments
  case "$name" in ''|\#*) continue ;; esac
  url="${url#"${url%%[![:space:]]*}"}"
  categories="${categories:-Network}"

  slug="$(slugify "$name")"
  desktop_file="$APP_DIR/webapp-$slug.desktop"
  icon_file="$ICON_DIR/$slug.png"

  if $REMOVE; then
    rm -f "$desktop_file" "$icon_file"
    echo "removed: $name"
    continue
  fi

  # Best-effort favicon fetch (Google's favicon service)
  if [ ! -f "$icon_file" ]; then
    domain="${url#*://}"; domain="${domain%%/*}"
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL --max-time 5 -o "$icon_file" \
        "https://www.google.com/s2/favicons?domain=${domain}&sz=128" 2>/dev/null || rm -f "$icon_file"
    fi
  fi
  icon_ref="$icon_file"
  [ -f "$icon_ref" ] || icon_ref="web-browser"

  cat > "$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$name
Comment=$name (Chromium webapp)
Exec=$LAUNCHER "$name" "$url"
Icon=$icon_ref
Terminal=false
Categories=$categories;
StartupNotify=true
StartupWMClass=webapp-${name// /-}
EOF
  echo "installed: $name -> $desktop_file"
done < "$LIST"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi
