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
hypr/                      Hyprland Lua config (hyprland.lua → defaults/ + personal overrides) + hyprlock/hypridle
arch-menu/                 user-editable arch-menu config (bookmarks.conf)
mako/                      notification daemon (stone-styled)
nvim/                      submodule → gitlab.com/kopytkg/nvim
spot/                      submodule → gitlab.com/kopytkg/spot (TOML+CSS dialog runtime)
spot-config/               linked into ~/.config/spot/ (menu, power, password, keyboard, …)
plymouth-theme-arch-stone/ boot/shutdown splash (Arch logo on stone-950)
sddm-theme-stone/          Qt6 login-screen theme
swayosd/                   audio/brightness OSD
walker/                    launcher (dmenu mode for arch-menu)
waybar/                    status bar + tray-menu CSS
bash/                      interactive bash config — boot .bashrc + 8 topic files (env, shell opts, aliases, dev stack, utils, tools, prompt)
starship.toml              starship prompt (Tokyo Night, current dev stack)
bootstrap.sh               vanilla Arch → desktop: yay, pacman/AUR, GPU pick, services, install.sh
install.sh                 wire everything into ~/.config/, ~/.local/bin/, system theme
arch-strip-omarchy-system.sh  one-shot system migrator (snapper snapshot, repo strip, AUR rebuild)
```

## Requirements

Everything lives in `extra`, `multilib`, or `chaotic-aur`. The migrator (`arch-strip-omarchy-system.sh`) wires up `chaotic-aur` automatically; on a fresh box add it manually first.

**Hyprland session** — `hyprland` `hypridle` `hyprlock` `hyprpicker` `hyprshot` `hyprsunset` `uwsm` `xdg-desktop-portal-hyprland` `sddm` `polkit-kde-agent` `plymouth`

**Bar / launcher / notifications** — `waybar` `walker` `elephant` `mako` `swaybg` `swayosd`

**Terminal & CLI** — `alacritty` (every `arch-*` installer + TUI runs here under `--class arch-*`) · `xdg-terminal-exec` · `fzf` `gum` `jq` `python` (all four required by the helper scripts) · `neovim` · `fastfetch` · `starship` (prompt) · `bash-completion` · `git` `openssh` `curl` `tar` `wl-clipboard`

**Waybar tray TUIs** — `btop` (CPU/mem) · `bluetui` + `bluez bluez-utils` (bluetooth) · `impala` + `iwd` (wifi) · `wiremix` (audio) · `yazi` (file manager, arch-menu → System → Files)

**Audio / input / misc** — `pipewire-pulse` (provides `pactl`) · `brightnessctl` · `libnotify` (`notify-send`) · `fcitx5`

**Fonts** — `ttf-cascadia-mono-nerd` (hard-coded in waybar + alacritty)

**Shell QoL (referenced by `.bashrc`)** — `lazygit` (alias `lz`) · `eza` · `bat` · `fd` (powers `FZF_DEFAULT_COMMAND`) · `ripgrep` · `git-delta` · `tree` · `net-tools` (`netstat`) · `lsof`

**Keyring / SSH agent** — `gnome-keyring` (PAM unlock at SDDM login) · `libsecret` (`secret-tool`, used by `arch-askpass` for passphrase caching) · `gcr-4` (provides `gcr-ssh-agent.socket`, the user systemd ssh-agent)

**Dev toolchains (work stack)** — most are managed by `mise` (`mise use --global …`); pacman covers the rest: `jdk-openjdk` `kotlin` `maven` `gradle` (Java/Kotlin/Android) · `texlive-meta` (LaTeX) · `bun` (RN/Expo/Preact). The Development install entry in `arch-menu` wraps `mise use --global` over a fzf-pick.

**Apps reached from default keybinds** — `chromium` (used by `arch-launch-webapp` + the Enterprise theme policy; `brave` works as a swap) · optional: `discord-canary` · `com.spotify.Client` (flatpak, SUPER+M)

**KDE utilities & Qt theme** — `dolphin` (file manager, SUPER+F) · `kcalc` (calculator key) · `okular` (PDF) · `ark` (archives) · `gwenview` (images) · `kdegraphics-thumbnailers` + `ffmpegthumbs` (dolphin thumbnails). Theming is Breeze Dark: `breeze` + `breeze-icons` supply the style/icons, `plasma-integration` supplies the Qt **platform theme** (`KDEPlasmaPlatformTheme6.so`) — without it Qt apps ignore the colour scheme and stay light. `hypr/defaults/envs.lua` sets `QT_STYLE_OVERRIDE=Breeze` + `QT_QPA_PLATFORMTHEME=kde`; `install.sh` writes the full palette to `~/.config/kdeglobals`, creates `~/.config/menus/applications.menu` (else Dolphin's "Open With" list is empty), rebuilds `kbuildsycoca6`, and points `xdg-mime` at these apps (folders/PDFs/images/archives, plus CSV + office docs → `onlyoffice`).

**Installer / migrator only** — `yay` (AUR helper for `term_install`) · `mise` (Development install menu) · `snapper` (migrator pre-snapshot + the `update` command's pre/post bracket)

**Snapshots / rollback** (btrfs root only) — `snapper` (config `root`, created by `bootstrap.sh`) · `limine-snapper-sync` (chaotic-aur — surfaces snapshots as bootable entries in the limine menu). The `update` command (a function in `bash/30-aliases.bash`) brackets every `yay -Syyu` with a snapper `pre`/`post` snapshot pair, so a bad upgrade is one boot-menu pick away from rollback.

**GPU** — picked interactively in `bootstrap.sh` phase 4. AMD: `vulkan-radeon` `lib32-vulkan-radeon` `mesa-utils` `libva-mesa-driver` (no RADV ⇒ no DXVK ⇒ Proton/Unity games fail at graphics init). Intel: `vulkan-intel` `lib32-vulkan-intel` `intel-media-driver`. Nvidia: `nvidia(-open)` `nvidia-utils` `lib32-nvidia-utils` `nvidia-settings` (+ manual Wayland env tweaks).

**Nvim submodule** — `nvim/install.sh` covers its own extras (`base-devel` `unzip` `tree-sitter-cli` `python-pip` `luarocks` `glab` …). Run it once after `./install.sh`.

One-shot bootstrap — `./bootstrap.sh` takes a vanilla Arch box (post-`pacstrap`, no DM/audio/Wayland) all the way to a working desktop. Six phases:

1. **yay** — `base-devel` + `git`, build `yay-bin` from AUR if missing
2. **pacman** — `--needed` install of the extra/multilib stack (Hyprland session, pipewire+wireplumber, qt6-wayland, xorg-xwayland, terminals, fonts, dev toolchains, keyring, tray TUIs `bluetui`/`impala`/`wiremix`, `linux-lts` + headers, …)
3. **AUR** — `walker-bin`, full `elephant-*-bin` stack, `xdg-terminal-exec-git` (prefers `-bin`/stable variants when upstream offers them; only `xdg-terminal-exec` is `-git` because no stable release exists)
4. **GPU** — `lspci` detect, then `gum choose` between **AMD** / **Intel** / **Nvidia open** / **Nvidia closed** / **Skip**
5. **Services + network** — enables `sddm`, `bluetooth`, `iwd`, `systemd-resolved`; writes `/etc/iwd/main.conf` (DHCP+DNS via systemd) and points `/etc/resolv.conf` at the systemd stub; on a btrfs root creates the snapper `root` config, enables `snapper-cleanup.timer` (prunes the `update` snapshots), and (on limine) installs + enables `limine-snapper-sync`; runs `xdg-user-dirs-update`
6. **install.sh** — symlink configs, browser policy, systemd user env, gcr-ssh-agent, SDDM + Plymouth themes

The package lists are inline at the top of `bootstrap.sh`. Re-running is safe: pacman/yay use `--needed`, services are `is-enabled`-checked, config files are only written when missing.

`linux-lts` is installed alongside whatever kernel you pacstrapped with. mkinitcpio's pacman hook auto-generates `initramfs-linux-lts.img`. The bootloader entry depends on what you use:

- **Limine** (with `limine-mkinitcpio-hook`): entry auto-added by pacman hook — no command needed. Fallback: `sudo limine-update`.
- **GRUB**: `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- **systemd-boot**: copy `/boot/loader/entries/arch.conf` → `arch-lts.conf` and replace `linux` with `linux-lts` in the `linux=`/`initrd=` lines

