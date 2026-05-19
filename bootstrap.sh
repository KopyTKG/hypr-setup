#!/bin/bash
# bootstrap.sh — vanilla Arch (post-pacstrap, no DM/audio/Wayland) → full desktop.
#
# Phases:
#   [0/6] sudo check + keepalive
#   [1/6] yay (AUR helper)
#   [2/6] pacman -S the extra/multilib stack (Hyprland, audio, Wayland, dev tools)
#   [3/6] yay -S the AUR / chaotic-aur bits (walker, elephant-*, AUR-only TUIs)
#   [4/6] GPU drivers (interactive — gum choose AMD/Intel/Nvidia/skip)
#   [5/6] Enable + configure system services (sddm, bluetooth, iwd, resolved)
#   [6/6] Hand off to ./install.sh (symlink configs, enable gcr-ssh-agent, …)
#
# Idempotent: pacman/yay run with --needed; service is-enabled checks;
# config files only written when missing.
# Run as your normal user (NOT root). sudo is called where required.

set -e
REPO=$(dirname "$(readlink -f "$0")")

source "$REPO/lib/colors.sh"

if [[ $EUID -eq 0 ]]; then
  red "Don't run as root. yay refuses, and install.sh expects to write into \$HOME."
  red "Run as your normal user: bash $0"
  exit 1
fi

if ! command -v pacman >/dev/null; then
  red "pacman not found — this script is Arch-only."
  exit 1
fi

cyan "[0/6] sudo check"
sudo -v
( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT

# ============================================================================
# [1/6] yay
# ============================================================================
cyan "[1/6] yay"
if command -v yay >/dev/null; then
  gray "  ✓ yay already installed ($(yay --version | head -1))"
else
  gray "  installing base-devel + git, then building yay-bin from AUR"
  sudo pacman -S --needed --noconfirm base-devel git
  tmp=$(mktemp -d)
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
  rm -rf "$tmp"
  green "  → yay installed"
fi

# ============================================================================
# [2/6] pacman packages
# ============================================================================
cyan "[2/6] pacman -S --needed (extra/multilib)"
PACMAN_PKGS=(
  # Hyprland session
  hyprland hypridle hyprlock hyprpicker hyprshot hyprsunset uwsm
  xdg-desktop-portal-hyprland sddm polkit-gnome plymouth
  # bar / launcher / notifications
  waybar mako swaybg swayosd
  # terminal & CLI (xdg-terminal-exec is AUR-only as -git, installed below)
  alacritty fzf gum jq python neovim fastfetch starship
  bash-completion
  # tray TUIs (bluetui/impala/wiremix moved out of AUR — they're in extra now)
  btop yazi libnotify brightnessctl fcitx5 bluetui impala wiremix
  # audio (pipewire stack — wireplumber is REQUIRED on modern Arch)
  pipewire pipewire-alsa pipewire-pulse wireplumber
  # wayland fallbacks for Qt + X11 apps
  qt6-wayland xorg-xwayland
  # bluetooth + wifi backends
  bluez bluez-utils iwd
  # fonts
  ttf-cascadia-mono-nerd
  # git / net basics
  git openssh curl tar wl-clipboard
  # keyring + SSH agent
  gnome-keyring libsecret gcr-4
  # shell QoL (referenced by .bashrc)
  lazygit eza bat fd ripgrep git-delta tree net-tools lsof
  # dev toolchains
  jdk-openjdk kotlin maven gradle texlive-meta bun
  # default-keybind apps
  chromium nautilus
  # installer/migrator helpers
  mise snapper
  # LTS kernel (in addition to whatever the user pacstrapped with)
  linux-lts linux-lts-headers
  # auto-mount + user dirs + manuals + pacman QoL + hw inspect
  udisks2 xdg-user-dirs man-db man-pages pacman-contrib pciutils usbutils
)
sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

# ============================================================================
# [3/6] AUR packages
# ============================================================================
cyan "[3/6] yay -S --needed (AUR / chaotic-aur)"
# Prefer -bin (prebuilt) variants when upstream offers them — no compile
# step, no Go/Rust toolchain pulled in just for the install.
# xdg-terminal-exec is AUR-only-as-git (no stable release exists).
AUR_PKGS=(
  walker-bin
  elephant-bin
  elephant-bluetooth-bin elephant-calc-bin elephant-clipboard-bin
  elephant-desktopapplications-bin elephant-files-bin elephant-menus-bin
  elephant-providerlist-bin elephant-runner-bin elephant-symbols-bin
  elephant-todo-bin elephant-unicode-bin elephant-websearch-bin
  xdg-terminal-exec-git
)
yay -S --needed --noconfirm "${AUR_PKGS[@]}"

# ============================================================================
# [4/6] GPU drivers (interactive)
# ============================================================================
cyan "[4/6] GPU drivers"
detected=$(lspci -nn 2>/dev/null | grep -Ei 'vga|3d|display' || true)
if [[ -n $detected ]]; then
  gray "  Detected:"
  while IFS= read -r line; do gray "    $line"; done <<< "$detected"
else
  gray "  lspci returned no GPU lines (running in a VM?)"
fi

gpu_pick=$(gum choose --header="Which GPU drivers?" \
  "AMD            (vulkan-radeon + lib32 + mesa-utils)" \
  "Intel          (vulkan-intel + intel-media-driver)" \
  "Nvidia open    (nvidia-open + nvidia-utils)" \
  "Nvidia closed  (nvidia + nvidia-utils)" \
  "Skip" 2>/dev/null) || gpu_pick=""

case "$gpu_pick" in
  AMD*)
    sudo pacman -S --needed --noconfirm \
      vulkan-radeon lib32-vulkan-radeon mesa-utils libva-mesa-driver
    ;;
  Intel*)
    sudo pacman -S --needed --noconfirm \
      vulkan-intel lib32-vulkan-intel intel-media-driver mesa-utils
    ;;
  "Nvidia open"*)
    sudo pacman -S --needed --noconfirm \
      nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings
    red "  ! Nvidia + Wayland is fiddly. Check /etc/modprobe.d/ + Hyprland env after reboot."
    ;;
  "Nvidia closed"*)
    sudo pacman -S --needed --noconfirm \
      nvidia nvidia-utils lib32-nvidia-utils nvidia-settings
    red "  ! Nvidia + Wayland is fiddly. Check /etc/modprobe.d/ + Hyprland env after reboot."
    ;;
  *)
    gray "  skipped — no GPU packages installed"
    ;;
