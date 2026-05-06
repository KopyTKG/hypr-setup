#!/usr/bin/env bash
# setup.sh — full bootstrap on a fresh Arch system.
#
# Usage:
#   ./setup.sh                 # full install
#   ./setup.sh --dry-run       # show what would happen
#   ./setup.sh --skip-aur      # only official-repo packages
#   ./setup.sh --skip-mise     # don't install dev tools
#   ./setup.sh --skip-webapps  # don't register Chromium PWAs
#
# Steps (each can be skipped):
#   1. pacman -S … from packages/pacman.txt
#   2. install yay if missing, then yay -S … from packages/aur.txt
#   3. install.sh — symlink config/ and bin/ into $HOME
#   4. install-webapps.sh — register Chromium PWAs from webapps.list
#   5. mise install — pin dev tools per config/mise/config.toml

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=false
SKIP_AUR=false
SKIP_MISE=false
SKIP_WEBAPPS=false

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY=true ;;
    --skip-aur) SKIP_AUR=true ;;
    --skip-mise) SKIP_MISE=true ;;
    --skip-webapps) SKIP_WEBAPPS=true ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 1
      ;;
  esac
done

run() { if $DRY; then echo "DRY: $*"; else "$@"; fi; }
say() { printf '\n>> %s\n' "$*"; }

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Run as a regular user; sudo is invoked when needed." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "This setup targets Arch Linux. pacman not found." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo not found." >&2
  exit 1
fi

read_list() {
  # echo non-comment, non-blank lines from a file
  [ -f "$1" ] || return 0
  grep -vE '^\s*(#|$)' "$1" || true
}

# 1. Official-repo packages
say "Installing official-repo packages"
mapfile -t pacman_pkgs < <(read_list "$REPO_DIR/packages/pacman.txt")
if [ "${#pacman_pkgs[@]}" -gt 0 ]; then
  run sudo pacman -Syu --needed --noconfirm "${pacman_pkgs[@]}"
else
  echo "  (nothing in packages/pacman.txt)"
fi

# 2. yay + AUR packages
if ! $SKIP_AUR; then
  if ! command -v yay >/dev/null 2>&1; then
    say "Installing yay (AUR helper)"
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    run sudo pacman -S --needed --noconfirm base-devel git
    run git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
    if ! $DRY; then
      ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
    fi
    trap - EXIT
    rm -rf "$tmp"
  fi

  say "Installing AUR packages"
  mapfile -t aur_pkgs < <(read_list "$REPO_DIR/packages/aur.txt")
  if [ "${#aur_pkgs[@]}" -gt 0 ]; then
    run yay -S --needed --noconfirm "${aur_pkgs[@]}"
  else
    echo "  (nothing in packages/aur.txt)"
  fi
fi

# 3. Deploy configs and bin/
say "Deploying configs"
if $DRY; then
  run "$REPO_DIR/install.sh" --dry-run
else
  run "$REPO_DIR/install.sh"
fi

# 4. Webapps
if ! $SKIP_WEBAPPS; then
  say "Registering Chromium PWAs"
  run "$REPO_DIR/bin/install-webapps.sh"
fi

# 5. mise — install dev tools
if ! $SKIP_MISE; then
  say "Installing dev tools via mise"
  if ! command -v mise >/dev/null 2>&1; then
    echo "  mise not found on PATH — falling back to mise.run installer"
    if $DRY; then
      echo "  DRY: curl -fsSL https://mise.run | sh"
    else
      curl -fsSL https://mise.run | sh
      export PATH="$HOME/.local/bin:$PATH"
    fi
  fi
  run mise install
fi

echo ""
echo "Done."
echo ""
echo "Reload running components:"
echo "  hyprctl reload && hyprctl configerrors"
echo "  killall -SIGUSR2 waybar"
echo "  makoctl reload"
echo "  fc-cache -f"
