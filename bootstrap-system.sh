#!/usr/bin/env bash
# bootstrap-system.sh — system-layer setup for a Hyprland desktop.
#
# Mirrors the system-level choices Omarchy makes at install time, distinct
# from the user-config layer handled by setup.sh / install.sh:
#
#   - SDDM as greeter, autologin into a uwsm-launched Hyprland session
#   - systemd-networkd + systemd-resolved + iwd (no NetworkManager)
#   - PipeWire / WirePlumber user units
#   - gnome-keyring with a passwordless Default keyring
#   - polkit-gnome authentication agent
#   - bluetooth, cups, ufw, power-profiles-daemon enabled
#
# Run AFTER setup.sh has deployed user configs, or independently. Idempotent:
# re-running is safe.
#
# Usage:
#   ./bootstrap-system.sh                    # run all steps (interactive sudo)
#   ./bootstrap-system.sh --dry-run          # print actions, change nothing
#   ./bootstrap-system.sh --no-autologin     # SDDM, but no autologin entry
#   ./bootstrap-system.sh --skip-packages    # assume packages already installed
#   ./bootstrap-system.sh --skip-network     # leave existing network stack alone
#   ./bootstrap-system.sh --skip-services    # don't enable any services
#   ./bootstrap-system.sh --skip-keyring     # don't write Default keyring
#   ./bootstrap-system.sh --skip-sddm        # don't touch SDDM config
#
# What this DOES NOT do (do manually — see BOOTSTRAP.md):
#   - install or configure the bootloader (limine / systemd-boot / grub)
#   - modify /etc/mkinitcpio.conf{.d} HOOKS
#   - set up snapper root config or limine-snapper-sync
#   - configure hibernation / resume hooks
#   - apply per-hardware fixes (nvidia, asus, intel, ...)
#   - set up the plymouth theme

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY=false
SKIP_PACKAGES=false
SKIP_NETWORK=false
SKIP_SERVICES=false
SKIP_KEYRING=false
SKIP_SDDM=false
AUTOLOGIN=true

for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY=true ;;
    --skip-packages) SKIP_PACKAGES=true ;;
    --skip-network) SKIP_NETWORK=true ;;
    --skip-services) SKIP_SERVICES=true ;;
    --skip-keyring) SKIP_KEYRING=true ;;
    --skip-sddm) SKIP_SDDM=true ;;
    --no-autologin) AUTOLOGIN=false ;;
    -h|--help)
      sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown arg: $arg" >&2
      exit 1
      ;;
  esac
done

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
  echo "Run as a regular user; sudo is invoked when needed." >&2
  exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
  echo "This bootstrap targets Arch Linux. pacman not found." >&2
  exit 1
fi

run() { if $DRY; then echo "DRY: $*"; else "$@"; fi; }
say() { printf '\n>> %s\n' "$*"; }
note() { printf '   %s\n' "$*"; }

write_file() {
  # write_file <path> <<<"contents"  — uses sudo, idempotent (skips if identical)
  local path="$1"
  local content
  content="$(cat)"
  if [ -f "$path" ] && [ "$(sudo cat "$path" 2>/dev/null)" = "$content" ]; then
    note "unchanged: $path"
    return
  fi
  if $DRY; then
    note "DRY: would write $path"
    return
  fi
  sudo install -m 0644 -D /dev/null "$path"
  printf '%s\n' "$content" | sudo tee "$path" >/dev/null
  note "wrote: $path"
}

# --- 1. Packages -----------------------------------------------------------
if ! $SKIP_PACKAGES; then
  say "Installing system-layer packages from packages/system.txt"
  if [ ! -f "$REPO_DIR/packages/system.txt" ]; then
    echo "missing $REPO_DIR/packages/system.txt" >&2
    exit 1
  fi
  mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$REPO_DIR/packages/system.txt")
  if [ "${#pkgs[@]}" -gt 0 ]; then
    run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
  fi

  # Heads-up about packages in pacman.txt that conflict with Omarchy's choices.
  if pacman -Qq networkmanager >/dev/null 2>&1; then
    note "WARN: networkmanager is installed — it will compete with iwd/networkd."
    note "      Either uninstall networkmanager or use --skip-network and skip iwd."
  fi
  if pacman -Qq hyprpolkitagent >/dev/null 2>&1; then
    note "INFO: hyprpolkitagent is installed alongside polkit-gnome."
    note "      Pick one autostart entry; running both is harmless but redundant."
  fi
fi

# --- 2. Network: systemd-networkd + systemd-resolved + iwd -----------------
if ! $SKIP_NETWORK; then
  say "Configuring systemd-networkd / resolved / iwd"

  write_file /etc/systemd/network/20-ethernet.network <<'EOF'
[Match]
Name=en* eth*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes
MulticastDNS=yes

[DHCPv4]
RouteMetric=10

[IPv6AcceptRA]
RouteMetric=10
EOF

  write_file /etc/systemd/network/20-wlan.network <<'EOF'
[Match]
Name=wl*

[Network]
DHCP=yes
IPv6PrivacyExtensions=yes
MulticastDNS=yes

[DHCPv4]
RouteMetric=20