esac

# ============================================================================
# [5/6] System services + iwd network config
# ============================================================================
cyan "[5/6] System services + iwd network"

enable_unit() {
  local svc=$1
  if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
    gray "  ✓ $svc already enabled"
  else
    sudo systemctl enable "$svc" 2>/dev/null \
      && green "  → $svc enabled" \
      || red "  ! failed to enable $svc"
  fi
}

enable_unit sddm.service
enable_unit bluetooth.service
enable_unit iwd.service
enable_unit systemd-resolved.service

# Tell iwd to handle DHCP + DNS itself (so wifi just works after `iwctl connect`).
IWD_CONF=/etc/iwd/main.conf
if [[ ! -f $IWD_CONF ]]; then
  sudo mkdir -p /etc/iwd
  sudo tee "$IWD_CONF" >/dev/null <<'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF
  green "  → $IWD_CONF written"
else
  gray "  ✓ $IWD_CONF already present (left alone)"
fi

# Point /etc/resolv.conf at systemd-resolved's stub (only if not already a symlink).
RESOLV=/etc/resolv.conf
STUB=/run/systemd/resolve/stub-resolv.conf
if [[ -L $RESOLV ]]; then
  if [[ "$(readlink "$RESOLV")" == "$STUB" ]]; then
    gray "  ✓ $RESOLV → systemd stub"
  else
    red "  ! $RESOLV → $(readlink "$RESOLV") (left alone; manual: sudo ln -sf $STUB $RESOLV)"
  fi
else
  sudo ln -sf "$STUB" "$RESOLV"
  green "  → $RESOLV → $STUB"
fi

# Populate ~/Documents, ~/Downloads, ... (only on first run)
if [[ ! -f $HOME/.config/user-dirs.dirs ]]; then
  xdg-user-dirs-update
  green "  → xdg-user-dirs populated"
else
  gray "  ✓ xdg-user-dirs already populated"
fi

# ============================================================================
# [6/6] hand off to install.sh
# ============================================================================
cyan "[6/6] running install.sh"
if [[ ! -x $REPO/install.sh ]]; then
  red "  $REPO/install.sh not found or not executable"
  exit 1
fi
"$REPO/install.sh"

green "bootstrap complete."
green "  → reboot to land in SDDM with the stone theme + Plymouth splash"
green "  → first time wifi:   iwctl  (or impala — SUPER+CTRL+W in the new session)"
green "  → run nvim/install.sh once for the Neovim submodule's extras"

if ! command -v spot >/dev/null 2>&1; then
  echo
  red "  !! spot binary not found on \$PATH"
  red "     arch-menu, arch-askpass, arch-power-menu, arch-keyboard, and arch-power-profile-menu all need it."
  red "     Build it from the submodule:"
  red "       cd $REPO/spot && go build -o spot . && ln -sf \"\$PWD/spot\" ~/.local/bin/spot"
  echo
fi
if pacman -Q linux-lts >/dev/null 2>&1; then
  if pacman -Q limine-mkinitcpio-hook >/dev/null 2>&1 && [[ -f /boot/limine.conf ]]; then
    if grep -q 'linux-lts' /boot/limine.conf 2>/dev/null; then
      green "  → linux-lts entry already in /boot/limine.conf (auto-added by limine-mkinitcpio-hook)"
    else
      green "  → linux-lts installed. Bootloader (limine): sudo limine-update"
    fi
  elif [[ -d /boot/grub ]]; then
    green "  → linux-lts installed. Bootloader (grub): sudo grub-mkconfig -o /boot/grub/grub.cfg"
  elif [[ -d /boot/loader/entries ]]; then
    green "  → linux-lts installed. Bootloader (systemd-boot): create /boot/loader/entries/arch-lts.conf"
  else
    green "  → linux-lts installed. Update your bootloader to add the LTS entry."
  fi
fi
