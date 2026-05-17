#!/bin/bash
# bootstrap.sh — fresh-box setup for hypr-setup.
#   1. install yay (if missing)
#   2. install every pacman + AUR package listed in README.md
#   3. run ./install.sh to wire configs into ~/.config/, ~/.local/bin/, system theme
#
# Idempotent: pacman/yay run with --needed; install.sh is idempotent on its own.
# Run as your normal user (NOT root). sudo is called only where required.

set -e
REPO=$(dirname "$(readlink -f "$0")")

cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
gray()  { printf '\033[90m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }

if [[ $EUID -eq 0 ]]; then
  red "Don't run as root. yay refuses, and install.sh expects to write into \$HOME."
  red "Run as your normal user: bash $0"
  exit 1
fi

if ! command -v pacman >/dev/null; then
  red "pacman not found — this script is Arch-only."
  exit 1
fi

# Keep sudo timestamp warm so the long pacman run doesn't prompt mid-stream.
cyan "[0/4] sudo check"
sudo -v
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

# ============================================================================
# [1/4] yay (AUR helper)
# ============================================================================
cyan "[1/4] yay"
if command -v yay >/dev/null; then
  gray "  ✓ yay already installed ($(yay --version | head -1))"
else
  gray "  installing base-devel + git, then building yay from AUR"
  sudo pacman -S --needed --noconfirm base-devel git
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
  rm -rf "$tmp"
  green "  → yay installed"
fi

# ============================================================================
# [2/4] pacman packages (from README "One-shot bootstrap")
# ============================================================================
cyan "[2/4] pacman -S --needed (extra/multilib)"
PACMAN_PKGS=(
  # Hyprland session
  hyprland hypridle hyprlock hyprpicker hyprshot hyprsunset uwsm
  xdg-desktop-portal-hyprland sddm polkit-gnome plymouth
  # bar / launcher / notifications
  waybar mako swaybg swayosd
  # terminal & CLI
  alacritty xdg-terminal-exec fzf gum jq python neovim fastfetch starship
  bash-completion
  # tray TUIs
  btop yazi libnotify brightnessctl fcitx5 pipewire-pulse
  bluez bluez-utils iwd
  # fonts
  ttf-cascadia-mono-nerd
  # git / net basics
  git openssh curl tar wl-clipboard
  # shell QoL (referenced by .bashrc)
  lazygit eza bat fd ripgrep git-delta tree net-tools lsof
  # dev toolchains
  jdk-openjdk kotlin maven gradle texlive-meta bun
  # default-keybind apps
  chromium nautilus
  # installer/migrator helpers
  mise snapper
  # AMD + Steam (no-op on Intel/NV; harmless to install)
  vulkan-radeon lib32-vulkan-radeon mesa-utils
)
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ============================================================================
# [3/4] AUR packages (walker/elephant stack + tray TUIs)
# ============================================================================
cyan "[3/4] yay -S --needed (AUR / chaotic-aur)"
AUR_PKGS=(
  walker elephant
  elephant-bluetooth elephant-calc elephant-clipboard
  elephant-desktopapplications elephant-files elephant-menus
  elephant-providerlist elephant-runner elephant-symbols elephant-todo
  elephant-unicode elephant-websearch
  bluetui impala wiremix
)
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ============================================================================
# [4/4] hand off to install.sh
# ============================================================================
cyan "[4/4] running install.sh"
if [[ ! -x $REPO/install.sh ]]; then
  red "  $REPO/install.sh not found or not executable"
  exit 1
fi
"$REPO/install.sh"

green "bootstrap complete."
green "  → reboot for new SDDM + Plymouth splash"
green "  → run nvim/install.sh once for the Neovim submodule's extras"
