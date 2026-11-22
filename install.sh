#!/bin/bash
# install.sh — wire this repo into ~/.config/, ~/.local/bin/, and system theme.
# Idempotent: existing files/dirs are timestamp-backed-up before linking.

set -e
REPO=$(dirname "$(readlink -f "$0")")
TS=$(date +%s)

source "$REPO/lib/colors.sh"

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
for name in alacritty arch-menu btop elephant environment.d fastfetch fish hypr mako nvim swayosd walker waybar xdg-desktop-portal xdg-desktop-portal-termfilechooser; do
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

# Launchers (.desktop) shipped by the repo: walker / the spot launcher list them.
mkdir -p "$HOME/.local/share/applications"
for f in "$REPO/applications"/*.desktop; do
  [[ -e $f ]] || continue
  link_to "$f" "$HOME/.local/share/applications/$(basename "$f")"
done

# Omarchy leftovers in ~/.local/share/applications:
# - "Disk Usage.desktop" ran `dust -r` in a fake TUI.float terminal (xdg-terminal-exec
#   ignores that class); applications/arch-disk.desktop replaces it. Only the
#   Omarchy one is moved aside, identified by its command.
legacy="$HOME/.local/share/applications/Disk Usage.desktop"
if [[ -f $legacy && ! -L $legacy ]] && grep -q 'dust -r' "$legacy" && grep -q 'TUI\.float' "$legacy"; then
  mv "$legacy" "$legacy.bak.$TS"
  gray "    old Disk Usage launcher → $legacy.bak.$TS"
fi
# - web apps that still call omarchy-launch-webapp (it only resolves while
#   ~/.local/share/omarchy/bin is on PATH) -> arch-launch-webapp. Idempotent.
"$REPO/bin/arch-webapp-migrate" || red "  (webapp launcher migration failed; run arch-webapp-migrate by hand)"

# spot itself is the spot-bin AUR package (installed by bootstrap.sh); only its
# config is linked above.
if ! command -v spot >/dev/null 2>&1; then
  red "    spot not installed — yay -S spot-bin (bootstrap.sh does this)"
fi

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

# Update-check timer (feeds waybar's custom/updates module): link the units,
# reload, and enable the timer so it fires on boot + every 30 min.
if [[ -d "$REPO/systemd/user" ]]; then
  for unit in "$REPO/systemd/user"/*; do
    link_to "$unit" "$HOME/.config/systemd/user/$(basename "$unit")"
  done
  systemctl --user daemon-reload 2>/dev/null || true
  systemctl --user enable --now arch-update-check.timer 2>/dev/null \
    && gray "  arch-update-check.timer enabled" \
    || gray "  arch-update-check.timer: enable failed (check 'systemctl --user status arch-update-check.timer')"
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

# Route folders / PDFs / images at yazi, zathura and swayimg
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default yazi.desktop inode/directory || true
  xdg-mime default org.pwmt.zathura.desktop application/pdf application/epub+zip || true
  xdg-mime default swayimg.desktop \
    image/png image/jpeg image/gif image/webp image/bmp image/tiff image/x-xpixmap || true
  # drop leftovers that point at removed KDE apps
  if [[ -f $HOME/.config/mimeapps.list ]]; then
    sed -i -E '/org\.kde\.(dolphin|okular|gwenview|ark|kcalc)/d' "$HOME/.config/mimeapps.list"
  fi
  gray "  default apps → yazi / zathura / swayimg"

  # Spreadsheets / office docs → OnlyOffice (else Krita hijacks text/csv, etc.)
  # Flatpak build preferred; the native onlyoffice-bin entry is the fallback.
  onlyoffice=
  for id in org.onlyoffice.desktopeditors onlyoffice-desktopeditors; do
    for dir in /var/lib/flatpak/exports/share/applications "$HOME/.local/share/flatpak/exports/share/applications" /usr/share/applications; do
      [[ -f $dir/$id.desktop ]] && { onlyoffice=$id.desktop; break 2; }
    done
  done
  if [[ -n $onlyoffice ]]; then
    xdg-mime default "$onlyoffice" \
      text/csv application/csv text/comma-separated-values \
      application/vnd.oasis.opendocument.spreadsheet \
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet \
      application/vnd.ms-excel \
      application/vnd.oasis.opendocument.text \
      application/vnd.openxmlformats-officedocument.wordprocessingml.document \
      application/msword \
      application/vnd.oasis.opendocument.presentation \
      application/vnd.openxmlformats-officedocument.presentationml.presentation \
      application/vnd.ms-powerpoint || true
    gray "  office docs / csv → onlyoffice"
  fi
fi

# Lock-screen picture (hyprlock reads ~/.cache/arch-wallpaper/lock.jpg)
"$REPO/bin/arch-wallpaper" lock-sync && gray "  lock screen picture ready"

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
