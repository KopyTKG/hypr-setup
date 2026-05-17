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
arch-menu/                 user-editable arch-menu config (bookmarks.conf)
mako/                      notification daemon (stone-styled)
nvim/                      submodule → gitlab.com/kopytkg/nvim
plymouth-theme-arch-stone/ boot/shutdown splash (Arch logo on stone-950)
sddm-theme-stone/          Qt6 login-screen theme
swayosd/                   audio/brightness OSD
walker/                    launcher (dmenu mode for arch-menu)
waybar/                    status bar + tray-menu CSS
.bashrc                    interactive bash config (aliases, completions, language env)
starship.toml              starship prompt (Tokyo Night, current dev stack)
bootstrap.sh               fresh-box: install yay + every required package, then run install.sh
install.sh                 wire everything into ~/.config/, ~/.local/bin/, system theme
arch-strip-omarchy-system.sh  one-shot system migrator (snapper snapshot, repo strip, AUR rebuild)
```

## Requirements

Everything lives in `extra`, `multilib`, or `chaotic-aur`. The migrator (`arch-strip-omarchy-system.sh`) wires up `chaotic-aur` automatically; on a fresh box add it manually first.

**Hyprland session** — `hyprland` `hypridle` `hyprlock` `hyprpicker` `hyprshot` `hyprsunset` `uwsm` `xdg-desktop-portal-hyprland` `sddm` `polkit-gnome` `plymouth`

**Bar / launcher / notifications** — `waybar` `walker` `elephant` `mako` `swaybg` `swayosd`

**Terminal & CLI** — `alacritty` (every `arch-*` installer + TUI runs here under `--class arch-*`) · `xdg-terminal-exec` · `fzf` `gum` `jq` `python` (all four required by the helper scripts) · `neovim` · `fastfetch` · `starship` (prompt) · `bash-completion` · `git` `openssh` `curl` `tar` `wl-clipboard`

**Waybar tray TUIs** — `btop` (CPU/mem) · `bluetui` + `bluez bluez-utils` (bluetooth) · `impala` + `iwd` (wifi) · `wiremix` (audio) · `yazi` (file manager, arch-menu → System → Files)

**Audio / input / misc** — `pipewire-pulse` (provides `pactl`) · `brightnessctl` · `libnotify` (`notify-send`) · `fcitx5`

**Fonts** — `ttf-cascadia-mono-nerd` (hard-coded in waybar + alacritty)

**Shell QoL (referenced by `.bashrc`)** — `lazygit` (alias `lz`) · `eza` · `bat` · `fd` (powers `FZF_DEFAULT_COMMAND`) · `ripgrep` · `git-delta` · `tree` · `net-tools` (`netstat`) · `lsof`

**Dev toolchains (work stack)** — most are managed by `mise` (`mise use --global …`); pacman covers the rest: `jdk-openjdk` `kotlin` `maven` `gradle` (Java/Kotlin/Android) · `texlive-meta` (LaTeX) · `bun` (RN/Expo/Preact). The Development install entry in `arch-menu` wraps `mise use --global` over a fzf-pick.

**Apps reached from default keybinds** — `chromium` (used by `arch-launch-webapp` + the Enterprise theme policy; `brave` works as a swap) · `nautilus` · optional: `discord-canary` `spotify`

**Installer / migrator only** — `yay` (AUR helper for `term_install`) · `mise` (Development install menu) · `snapper` (pre-migration snapshot)

**AMD + Steam** — `vulkan-radeon` `lib32-vulkan-radeon` `mesa-utils` (no RADV ⇒ no DXVK ⇒ Proton/Unity games fail at graphics init)

**Nvim submodule** — `nvim/install.sh` covers its own extras (`base-devel` `unzip` `tree-sitter-cli` `python-pip` `luarocks` `glab` …). Run it once after `./install.sh`.

One-shot bootstrap — `./bootstrap.sh` does all of the below in one go (installs `yay` first if missing, then `pacman -S --needed` the extra/multilib block, then `yay -S --needed` the AUR block, then runs `./install.sh`):

```bash
sudo pacman -S --needed \
  hyprland hypridle hyprlock hyprpicker hyprshot hyprsunset uwsm \
  xdg-desktop-portal-hyprland sddm polkit-gnome plymouth \
  waybar mako swaybg swayosd \
  alacritty xdg-terminal-exec fzf gum jq python neovim fastfetch starship \
  btop yazi libnotify brightnessctl fcitx5 pipewire-pulse \
  bluez bluez-utils iwd \
  ttf-cascadia-mono-nerd \
  git openssh curl tar wl-clipboard \
  lazygit eza bat fd ripgrep git-delta tree net-tools lsof \
  jdk-openjdk kotlin maven gradle texlive-meta bun \
  chromium nautilus
