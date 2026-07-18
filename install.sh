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
for name in alacritty arch-menu btop elephant environment.d fastfetch fish hypr mako nvim swayosd walker waybar; do
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

# spot is a Go binary built from the submodule; build + link only when no spot
# is already on $PATH (respects external/dev-tree installs).
if ! command -v spot >/dev/null 2>&1; then
  cyan "    spot not on \$PATH — building from $REPO/spot…"
  if ! command -v go >/dev/null 2>&1; then
    red "    go not installed; pacman -S go, then re-run install.sh"
  elif (cd "$REPO/spot" && go build -o spot . 2>&1 | tail -5); then
    green "    ✓ spot built"
    link_to "$REPO/spot/spot" "$HOME/.local/bin/spot"
  else
    red "    spot build failed — ensure gtk4 / gtk4-layer-shell / go are installed and rerun"
  fi
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

# Qt / KDE theme — Breeze Dark, to match the dark GTK look for dolphin/okular/kcalc/ark/gwenview.
# QT_STYLE_OVERRIDE=Breeze (envs.conf) picks the widget style; kdeglobals drives colours + icons.
# NOTE: outside a Plasma session there's no plasma-apply-colorscheme to resolve a scheme *name*,
# so we inline the actual palette from BreezeDark.colors (already kdeglobals format) or KDE apps
# fall back to the light default.
KDE_SCHEME=/usr/share/color-schemes/BreezeDark.colors
if [[ -f $KDE_SCHEME ]]; then
  { cat "$KDE_SCHEME"; printf '\n[Icons]\nTheme=breeze-dark\n\n[KDE]\nwidgetStyle=Breeze\n'; } \
    > "$HOME/.config/kdeglobals"
  gray "  kdeglobals written (Breeze Dark palette + breeze-dark icons)"
else
  cat > "$HOME/.config/kdeglobals" <<'EOF'
[General]
ColorScheme=BreezeDark

[Icons]
Theme=breeze-dark

[KDE]
widgetStyle=Breeze
EOF
  red "  BreezeDark.colors not found (install 'breeze') — wrote name-only kdeglobals; apps may stay light"
fi

# Route folders / PDFs / images / archives at the KDE utilities
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default org.kde.dolphin.desktop inode/directory || true
  xdg-mime default org.kde.okular.desktop application/pdf application/epub+zip || true
  xdg-mime default org.kde.gwenview.desktop \
    image/png image/jpeg image/gif image/webp image/bmp image/tiff image/x-xpixmap || true
  xdg-mime default org.kde.ark.desktop \
    application/zip application/x-tar application/gzip application/x-7z-compressed application/vnd.rar application/x-bzip2 || true
  gray "  default apps → dolphin / okular / gwenview / ark"

  # Spreadsheets / office docs → OnlyOffice (else Krita hijacks text/csv, etc.)
  if [[ -f /usr/share/applications/onlyoffice-desktopeditors.desktop ]]; then
    xdg-mime default onlyoffice-desktopeditors.desktop \
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

# KDE's "Open With" chooser builds its application tree from an XDG applications.menu.
# Minimal Hyprland installs have no /etc/xdg/menus, so the chooser shows an EMPTY list.
# Provide a user-level menu (no root needed) with a catch-all so every app appears.
if [[ ! -f /etc/xdg/menus/applications.menu ]]; then
  mkdir -p "$HOME/.config/menus"
  cat > "$HOME/.config/menus/applications.menu" <<'EOF'
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
 "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
<Menu>
    <Name>Applications</Name>
    <Directory>Applications.directory</Directory>
    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>
    <DefaultMergeDirs/>

    <Menu><Name>Accessories</Name><Directory>Utility.directory</Directory>
        <Include><And><Category>Utility</Category></And></Include></Menu>
    <Menu><Name>Development</Name><Directory>Development.directory</Directory>
        <Include><And><Category>Development</Category></And></Include></Menu>
    <Menu><Name>Graphics</Name><Directory>Graphics.directory</Directory>
        <Include><And><Category>Graphics</Category></And></Include></Menu>
    <Menu><Name>Internet</Name><Directory>Network.directory</Directory>
        <Include><And><Category>Network</Category></And></Include></Menu>
    <Menu><Name>Multimedia</Name><Directory>AudioVideo.directory</Directory>
        <Include><And><Category>AudioVideo</Category></And></Include></Menu>
    <Menu><Name>Office</Name><Directory>Office.directory</Directory>
        <Include><And><Category>Office</Category></And></Include></Menu>
    <Menu><Name>System</Name><Directory>System.directory</Directory>
        <Include><And><Category>System</Category></And></Include></Menu>
    <Menu><Name>Settings</Name><Directory>Settings.directory</Directory>
        <Include><And><Category>Settings</Category></And></Include></Menu>
    <Menu><Name>Other</Name><Directory>Other.directory</Directory>
        <OnlyUnallocated/>
        <Include><And><Not><Category>Core</Category></Not>
            <Not><Category>Screensaver</Category></Not></And></Include></Menu>
</Menu>
EOF
  gray "  ~/.config/menus/applications.menu written (KDE open-with tree)"
fi

# KDE reads its own service cache (ksycoca), not mimeapps.list, for the "Open With" list
# and default-handler resolution. A stale cache shows an EMPTY app chooser — rebuild it.
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
  gray "  ksycoca rebuilt (KDE open-with / default handlers)"
fi

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