The final message of `bootstrap.sh` detects which bootloader you have and tells you what to do (or confirms the entry's already there for Limine).

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
5. Push `FZF_DEFAULT_OPTS` to live systemd user env + write GTK dark-theme settings, enable `gcr-ssh-agent.socket`
6. Install SDDM stone theme (login screen) — needs sudo
7. Install Arch Stone Plymouth theme (boot splash) — needs sudo, rebuilds initramfs

Existing files are backed up to `<path>.bak.<timestamp>` before linking.

## Keyring / SSH agent

`environment.d/ssh-agent.conf` points `SSH_AUTH_SOCK` at `gcr-ssh-agent` (`/run/user/UID/gcr/ssh`) and sets `SSH_ASKPASS=arch-askpass`. From a terminal (`ssh-add` typed at a shell) `arch-askpass` uses `gum input --password` inline. From a no-TTY caller (the `hyprland.start` hook in `hypr/autostart.lua`, gcr-ssh-agent, etc.) it pops `spot ~/.config/spot/password.toml` — a layer-shell GTK4 dialog with a single password field, styled with the same stone palette; the key name shows in the input placeholder.

`arch-askpass` reads/writes the keyring via `secret-tool` (libsecret). PAM unlocks the gnome-keyring at SDDM login (`pam_gnome_keyring.so auto_start` is already in `/etc/pam.d/sddm`), so:

- **First boot** — hypr's `ssh-add ~/.ssh/dev/dev_sign` on `hyprland.start` (in `hypr/autostart.lua`) triggers `arch-askpass`; a floating TUI prompt asks for the passphrase and stores it under `unique=ssh-store:<keypath>`.
- **Every later boot** — keyring is unlocked at SDDM login → `arch-askpass` returns the cached passphrase silently → keys ready before the first commit / push.

For other keys to lazy-load on first SSH use, add this to your `~/.ssh/config` (top of file, outside any `Host` block):

```
Host *
  AddKeysToAgent yes
```

## arch-menu (SUPER+ALT+SPACE)

Hierarchical menu rendered by `spot` (TOML+CSS layer-shell dialog runtime; submodule at `spot/`). Top level: **Apps · Install · Remove · Capture · Toggle · Setup · Bookmarks · System · Remote · Keybinds · Learn · Power**.

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
| `arch-askpass`                  | Password prompt (`SSH_ASKPASS`); libsecret-cached. Inline `gum` from a TTY, `spot` password dialog headless |

## Themes

Stone palette (`#0c0a09` bg, `#f5f5f4` border, `#fafaf9` fg, `#a8a29e` muted) is used everywhere:

- **Hyprland** — `looknfeel.lua` overrides for border / opacity / dim
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
- Hyprland config is Lua (0.56+; the hyprlang `.conf` format is legacy). Validate with `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua`; LSP stubs via `hypr/.luarc.json`. Scripts talk to it with `hyprctl dispatch 'hl.dsp.…'` / `hyprctl eval 'hl.config(…)'` — the old `dispatch <name> <args>` / `keyword` forms no longer work
- Steam compatibility tools install path: `~/.steam/root/compatibilitytools.d/`
- AMD requires `vulkan-radeon` + `lib32-vulkan-radeon` for Proton games (no RADV = no DXVK = no Unity)
