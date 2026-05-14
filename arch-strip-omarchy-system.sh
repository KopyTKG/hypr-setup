#!/bin/bash
# Strips the system-level omarchy traces: login screen branding + pacman repos.
# Leaves ~/.local/share/omarchy/ and ~/.config/omarchy/ on disk (keep for now).
#
# Usage:  sudo bash arch-strip-omarchy-system.sh

set -e
TS=$(date +%s)

if [[ $EUID -ne 0 ]]; then
  echo "Must be run as root. Run: sudo bash $0" >&2
  exit 1
fi

backup() { cp -a "$1" "$1.bak.$TS"; }

# ============================================================================
# [0] Safety net: btrfs snapper snapshot (if root is btrfs + snapper configured)
# ============================================================================
echo "[0/7] Pre-flight snapshot"
SNAP_TAKEN=""
if command -v snapper >/dev/null && [[ "$(findmnt -no FSTYPE /)" == "btrfs" ]]; then
  # Find which snapper config covers /
  cfg=$(snapper list-configs 2>/dev/null | awk 'NR>2 && $3=="/" {print $1; exit}')
  cfg=${cfg:-root}
  if snapper -c "$cfg" list >/dev/null 2>&1; then
    SNAP_NUM=$(snapper -c "$cfg" create --type single --description "pre-omarchy-strip" --print-number)
    SNAP_TAKEN="$cfg #$SNAP_NUM"
    echo "    ✓ snapper snapshot $SNAP_TAKEN created"
  else
    echo "    snapper installed but no config for '/' — set one up with:  snapper -c root create-config /"
    echo "    Continuing without snapshot — backups will be inline (.bak.$TS)"
  fi
else
  echo "    snapper or btrfs not available — falling back to inline .bak.$TS files"
fi

echo "[1/7] SDDM autologin → vanilla hyprland-uwsm session, drop omarchy theme"
F=/etc/sddm.conf.d/autologin.conf
backup "$F"
cat > "$F" <<EOF
[Autologin]
User=kopy
Session=hyprland-uwsm
EOF
echo "    → $F (backup: $F.bak.$TS)"

echo "[2/7] Remove /usr/share/sddm/themes/omarchy"
if [[ -d /usr/share/sddm/themes/omarchy ]]; then
  rm -rf /usr/share/sddm/themes/omarchy
  echo "    → removed"
fi

echo "[3/7] /etc/pacman.conf: drop [omarchy] custom repo"
F=/etc/pacman.conf
backup "$F"
# Delete the 3-line block: [omarchy] / SigLevel / Server = pkgs.omarchy
sed -i '/^\[omarchy\]/,/^Server = https:\/\/pkgs\.omarchy/d' "$F"
echo "    → $F (backup: $F.bak.$TS)"

echo "[4/7] Restore /etc/pacman.d/mirrorlist with real Arch mirrors"
F=/etc/pacman.d/mirrorlist
backup "$F"
cat > "$F" <<'EOF'
## Arch Linux mirrorlist — restored after Omarchy strip

## Worldwide (geo load-balanced)
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch

## Generic fallbacks
Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://archlinux.thaller.ws/$repo/os/$arch

## Tip: install reflector and run
##   sudo reflector --country YourCountry --age 12 --sort rate --save /etc/pacman.d/mirrorlist
## to get a localized, ranked mirrorlist.
EOF
echo "    → $F (backup: $F.bak.$TS)"

echo "[5/7] Ensure chaotic-aur repo is set up (idempotent)"
CHAOTIC_KEY=3056513887B78AEB
if ! pacman -Q chaotic-keyring chaotic-mirrorlist >/dev/null 2>&1; then
  echo "    importing chaotic-aur primary key + installing keyring/mirrorlist…"
  pacman-key --recv-key "$CHAOTIC_KEY" --keyserver keyserver.ubuntu.com
  pacman-key --lsign-key "$CHAOTIC_KEY"
  pacman --noconfirm -U \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
  echo "    ✓ chaotic-keyring + chaotic-mirrorlist installed"
else
  echo "    ✓ chaotic-keyring + chaotic-mirrorlist already installed"
fi

if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
  echo "    appending [chaotic-aur] block to /etc/pacman.conf"
  cat >> /etc/pacman.conf <<'PACMAN'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
PACMAN
  echo "    ✓ [chaotic-aur] added"
else
  echo "    ✓ [chaotic-aur] already in pacman.conf"
fi

echo
echo "[6/7] Rebuild AUR-available packages from AUR (so they get future updates)"
TARGET_USER=${SUDO_USER:-}
if [[ -z $TARGET_USER || $TARGET_USER == root ]]; then
  echo "    cannot determine non-root invoking user — skipping. Run manually:"
  echo "      yay -Syu --needed --aur elephant walker xdg-terminal-exec ..."
else
  pacman -Syy
  PKGS=(
    aether bun-bin cliamp python-terminaltexteffects ttf-ia-writer typora
    tzupdate ufw-docker walker xdg-terminal-exec
    elephant elephant-bluetooth elephant-calc elephant-clipboard
    elephant-desktopapplications elephant-files elephant-menus
    elephant-providerlist elephant-runner elephant-symbols elephant-todo
    elephant-unicode elephant-websearch
  )

  # Handle known omarchy → AUR-only-as-git renames. Each entry: "old-name new-name"
  RENAMES=(
    "xdg-terminal-exec xdg-terminal-exec-git"
  )
  for r in "${RENAMES[@]}"; do
    old=${r%% *}; new=${r##* }
    if pacman -Q "$old" >/dev/null 2>&1 && ! pacman -Q "$new" >/dev/null 2>&1; then
      echo "    rename: $old → $new (force-remove old, install new)"
      pacman -Rdd --noconfirm "$old" || true
      # swap in the PKGS array
      PKGS=("${PKGS[@]/$old/$new}")
    fi
  done

  echo "    rebuilding ${#PKGS[@]} packages from AUR (this can take several minutes)..."
  sudo -u "$TARGET_USER" yay -S --aur --needed --noconfirm "${PKGS[@]}" \
    || echo "    some rebuilds failed — not fatal, packages still work at the omarchy-installed version"
fi

echo "[7/7] Summary"
if [[ -n $SNAP_TAKEN ]]; then
  echo "    snapper snapshot: $SNAP_TAKEN"
  echo "    rollback:         sudo snapper rollback ${SNAP_TAKEN##*#}"
  echo "    diff vs current:  sudo snapper -c root status ${SNAP_TAKEN##*#}..0"
fi
echo "    inline backups:   /etc/*.bak.$TS  /etc/sddm.conf.d/*.bak.$TS  /etc/pacman.d/*.bak.$TS"
echo
echo "Done. Next:  sudo pacman -Syyu"
