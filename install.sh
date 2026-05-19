#!/bin/bash
# install.sh — wire this repo into ~/.config/, ~/.local/bin/, and system theme.
# Idempotent: existing files/dirs are timestamp-backed-up before linking.

set -e
REPO=$(dirname "$(readlink -f "$0")")
TS=$(date +%s)

cyan()  { printf '\033[36m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
gray()  { printf '\033[90m%s\033[0m\n' "$*"; }
red()   { printf '\033[31m%s\033[0m\n' "$*" >&2; }

link_to() {
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if [[ -L $dst && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    gray "  ✓ $dst (already linked)"
    return
  fi
  if [[ -e $dst || -L $dst ]]; then
    mv "$dst" "$dst.bak.$TS"
    gray "    backup: $dst → $dst.bak.$TS"
  fi
  ln -s "$src" "$dst"
  green "  → $dst"
}

cyan "[1/7] Link config dirs into ~/.config/"
for name in alacritty arch-menu btop elephant environment.d fastfetch hypr mako nvim swayosd walker waybar; do
  link_to "$REPO/$name" "$HOME/.config/$name"
done

cyan "[2/7] Link standalone config files"
link_to "$REPO/spot-config"                  "$HOME/.config/spot"
link_to "$REPO/chromium/chromium-flags.conf" "$HOME/.config/chromium-flags.conf"
link_to "$REPO/bash/.bashrc"   "$HOME/.bashrc"
link_to "$REPO/starship.toml"  "$HOME/.config/starship.toml"

cyan "[3/7] Link bin/arch-* into ~/.local/bin/"
for f in "$REPO/bin"/*; do
  link_to "$f" "$HOME/.local/bin/$(basename "$f")"
done

cyan "[4/7] Apply system-wide browser theme policy"
if [[ -x "$REPO/bin/arch-apply-browser-theme" ]]; then
  "$REPO/bin/arch-apply-browser-theme" || red "  (browser theme policy: skipped, manual run may be needed)"
fi

cyan "[5/7] Apply systemd user env + gsettings"
# Push FZF_DEFAULT_OPTS into the live systemd user session
if [[ -f "$HOME/.config/environment.d/fzf.conf" ]]; then
  line=$(head -1 "$HOME/.config/environment.d/fzf.conf")
  val="${line#FZF_DEFAULT_OPTS=}"
  systemctl --user set-environment "FZF_DEFAULT_OPTS=$val" || true
  gray "  systemd FZF_DEFAULT_OPTS set"
fi

# Enable gcr-ssh-agent socket (lazy-activated; provides SSH_AUTH_SOCK at
# $XDG_RUNTIME_DIR/gcr/ssh). environment.d/ssh-agent.conf points SSH_AUTH_SOCK
# and SSH_ASKPASS at this socket + the TUI arch-askpass.
if systemctl --user list-unit-files gcr-ssh-agent.socket >/dev/null 2>&1; then
  systemctl --user enable --now gcr-ssh-agent.socket 2>/dev/null \
    && gray "  gcr-ssh-agent.socket enabled" \
    || gray "  gcr-ssh-agent.socket: already enabled or failed (check 'systemctl --user status gcr-ssh-agent.socket')"
fi

# GTK / libadwaita theme
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'  || true
gsettings set org.gnome.desktop.interface accent-color 'slate'         || true
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'         || true
gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'       || true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'     || true
gray "  gsettings applied (color-scheme=prefer-dark, accent=slate, icons/cursor=Adwaita)"

# GTK 3 & 4 settings.ini (not in repo — written in place)
for ver in 3.0 4.0; do
  d=$HOME/.config/gtk-$ver
  mkdir -p "$d"
  cat > "$d/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Adwaita
gtk-cursor-theme-name=Adwaita
EOF
done
gray "  gtk-3.0 + gtk-4.0 settings.ini written"

cyan "[6/7] Install SDDM stone theme (login screen)"
SDDM_INSTALLER=$REPO/sddm-theme-stone/install.sh
if [[ -x $SDDM_INSTALLER ]]; then
  if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    sudo bash "$SDDM_INSTALLER" || red "  SDDM theme install failed (run manually: sudo bash $SDDM_INSTALLER)"
  else
    red "  Skipping — needs sudo. Run manually:  sudo bash $SDDM_INSTALLER"
  fi
else
  red "  sddm-theme-stone/install.sh missing"
fi

cyan "[7/7] Install Arch Stone Plymouth theme (boot/shutdown splash)"
PLYMOUTH_INSTALLER=$REPO/plymouth-theme-arch-stone/install.sh
if [[ -x $PLYMOUTH_INSTALLER ]]; then
  if sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    sudo bash "$PLYMOUTH_INSTALLER" || red "  Plymouth theme install failed (run manually: sudo bash $PLYMOUTH_INSTALLER)"
  else
    red "  Skipping — needs sudo. Run manually:  sudo bash $PLYMOUTH_INSTALLER"
  fi
fi

green "done. Restart waybar / walker / chromium / running terminals to pick up everything."
green "      Reboot to see new SDDM login + Plymouth boot splash."
