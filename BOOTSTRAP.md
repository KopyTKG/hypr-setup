# BOOTSTRAP

This repo's `setup.sh` only handles the **user-config layer** — packages, dotfiles
in `~/.config/`, dev tools via mise. A working Hyprland desktop also needs a
**system layer**: greeter, session orchestration, networking, polkit, audio,
keyring, etc. This document describes that layer and what
[`bootstrap-system.sh`](./bootstrap-system.sh) automates.

The choices below mirror what [Omarchy](https://omarchy.org/) does at install
time. They're opinionated but well-tested. Where this repo's existing
`packages/pacman.txt` makes a different call (NetworkManager,
hyprpolkitagent), it's flagged as **delta** below.

---

## The stack at a glance

| Layer | Choice |
|-------|--------|
| Distro base | Arch Linux, BTRFS root |
| Bootloader | Limine (EFI) with UKI + EFI fallback |
| Initramfs | mkinitcpio with `plymouth`, `encrypt`, `btrfs-overlayfs` hooks |
| Boot splash | Plymouth (custom theme) |
| Snapshots | Snapper (root only), `limine-snapper-sync` |
| Greeter | SDDM with autologin |
| Session manager | **uwsm** (Universal Wayland Session Manager) |
| Compositor | Hyprland |
| Seats / login | systemd-logind (no seatd) |
| Polkit agent | polkit-gnome — *delta: repo currently uses `hyprpolkitagent`* |
| Keyring | gnome-keyring (passwordless Default keyring) |
| XDG portals | `xdg-desktop-portal-hyprland` + `xdg-desktop-portal-gtk` |
| Audio | PipeWire + WirePlumber + pipewire-pulse + pipewire-jack |
| Network | systemd-networkd + systemd-resolved + **iwd** — *delta: repo currently uses `networkmanager`* |
| Bluetooth | bluez |
| Printing | CUPS + cups-browsed + cups-pdf |
| Discovery | avahi + nss-mdns |
| Power | power-profiles-daemon |
| Firewall | ufw (+ ufw-docker if Docker installed) |
| Time | systemd-timesyncd |
| Containers | docker + docker-buildx + docker-compose |
| Repos | pacman + yay; Chaotic-AUR optional |

---

## What `bootstrap-system.sh` automates

Run after `setup.sh` (user configs) is in place. The script is idempotent —
re-run safely.

```bash
./bootstrap-system.sh                    # everything
./bootstrap-system.sh --dry-run          # preview, change nothing
./bootstrap-system.sh --no-autologin     # SDDM but no autologin entry
./bootstrap-system.sh --skip-network     # leave network stack alone
./bootstrap-system.sh --skip-sddm        # don't touch greeter
./bootstrap-system.sh --skip-keyring     # don't write Default keyring
./bootstrap-system.sh --skip-services    # don't enable any units
./bootstrap-system.sh --skip-packages    # assume packages already installed
```

It does:

1. **Packages** from [`packages/system.txt`](./packages/system.txt):
   `sddm`, `uwsm`, `iwd`, `openresolv`, `bluez`, `cups*`, `avahi`,
   `nss-mdns`, `gnome-keyring`, `polkit-gnome`, `xdg-desktop-portal-gtk`,
   `ufw`, `power-profiles-daemon`, `plymouth`, `snapper`.
2. **Network drop-ins** at `/etc/systemd/network/20-{ethernet,wlan}.network`
   (DHCP + IPv6 privacy + mDNS + sane route metrics).
3. **Masks** `systemd-networkd-wait-online.service` so boot doesn't block
   on the network coming up.
4. **Symlinks** `/etc/resolv.conf` → `/run/systemd/resolve/stub-resolv.conf`.
5. **Wayland session entry** at `/usr/local/share/wayland-sessions/hyprland-uwsm.desktop`,
   `Exec=uwsm start -g -1 -e -D Hyprland hyprland.desktop`.
6. **SDDM autologin** at `/etc/sddm.conf.d/autologin.conf` (skip with `--no-autologin`).
7. **Patches `/etc/pam.d/sddm`** — strips `pam_gnome_keyring.so` from auth +
   password stacks. Without this, SDDM creates an encrypted login keyring
   that fights the passwordless Default keyring.
8. **Enables system services**: `systemd-{networkd,resolved,timesyncd}`,
   `iwd`, `bluetooth`, `cups`, `avahi-daemon`, `power-profiles-daemon`,
   `ufw`, `sddm`.
9. **Enables user services**: `pipewire.socket`, `pipewire-pulse.socket`,
   `wireplumber.service`, `gnome-keyring-daemon.socket`.
10. **Passwordless Default keyring** at `~/.local/share/keyrings/`.

Detects and warns on:
- `networkmanager` installed alongside `iwd` — they will fight over Wi-Fi.
- `hyprpolkitagent` installed alongside `polkit-gnome` — pick one autostart.

---

## What stays manual

These are intentionally out of scope: too system-specific or too risky to
automate generically. Inspect Omarchy's install scripts under
`~/.local/share/omarchy/install/` for full reference implementations.

### Bootloader (Limine + UKI)

Reference: `~/.local/share/omarchy/install/login/limine-snapper.sh` and
`~/.local/share/omarchy/default/limine/`.

Sketch:

```bash
# After base Arch + limine package installed:
sudo cp ~/omarchy-config/.../limine.conf /boot/limine.conf
sudo cp ~/omarchy-config/.../default-limine.conf /etc/default/limine
sudo pacman -S --needed limine-snapper-sync limine-mkinitcpio-hook
# limine-mkinitcpio-hook triggers UKI rebuild on install; no manual step needed.
```

### mkinitcpio hooks

Omarchy uses:

```
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap
       consolefont block encrypt filesystems fsck btrfs-overlayfs)
MODULES+=(thunderbolt)
```

Drop into `/etc/mkinitcpio.conf.d/omarchy_hooks.conf` (or your own name). Then
`sudo mkinitcpio -P`. **Verify on a non-production machine first** — wrong
HOOKS = unbootable system.

### Snapper (BTRFS snapshots)

```bash
sudo snapper -c root create-config /
sudo cp ~/.local/share/omarchy/default/snapper/root /etc/snapper/configs/root
sudo btrfs quota disable /                       # quota accounting is slow
sudo systemctl enable --now limine-snapper-sync.service
```

Snapshot `/` only — `/home` is user data and rolling it back loses work.

### Plymouth theme

```bash
sudo cp -r ~/.local/share/omarchy/default/plymouth /usr/share/plymouth/themes/omarchy/
sudo plymouth-set-default-theme omarchy
sudo mkinitcpio -P
```

Requires `plymouth` in mkinitcpio HOOKS.

### Hibernation

Reference: `omarchy-hibernation-setup` script. Needs sufficient swap
(file or partition), `resume=` cmdline param, and the `resume` mkinitcpio
hook. Highly machine-specific — don't generalize.

### Hardware fixes

Omarchy ships dozens of one-off scripts under `install/config/hardware/`
(asus, intel, dell, framework, apple, surface, …). Cherry-pick what your
target hardware needs; do not bulk-apply.

### Chaotic-AUR (optional)

```bash
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
# Append to /etc/pacman.conf:
# [chaotic-aur]
# Include = /etc/pacman.d/chaotic-mirrorlist
```

---

## Deltas vs the user-app layer

`packages/pacman.txt` was authored before this bootstrap. Two entries clash
with Omarchy's system-layer choices:

- **`networkmanager`, `network-manager-applet`** — remove if you want
  Omarchy's `iwd + networkd + resolved` stack. Otherwise pass
  `--skip-network` to `bootstrap-system.sh` and don't install `iwd`.
- **`hyprpolkitagent`** — Omarchy uses `polkit-gnome`. Both work.
  Keep one autostart entry; running both is harmless but redundant.

Either reconcile `packages/pacman.txt` to match this bootstrap, or run with
the appropriate `--skip-*` flags.

---

## Recommended install order on a fresh Arch system

1. Base Arch install (archinstall or manual). Pick BTRFS root if you want
   snapshots. Get any user account created.
2. Bootloader / initramfs choices (see "What stays manual" above) —
   ideally before first boot into the new environment.
3. `git clone` this repo into `~/`.
4. `./setup.sh` — packages, user configs, dev tools, webapps.
5. `./bootstrap-system.sh` — system services, greeter, network, keyring.
6. (Optional) plymouth theme, snapper, hibernation, hardware fixes.
7. Reboot.

---

## Reference

- Omarchy install scripts: `~/.local/share/omarchy/install/`
- Omarchy default configs: `~/.local/share/omarchy/default/`
- Hyprland wiki: <https://wiki.hypr.land/>
- uwsm: <https://github.com/Vladimir-csp/uwsm>
- Limine: <https://github.com/limine-bootloader/limine>
- Snapper + BTRFS: <https://wiki.archlinux.org/title/Snapper>
