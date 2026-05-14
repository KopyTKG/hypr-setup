#!/bin/bash
# Install the Arch Stone Plymouth theme. Needs sudo (writes to /usr/share + initramfs).
set -e
[[ $EUID -eq 0 ]] || { echo "Run with sudo" >&2; exit 1; }
REPO=$(dirname "$(readlink -f "$0")")
TARGET=/usr/share/plymouth/themes/arch-stone
[[ -L $TARGET || -e $TARGET ]] && rm -rf "$TARGET"
ln -s "$REPO" "$TARGET"
echo "  symlinked: $TARGET → $REPO"
plymouth-set-default-theme -R arch-stone
echo "  set as default + rebuilt initramfs"
