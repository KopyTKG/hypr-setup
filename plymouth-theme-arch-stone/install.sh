#!/bin/bash
# Install the Arch Stone Plymouth theme. Needs sudo (writes to /usr/share + initramfs).
set -e
[[ $EUID -eq 0 ]] || { echo "Run with sudo" >&2; exit 1; }
REPO=$(dirname "$(readlink -f "$0")")
TARGET=/usr/share/plymouth/themes/arch-stone
[[ -L $TARGET || -e $TARGET ]] && rm -rf "$TARGET"
# copy instead of symlink — keeps the theme readable for tools that don't run as root
cp -rL "$REPO" "$TARGET"
chown -R root:root "$TARGET"
chmod -R a+rX "$TARGET"
echo "  copied: $REPO → $TARGET"
plymouth-set-default-theme -R arch-stone
echo "  set as default + rebuilt initramfs"