yay -S walker elephant bluetui impala wiremix   # if not in chaotic-aur yet
```

## Install

Fresh box (installs yay + every package + wires the configs):

```bash
git clone --recurse-submodules git@gitlab.com:kopytkg/hypr-setup.git ~/Projects/hypr-setup
cd ~/Projects/hypr-setup
./bootstrap.sh
```

Already have the packages — just wire the configs:

```bash
cd ~/Projects/hypr-setup
./install.sh
```

Already cloned without `--recurse-submodules`? Pull the submodules in:

```bash
git submodule update --init --recursive
```

Pull future nvim updates with:

```bash
git submodule update --remote nvim
```

7-phase bootstrap:

1. Symlink config dirs into `~/.config/`
2. Symlink standalone files (`chromium-flags.conf`, `.bashrc`, `starship.toml`)
3. Symlink `bin/arch-*` into `~/.local/bin/`
4. Apply system-wide Chromium / Brave theme policy (writes `/etc/{chromium,brave}/policies/managed/color.json`)
5. Push `FZF_DEFAULT_OPTS` to live systemd user env + write GTK dark-theme settings
6. Install SDDM stone theme (login screen) — needs sudo
7. Install Arch Stone Plymouth theme (boot splash) — needs sudo, rebuilds initramfs

Existing files are backed up to `<path>.bak.<timestamp>` before linking.

## arch-menu (SUPER+ALT+SPACE)

Hierarchical walker-dmenu launcher. Top level: **Apps · Install · Remove · Capture · Toggle · Setup · Bookmarks · System · Remote · Keybinds · Learn · Power**.

Notable submenus:

- **Install** — fzf-driven installers for Pacman / AUR / Development (mise) / Gaming / Terminal / Font / **Webapp** (create or remove a chromium `--app` desktop launcher) / **ProtonGE** (fzf-pick any GE-Proton release, download into `~/.steam/root/compatibilitytools.d/`)
- **Remove** — mirrors Install: Pacman (fzf over `pacman -Qq`) / AUR (foreign packages only, `pacman -Qqm`) / Webapp / Development (`mise uninstall`) / Gaming/Terminal/Font (curated `pacman -Rns`) / ProtonGE (rm from `compatibilitytools.d/`)
- **Bookmarks** — reads `~/.config/arch-menu/bookmarks.conf` (one `Label | URL` per line, `#` comments OK). Selecting opens the URL in chromium.
- **System** — TUI control panels via floating alacritty: bluetui, impala, wiremix, btop
- **Remote** — parses `~/.ssh/config` for `# group: NAME` markers; picks a group, then a host, and spawns ssh in a tiled `ssh-session` terminal. **Custom…** gum-prompts for User/Host/Port.
- **Keybinds** — also bound to SUPER+F1; fzf-list of every described Hyprland bind (live from `hyprctl binds`), colored per modifier
- **Power** — sleep / lock / logout / restart / shutdown

## arch-* helpers

All under `bin/`, linked into `~/.local/bin/`. Examples:

| script                          | purpose                                                            |
| ------------------------------- | ------------------------------------------------------------------ |
| `arch-menu`                     | the hierarchical launcher (SUPER+ALT+SPACE)                        |
| `arch-pacman-install`           | fzf-pick a pacman package from the package list                    |
| `arch-aur-install`              | fzf-pick an AUR package                                            |
| `arch-pacman-remove`            | fzf-pick installed package(s); `sudo pacman -Rns`                  |
| `arch-aur-remove`               | fzf-pick AUR-installed (foreign) package(s); `sudo pacman -Rns`    |
| `arch-mise-remove`              | fzf-pick installed mise tool@version; `mise uninstall`             |
| `arch-protonge-install`         | fzf-pick a GE-Proton release; downloads + sha512-verifies + extracts |
| `arch-protonge-remove`          | fzf-pick a GE-Proton release in `compatibilitytools.d/`; `rm -rf`  |
| `arch-webapp-install`           | gum prompt → desktop launcher for any URL via chromium `--app`     |
| `arch-webapp "<Name>"`          | launch a webapp by Name (matches `Name=` in any `~/.local/share/applications/*.desktop` whose Exec calls `arch-launch-webapp`); no args → walker picker over all discovered webapps |
| `arch-keybinds`                 | SUPER+F1; fzf-list of every Hyprland bind (colored per modifier)   |
| `arch-remote-custom`            | gum prompt → User/Host/Port → spawns ssh in a tiled `ssh-session` window |
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
- **SDDM** — `sddm-theme-stone` Qt6 theme (single password field, time/date, hostname); input is `radius: 8` (rounded-lg), border hidden idle / 1px stone-400 on focus
- **Hyprlock** — same input treatment: `rounding = 16`, `outline_thickness = 1`, outer_color stone-400 (muted)
- **Plymouth** — `arch-stone` (cloned omarchy script with stone-950 bg + Arch logo)
- **Starship** — Tokyo Night accents (purple cwd, blue branch, yellow status); language modules for Java / Kotlin / .NET / Node / Go / Docker

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
