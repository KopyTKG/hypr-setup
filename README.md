# hypr-setup

Personal Arch + Hyprland setup. Vanilla — no Omarchy/distro overlays. Tailwind **stone** monochrome palette across every UI surface; ANSI/syntax colors preserved.

## Layout

```
alacritty/                 terminal config (stone chrome, full ANSI palette)
btop/                      stone theme
bin/                       arch-* helper scripts (linked into ~/.local/bin)
chromium/                  flags + system policy for browser theme color
elephant/                  walker data provider config
environment.d/             systemd user env (FZF_DEFAULT_OPTS, ...)
fastfetch/                 system info (no Omarchy branding)
hypr/                      Hyprland config (inputs, monitors, windowrules, binds)
mako/                      notification daemon (stone-styled)
plymouth-theme-arch-stone/ boot/shutdown splash (Arch logo on stone-950)
sddm-theme-stone/          Qt6 login-screen theme
swayosd/                   audio/brightness OSD
walker/                    launcher (dmenu mode for arch-menu)
waybar/                    status bar + tray-menu CSS
install.sh                 wire everything into ~/.config/, ~/.local/bin/, system theme
arch-strip-omarchy-system.sh  one-shot system migrator (snapper snapshot, repo strip, AUR rebuild)
```

## Requirements

Everything lives in `extra`, `multilib`, or `chaotic-aur`. The migrator (`arch-strip-omarchy-system.sh`) wires up `chaotic-aur` automatically; on a fresh box add it manually first.

**Hyprland session** — `hyprland` `hypridle` `hyprlock` `hyprpicker` `hyprshot` `hyprsunset` `uwsm` `xdg-desktop-portal-hyprland` `sddm` `polkit-gnome` `plymouth`

**Bar / launcher / notifications** — `waybar` `walker` `elephant` `mako` `swaybg` `swayosd`

**Terminal & CLI** — `alacritty` (every `arch-*` installer + TUI runs here under `--class arch-*`) · `xdg-terminal-exec` · `fzf` `gum` `jq` `python` (all four required by the helper scripts) · `neovim` · `fastfetch`

**Waybar tray TUIs** — `btop` (CPU/mem) · `bluetui` + `bluez bluez-utils` (bluetooth) · `impala` + `iwd` (wifi) · `wiremix` (audio)

**Audio / input / misc** — `pipewire-pulse` (provides `pactl`) · `brightnessctl` · `libnotify` (`notify-send`) · `fcitx5`

**Fonts** — `ttf-cascadia-mono-nerd` (hard-coded in waybar + alacritty)

**Apps reached from default keybinds** — `chromium` (used by `arch-launch-webapp` + the Enterprise theme policy; `brave` works as a swap) · `nautilus` · optional: `discord-canary` `spotify`

**Installer / migrator only** — `yay` (AUR helper for `term_install`) · `mise` (Development install menu) · `snapper` (pre-migration snapshot)

**AMD + Steam** — `vulkan-radeon` `lib32-vulkan-radeon` `mesa-utils` (no RADV ⇒ no DXVK ⇒ Proton/Unity games fail at graphics init)

One-shot bootstrap:

```bash
sudo pacman -S --needed \
  hyprland hypridle hyprlock hyprpicker hyprshot hyprsunset uwsm \
  xdg-desktop-portal-hyprland sddm polkit-gnome plymouth \
  waybar mako swaybg swayosd \
  alacritty xdg-terminal-exec fzf gum jq python neovim fastfetch \
  btop libnotify brightnessctl fcitx5 pipewire-pulse \
  bluez bluez-utils iwd \
  ttf-cascadia-mono-nerd \
  chromium nautilus
yay -S walker elephant bluetui impala wiremix   # if not in chaotic-aur yet
```

## Install

```bash
git clone git@gitlab.com:kopytkg/hypr-setup.git ~/Projects/hypr-setup
cd ~/Projects/hypr-setup
./install.sh
```

7-phase bootstrap:

