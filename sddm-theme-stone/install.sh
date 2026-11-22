#!/bin/bash
# Install the Stone Monochrome SDDM theme.
# Symlinks the theme dir from the repo into /usr/share/sddm/themes/ and points SDDM at it.
# Run with sudo: sudo bash install.sh

set -e
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash $0" >&2; exit 1; }

REPO_THEME=$(dirname "$(readlink -f "$0")")
TARGET=/usr/share/sddm/themes/stone

# 1. Copy theme dir (NOT symlink — sddm user can't traverse /home/$USER which is mode 700)
if [[ -L $TARGET || -e $TARGET ]]; then
  rm -rf "$TARGET"
fi
cp -rL "$REPO_THEME" "$TARGET"
chown -R root:root "$TARGET"
chmod -R a+rX "$TARGET"
echo "  copied: $REPO_THEME → $TARGET"

# 2. Tell SDDM to use it
CONF=/etc/sddm.conf.d/theme.conf
mkdir -p /etc/sddm.conf.d
cat > "$CONF" <<'EOF'
[Theme]
Current=stone
EOF
echo "  wrote: $CONF"

# 3. Greeter compositor config: Hyprland now reads Lua, so the old hyprlang
#    /usr/share/sddm/hyprland.conf fails ("unexpected symbol near '#'").
install -Dm644 "$REPO_THEME/hyprland-greeter.lua" /usr/share/sddm/hyprland.lua
cat > /etc/sddm.conf.d/10-wayland.conf <<'EOF2'
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=start-hyprland -- --config /usr/share/sddm/hyprland.lua
EOF2
echo "  wrote: /usr/share/sddm/hyprland.lua + /etc/sddm.conf.d/10-wayland.conf"

echo
echo "Done. Reboot or restart sddm to see the new login screen:"
echo "  sudo systemctl restart sddm"