[IPv6AcceptRA]
RouteMetric=20
EOF

  # Speed up boot: don't block on network being ready.
  if ! systemctl is-enabled --quiet systemd-networkd-wait-online.service \
     || ! systemctl is-active --quiet systemd-networkd-wait-online.service; then
    : # already disabled; mask anyway to be sure
  fi
  run sudo systemctl mask systemd-networkd-wait-online.service

  # Point /etc/resolv.conf at systemd-resolved.
  if [ ! -L /etc/resolv.conf ] || \
     [ "$(readlink /etc/resolv.conf 2>/dev/null)" != "/run/systemd/resolve/stub-resolv.conf" ]; then
    run sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    note "linked /etc/resolv.conf -> stub-resolv.conf"
  else
    note "resolv.conf already linked to stub-resolv.conf"
  fi
fi

# --- 3. Wayland session file for SDDM --------------------------------------
if ! $SKIP_SDDM; then
  say "Installing Wayland session entry for uwsm-launched Hyprland"
  write_file /usr/local/share/wayland-sessions/hyprland-uwsm.desktop <<'EOF'
[Desktop Entry]
Name=Hyprland (uwsm)
Comment=Hyprland session managed by uwsm
Exec=uwsm start -g -1 -e -D Hyprland hyprland.desktop
TryExec=uwsm
Type=Application
EOF

  # Autologin block (optional).
  if $AUTOLOGIN; then
    say "Configuring SDDM autologin for $USER -> hyprland-uwsm session"
    write_file /etc/sddm.conf.d/autologin.conf <<EOF
[Autologin]
User=$USER
Session=hyprland-uwsm
EOF
  else
    note "autologin disabled (--no-autologin); remove /etc/sddm.conf.d/autologin.conf manually if it exists"
  fi

  # Strip pam_gnome_keyring from SDDM PAM stack so it doesn't create an
  # encrypted login keyring that conflicts with our passwordless Default keyring.
  # Idempotent: deletion is a no-op if the lines aren't present.
  say "Patching /etc/pam.d/sddm (remove pam_gnome_keyring lines)"
  if [ -f /etc/pam.d/sddm ]; then
    if grep -qE '(-auth|-password).*pam_gnome_keyring\.so' /etc/pam.d/sddm; then
      run sudo cp /etc/pam.d/sddm "/etc/pam.d/sddm.bak.$(date +%s)"
      run sudo sed -i '/^-auth.*pam_gnome_keyring\.so/d; /^-password.*pam_gnome_keyring\.so/d' /etc/pam.d/sddm
      note "patched /etc/pam.d/sddm"
    else
      note "/etc/pam.d/sddm already clean"
    fi
  else
    note "/etc/pam.d/sddm not found yet (sddm will install it)"
  fi
fi

# --- 4. Services -----------------------------------------------------------
if ! $SKIP_SERVICES; then
  enable_unit() {
    local unit="$1" scope="${2:-system}"
    if [ "$scope" = "user" ]; then
      if systemctl --user is-enabled --quiet "$unit" 2>/dev/null; then
        note "user already enabled: $unit"; return
      fi
      run systemctl --user enable "$unit"
    else
      if sudo systemctl is-enabled --quiet "$unit" 2>/dev/null; then
        note "already enabled: $unit"; return
      fi
      run sudo systemctl enable "$unit"
    fi
  }

  say "Enabling system services"
  enable_unit systemd-networkd.service
  enable_unit systemd-resolved.service
  enable_unit systemd-timesyncd.service
  enable_unit iwd.service
  enable_unit bluetooth.service
  enable_unit cups.service
  enable_unit avahi-daemon.service
  enable_unit power-profiles-daemon.service
  enable_unit ufw.service
  if ! $SKIP_SDDM; then
    enable_unit sddm.service
  fi

  say "Enabling user services (PipeWire stack + gnome-keyring socket)"
  enable_unit pipewire.socket user
  enable_unit pipewire-pulse.socket user
  enable_unit wireplumber.service user
  enable_unit gnome-keyring-daemon.socket user
fi

# --- 5. Passwordless Default keyring ---------------------------------------
if ! $SKIP_KEYRING; then
  say "Setting up passwordless Default keyring"
  KEYRING_DIR="$HOME/.local/share/keyrings"
  KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
  DEFAULT_FILE="$KEYRING_DIR/default"

  if [ -f "$KEYRING_FILE" ] && [ -f "$DEFAULT_FILE" ] && \
     grep -q '^Default_keyring$' "$DEFAULT_FILE" 2>/dev/null; then
    note "keyring already configured at $KEYRING_DIR"
  else
    if $DRY; then
      note "DRY: would create $KEYRING_FILE and $DEFAULT_FILE"
    else
      mkdir -p "$KEYRING_DIR"
      cat >"$KEYRING_FILE" <<EOF
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF
      printf 'Default_keyring\n' >"$DEFAULT_FILE"
      chmod 700 "$KEYRING_DIR"
      chmod 600 "$KEYRING_FILE"
      chmod 644 "$DEFAULT_FILE"
      note "created $KEYRING_FILE"
    fi
  fi
fi

# --- 6. Done ---------------------------------------------------------------
echo ""
if $DRY; then
  echo "Dry run complete."
  exit 0
fi

cat <<EOF

Done. Next steps:

  - Reboot, or:
      sudo systemctl start systemd-networkd systemd-resolved iwd bluetooth cups
      systemctl --user start pipewire pipewire-pulse wireplumber gnome-keyring-daemon.socket

  - SDDM is enabled but not started. Either reboot or:
      sudo systemctl start sddm

  - For optional pieces (limine + snapper, plymouth theme, hibernation,
    mkinitcpio HOOKS, hardware fixes), see BOOTSTRAP.md.

EOF