1. Symlink config dirs into `~/.config/`
2. Symlink standalone files (`chromium-flags.conf`)
3. Symlink `bin/arch-*` into `~/.local/bin/`
4. Apply system-wide Chromium / Brave theme policy (writes `/etc/{chromium,brave}/policies/managed/color.json`)
5. Push `FZF_DEFAULT_OPTS` to live systemd user env + write GTK dark-theme settings
6. Install SDDM stone theme (login screen) — needs sudo
7. Install Arch Stone Plymouth theme (boot splash) — needs sudo, rebuilds initramfs

Existing files are backed up to `<path>.bak.<timestamp>` before linking.

## arch-menu (SUPER+ALT+SPACE)

Hierarchical walker-dmenu launcher. Top level: **Apps · Learn · Capture · Toggle · Setup · Install · System · Power**.

Notable submenus:

- **Install** — fzf-driven installers for Pacman / AUR / Development (mise) / Gaming / Terminal / Font / **Webapp** (create or remove a chromium `--app` desktop launcher) / **ProtonGE** (fzf-pick any GE-Proton release, download into `~/.steam/root/compatibilitytools.d/`)
- **System** — TUI control panels via floating alacritty: bluetui, impala, wiremix, btop
- **Power** — sleep / lock / logout / restart / shutdown

## arch-* helpers

All under `bin/`, linked into `~/.local/bin/`. Examples:

| script                          | purpose                                                            |
| ------------------------------- | ------------------------------------------------------------------ |
| `arch-menu`                     | the hierarchical launcher (SUPER+ALT+SPACE)                        |
| `arch-pacman-install`           | fzf-pick a pacman package from the package list                    |
| `arch-aur-install`              | fzf-pick an AUR package                                            |
| `arch-protonge-install`         | fzf-pick a GE-Proton release; downloads + sha512-verifies + extracts |
| `arch-webapp-install`           | gum prompt → desktop launcher for any URL via chromium `--app`     |
| `arch-power-menu`               | bound to SUPER+ESC                                                 |
| `arch-killactive`               | SUPER+W; closes walker layer if visible, else `killactive`         |
| `arch-launch-webapp <class> <url>` | focus existing chromium-app window by class, else launch it    |
| `arch-apply-browser-theme`      | copy `chromium/policies/managed/color.json` to system policy dir   |

## Themes

Stone palette (`#0c0a09` bg, `#f5f5f4` border, `#fafaf9` fg, `#a8a29e` muted) is used everywhere:

- **Hyprland** — `looknfeel.conf` overrides for border / opacity / dim
- **Waybar** — pill bg `rgba(28,25,23,0.7)` with `stone-100 @ 50%` border, matching tooltip + tray menu styles
- **Walker** — solid stone-900 box-wrapper
- **Alacritty** — stone chrome (`primary/cursor/selection/...`); ANSI 16 colors preserved (Tokyo Night)
- **Btop / Mako / SwayOSD** — same chrome
- **Fastfetch** — Arch logo, no Omarchy branding
- **Chromium / Brave** — `BrowserThemeColor = #0a0a0a` via Enterprise Policy
- **SDDM** — `sddm-theme-stone` Qt6 theme (single password field, time/date, hostname)
- **Plymouth** — `arch-stone` (cloned omarchy script with stone-950 bg + Arch logo)

## System migrator

`arch-strip-omarchy-system.sh` — one-shot script that:

1. Snapper snapshot for rollback safety
2. Switches SDDM session to `hyprland-uwsm`
3. Removes the omarchy SDDM theme + repo branding
4. Strips `[omarchy]` from `pacman.conf`, restores Arch mirrorlist
5. Sets up `chaotic-aur`
6. `yay -S`s the ~23 AUR packages we still need (with `xdg-terminal-exec` → `-git` rename handling)

## Conventions

- `bin/arch-*` scripts are namespaced replacements for the previous `omarchy-*` calls
- All Hyprland config errors gated on v0.54.3 (`pseudotile` / `col.border_locked_*` are commented out in `hypr/defaults/looknfeel.conf`)
- Steam compatibility tools install path: `~/.steam/root/compatibilitytools.d/`
- AMD requires `vulkan-radeon` + `lib32-vulkan-radeon` for Proton games (no RADV = no DXVK = no Unity)
