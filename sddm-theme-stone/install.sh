#!/bin/bash
# Install the Stone Monochrome SDDM theme.
# Symlinks the theme dir from the repo into /usr/share/sddm/themes/ and points SDDM at it.
# Run with sudo: sudo bash install.sh

set -e
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo bash $0" >&2; exit 1; }

REPO_THEME=$(dirname "$(readlink -f "$0")")
TARGET=/usr/share/sddm/themes/stone

# 1. Symlink theme dir
if [[ -L $TARGET || -e $TARGET ]]; then
  rm -rf "$TARGET"
fi
ln -s "$REPO_THEME" "$TARGET"
echo "  symlinked: $TARGET → $REPO_THEME"

# 2. Tell SDDM to use it
CONF=/etc/sddm.conf.d/theme.conf
mkdir -p /etc/sddm.conf.d
cat > "$CONF" <<'EOF'
[Theme]
Current=stone
EOF
echo "  wrote: $CONF"

echo
echo "Done. Reboot or restart sddm to see the new login screen:"
echo "  sudo systemctl restart sddm"
