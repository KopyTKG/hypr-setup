# hypr-setup

Personal Arch + Hyprland setup. Vanilla — no Omarchy/distro overlays. Tailwind **stone** monochrome palette across every UI surface; ANSI/syntax colors preserved.

**Keybinds:** press **SUPER+F1** for every keybind (Hyprland, dialogs, shell, terminal, editor, waybar clicks, terminal UIs; type to filter), or read [`KEYBINDS.md`](KEYBINDS.md).

## Layout

```
kitty/                     the terminal config (stone chrome, full ANSI palette; its graphics protocol drives yazi previews)
btop/                      stone theme
bin/                       arch-* helper scripts (linked into ~/.local/bin)
chromium/                  flags + system policy for browser theme color
environment.d/             systemd user env (FZF_DEFAULT_OPTS, ...)
fastfetch/                 system info (no Omarchy branding)
hypr/                      Hyprland Lua config (hyprland.lua → defaults/ + personal overrides) + hyprlock/hypridle
arch-menu/                 user-editable arch-menu config (bookmarks.conf, keybinds.conf)
mako/                      notification daemon (stone-styled)
nvim/                      submodule → gitlab.com/kopytkg/nvim
spot-config/               linked into ~/.config/spot/ (menu, power, password, keyboard, display, …)
applications/              .desktop launchers linked into ~/.local/share/applications/ (e.g. Disk Usage → arch-disk)
plymouth-theme-arch-stone/ boot/shutdown splash (Arch logo on stone-950)
sddm-theme-stone/          Qt6 login-screen theme
swayosd/                   audio/brightness OSD
waybar/                    status bar + tray-menu CSS
bash/                      interactive bash config — boot .bashrc + 8 topic files (env, shell opts, aliases, dev stack, utils, tools, prompt)
starship.toml              starship prompt (Tokyo Night, current dev stack)
bootstrap.sh               vanilla Arch → desktop: yay, pacman/AUR, GPU pick, services, install.sh
install.sh                 wire everything into ~/.config/, ~/.local/bin/, system theme
arch-strip-omarchy-system.sh  one-shot system migrator (snapper snapshot, repo strip, AUR rebuild)
```

## Requirements

Everything lives in `extra`, `multilib`, or `chaotic-aur`. The migrator (`arch-strip-omarchy-system.sh`) wires up `chaotic-aur` automatically; on a fresh box add it manually first.

**Hyprland session** — `hyprland` `hypridle` `hyprlock` `hyprpicker` `hyprshot` `hyprsunset` `uwsm` `xdg-desktop-portal-hyprland` `sddm` `hyprpolkitagent` `plymouth`

**Bar / launcher / notifications** — `waybar` `mako` `swaybg` `swayosd`

**Terminal & CLI** — `kitty` (the terminal: every `arch-*` installer + TUI runs here under `--class arch-*`; `xdg-terminals.list`, linked from the repo, makes it the terminal `xdg-terminal-exec` uses) · `xdg-terminal-exec` · `fzf` `gum` `jq` `python` (all four required by the helper scripts) · `neovim` · `fastfetch` · `starship` (prompt) · `bash-completion` · `git` `openssh` `curl` `tar` `wl-clipboard`

**Waybar tray TUIs** — `btop` (CPU/mem) · `bluetui` + `bluez bluez-utils` (bluetooth) · `impala` + `iwd` (wifi) · `wiremix` (audio) · `jolt` (battery, SUPER+CTRL+P / click battery) · `yazi` (file manager, arch-menu → System → Files)

**Audio / input / misc** — `pipewire-pulse` (provides `pactl`) · `brightnessctl` · `libnotify` (`notify-send`) · `fcitx5`

**Fonts** — `ttf-cascadia-mono-nerd` (hard-coded in waybar + kitty)

**Shell QoL (referenced by `.bashrc`)** — `lazygit` (alias `lz`) · `eza` · `bat` · `fd` (powers `FZF_DEFAULT_COMMAND`) · `ripgrep` · `git-delta` · `tree` · `net-tools` (`netstat`) · `lsof`

**Keyring / SSH agent** — `gnome-keyring` (PAM unlock at SDDM login) · `libsecret` (`secret-tool`, used by `arch-askpass` for passphrase caching) · `gcr-4` (provides `gcr-ssh-agent.socket`, the user systemd ssh-agent)

**Dev toolchains (work stack)** — most are managed by `mise` (`mise use --global …`); pacman covers the rest: `jdk-openjdk` `kotlin` `maven` `gradle` (Java/Kotlin/Android) · `texlive-meta` (LaTeX) · `bun` (RN/Expo/Preact). The Development install entry in `arch-menu` wraps `mise use --global` over a fzf-pick.

**Apps reached from default keybinds** — `chromium` (used by `arch-launch-webapp` + the Enterprise theme policy; `brave` works as a swap) · optional flatpaks: `com.discordapp.Discord` (SUPER+D) · `com.spotify.Client` (SUPER+M)

**Viewers & dialogs (no KDE)** — `zathura` + `zathura-pdf-mupdf` (PDF/epub) · `swayimg` (images) · folders open in `yazi` (SUPER+F, and as the `inode/directory` handler) · archives via the `extract` fish function / yazi · the calculator key opens `qalc` in a floating terminal. File open/save dialogs of browsers and other apps are `xdg-desktop-portal-termfilechooser` (AUR) running yazi in a floating alacritty (`xdg-desktop-portal-termfilechooser/config`, selected in `xdg-desktop-portal/hyprland-portals.conf`; restart with `systemctl --user restart xdg-desktop-portal`). Polkit prompts from GUI apps are handled by `hyprpolkitagent`; our own privileged actions use `arch-root` (spot password dialog). `install.sh` points `xdg-mime` at these apps (plus CSV + office docs → `onlyoffice`). No Qt platform theme is set; the few Qt apps left (hyprpolkitagent) style themselves.

**yazi (power setup)** — config in `yazi/` (linked to `~/.config/yazi`): stone theme, natural sort with folders first, two visible panes, files 2 : preview 8 (parent column hidden; a very wide preview for images, `T` maximizes it), git status signs, full border, owner:group in the status bar, user@host in the header. Previews: images / video thumbnails / PDFs use kitty's graphics protocol (sharp, in-terminal). Under Alacritty yazi falls back to `chafa` text blocks; `ueberzugpp` must NOT be installed (it positions its overlay window with `hyprctl keyword`, which the Lua Hyprland config does not accept, so it tiled into the layout and glitched everything); folders as an `eza` tree, Markdown via `glow`, JSON via `jq`, archives listed with `ouch`. Openers: PDF → zathura (or Chromium), images → swayimg, video/audio → mpv, archives → `ouch decompress`. Extra keys (all listed in SUPER+F1 → Terminal UIs): `l` smart enter, `T` maximize preview, `f` jump-to-char, `F` filter, `M` mount/eject disks, `cm` chmod, `cz` zip, `E` nvim, `Ctrl+G` lazygit, `Ctrl+N` drag out (ripdrag), `Alt+D` diff, `gp/gr/gv/gw/gm/gt` jump to places. Plugins are pinned in `yazi/package.toml` (from `yazi-rs/plugins`) and installed by `install.sh` with `ya pkg install`; `yazi/plugins/` is git-ignored. The same config drives the file open/save dialog.

**Installer / migrator only** — `yay` (AUR helper for `term_install`) · `mise` (Development install menu) · `snapper` (migrator pre-snapshot + the `update` command's pre/post bracket)

**Snapshots / rollback** (btrfs root only) — `snapper` (config `root`, created by `bootstrap.sh`) · `limine-snapper-sync` (chaotic-aur — surfaces snapshots as bootable entries in the limine menu). The `update` command (a function in `bash/30-aliases.bash`) brackets every `yay -Syyu` with a snapper `pre`/`post` snapshot pair, so a bad upgrade is one boot-menu pick away from rollback.

**GPU** — picked interactively in `bootstrap.sh` phase 4. AMD: `vulkan-radeon` `lib32-vulkan-radeon` `mesa-utils` `libva-mesa-driver` (no RADV ⇒ no DXVK ⇒ Proton/Unity games fail at graphics init). Intel: `vulkan-intel` `lib32-vulkan-intel` `intel-media-driver`. Nvidia: `nvidia(-open)` `nvidia-utils` `lib32-nvidia-utils` `nvidia-settings` (+ manual Wayland env tweaks).

**Nvim submodule** — `nvim/install.sh` covers its own extras (`base-devel` `unzip` `tree-sitter-cli` `python-pip` `luarocks` `glab` …). Run it once after `./install.sh`.

One-shot bootstrap — `./bootstrap.sh` takes a vanilla Arch box (post-`pacstrap`, no DM/audio/Wayland) all the way to a working desktop. Six phases:

1. **yay** — `base-devel` + `git`, build `yay-bin` from AUR if missing
2. **pacman** — `--needed` install of the extra/multilib stack (Hyprland session, pipewire+wireplumber, qt6-wayland, xorg-xwayland, terminals, fonts, dev toolchains, keyring, tray TUIs `bluetui`/`impala`/`wiremix`, `linux-lts` + headers, …)
3. **AUR** — `spot-bin`, `mpvpaper`, `xdg-desktop-portal-termfilechooser`, `xdg-terminal-exec-git` (prefers `-bin`/stable variants when upstream offers them; only `xdg-terminal-exec` is `-git` because no stable release exists)
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

Hierarchical menu rendered by `spot` (type to filter; smart matching understands abbreviations — `rmt` → Remote, `sys` → System) (TOML+CSS layer-shell dialog runtime, from the `spot-bin` AUR package — github.com/KopyTKG/spot). Top level: **Apps · Webapps · Install · Remove · Capture · Toggle · Setup · Bookmarks · System · Remote · Keybinds · Learn · Power**.

**One window, with Back.** With the spot daemon (`spot daemon`, started from `hypr/defaults/autostart.lua`; it also starts itself on first use) every menu step reuses one window, so moving between menus does not flicker. Every submenu has a **‹ Back** button (also **Backspace** on an empty search, **Alt+Left**); **Esc** still closes everything. Scripts the menu launches inherit `SPOT_BACK`, so their dialogs get a Back that returns to the menu: **Setup → Display** goes back to Setup, **System → Power menu** to System. The same dialogs opened from a keybind (SUPER+SHIFT+P, SUPER+ESC) have no Back. `arch-menu <name>` opens a submenu directly (`arch-menu setup`); that is what Back runs. An older spot without Back or the daemon still works: the menu falls back to a "Back" row and one window per step.

Notable submenus:

- **Webapps** (top level) — everything about chromium `--app` launchers in one place: **Install** (create one from a URL), **Edit** (change a launcher's name, URL or icon; `arch-webapp-edit`), **Remove**. Back returns to the main menu; `arch-menu webapps` opens it directly.
- **Install** — fzf-driven installers for Pacman / AUR / Development (mise) / Gaming / Terminal / Font / **ProtonGE** (fzf-pick any GE-Proton release, download into `~/.steam/root/compatibilitytools.d/`)
- **Remove** — mirrors Install: Pacman (fzf over `pacman -Qq`) / AUR (foreign packages only, `pacman -Qqm`) / Development (`mise uninstall`) / Gaming/Terminal/Font (curated `pacman -Rns`) / ProtonGE (rm from `compatibilitytools.d/`) / **Cache** (`arch-cache-clean`: shows the sizes, then cleans yay's build dirs and the pacman package cache)
- **Bookmarks** — reads `~/.config/arch-menu/bookmarks.conf` (one `Label | URL` per line, `#` comments OK). Selecting opens the URL in chromium.
- **System** — TUI control panels via a floating kitty: bluetui, impala, wiremix, jolt, btop · **Disk** (`arch-disk`: filesystems + btrfs allocation + biggest folders in `~`, then `gdu` to explore) · **Sockets** (`arch-sockets`: a searchable table of every TCP/UDP socket in a spot dialog; also the waybar socket-count module) · **Firewall** (`arch-firewall`: a spot GUI over `ufw` — searchable rules table, add / delete / enable / reload / reset; the old fzf TUI is `arch-firewall-tui`)
- **Remote** — reads `~/.ssh/config` and everything it `Include`s; a host's group is its nearest `# group: NAME` marker, else the folder its config lives in (`~/.ssh/infra/config` → *infra*); git forges (github/gitlab/bitbucket/aur) are skipped; picks a group, then a host, and spawns ssh in a tiled `ssh-session` terminal. **Custom…** gum-prompts for User/Host/Port.
- **Keybinds** — also bound to SUPER+F1; a searchable, **collapsible** spot list (`spot-config/keybinds.toml`: one folded group per scope, Enter or Left/Right folds it, typing searches inside folded groups) of **every** keybind, not just Hyprland's: the live Hyprland binds (grouped, with key combinations that two binds share marked ⚠), dialogs and menus, waybar clicks (generated from the waybar config), and the keys of installed apps read from the apps themselves — fish, kitty, yazi, mpv and nvim — plus a curated list for lazygit, lazydocker, btop, zathura and gdu (`arch-menu/keybinds.conf`; only shown when the app is installed). Smart matching: every word has to match (`yazi seek`, `fish ctrl r`, `nvim lsp`). The same data as a document: [`KEYBINDS.md`](KEYBINDS.md)
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
| `arch-cache-clean`              | Remove → Cache. Shows what `~/.cache/yay` and `/var/cache/pacman/pkg` cost, then cleans them: yay's per-package build dirs (keeps `completion.cache` and `vcs.json`), and `paccache` (keeps the newest 2 versions, drops uninstalled packages, removes leftover `download-*` dirs). `--dry-run` shows what would go; `yay`, `pacman` or `all` (with `-y`) for scripts |
| `arch-disk`                     | System → Disk. Overview (filesystems via `duf`/`df`, the btrfs pool, biggest folders in `~` via `dust`), then pick a place to explore with `gdu` (falls back to `dust`). `arch-disk <path>` jumps straight in, `--overview` prints and exits. Note: on btrfs, snapper snapshots hold space `du` can't see |
| `arch-sockets`                  | `ss` with a GUI. `arch-sockets` opens a spot table of every TCP/UDP socket (proto, state, local, peer, process) with smart matching (`tcp listen 22`, `ssh estab`); Enter copies the local `addr:port`. `--listening` filters to listeners; `--root` (or the first row of the dialog) names every socket's process (sudo, with the password asked in a spot dialog); `count` prints the waybar JSON (total + breakdown tooltip); `list` / `header` print the table. Without root, process names show only for your own sockets. Config: `spot-config/sockets.toml` |
| `arch-firewall`                 | System → Firewall and the waybar firewall click. UFW in spot dialogs: a searchable table of the rules (parsed from the world-readable `/etc/ufw/user.rules`, so no password to look), plus *Add rule…* (service templates — SSH, HTTP(S), DNS, DHCP, LocalSend, KDE Connect, mDNS, Samba, Syncthing, WireGuard, dev servers… — each from anywhere or from the local network only, defined in `arch-menu/firewall-services.conf`; or a custom form: action, direction, protocol, port / range / list, optional source), enable / disable, reload, reset. Picking a rule opens *Edit* / *Delete*: Edit shows the form filled in and saves by adding the new rule, then deleting the old one (ufw cannot change a rule in place, so the new rule ends up last; interface, source-port and route rules are left to the ufw CLI, and the notification says which one it is; the form has optional From and To addresses); Delete asks first and shows the exact `ufw delete …`. Changes go through `arch-root` (sudo, with the password asked in a spot dialog that shows the exact command); results as notifications. `rules` / `header` print the table |
| `arch-firewall-tui`             | The previous fzf terminal UI for ufw (`a` allow · `d` deny · `l` limit · `x` delete · `e` enable/disable), kept for keyboard-only use |
| `arch-ufw`                      | The waybar firewall right-click: three spot tiles (enable / disable / reload) for a quick toggle without opening the rules table |
| `arch-launch-apps`              | SUPER+SPACE, Menu → Apps: spot's own app launcher (`spot-config/launcher.toml`, `type = "apps"`; needs spot ≥ 0.5.0). Webapps appear on their own: spot rescans the applications folder |
| `arch-emoji`                    | SUPER+CTRL+E; emoji picker: Unicode's list (`unicode-emoji`) in a collapsible spot list, one folded group per category, search across all; with `python-emoji` every row also carries its Discord / Slack shortcodes (`rofl`, `:joy:`, `:+1:`, `:sob:`); Enter copies and pastes (Shift+Insert) |
| `arch-clipboard`                | SUPER+CTRL+V; clipboard history: `cliphist` entries (stored by `wl-paste --watch` from autostart) in a spot list; Enter copies back and pastes; `arch-clipboard clear` wipes it |
| `arch-wallpaper`                | Animated wallpaper: `mpvpaper` plays a video/GIF from `~/Videos/Wallpapers` over `swaybg`'s static image. Only while on AC power (drops to the static image on battery; `watch` daemon from autostart polls every 30 s) and paused while the wallpaper is covered. While the video runs, `swaybg` shows its first frame (so the loop point doesn't flash the static image); the lock screen shows a still frame. `pick` (Menu → Setup → Wallpaper), `set <file>`, `on` / `off`, `status` |
| `arch-root`                     | `arch-root <reason> <command…>`: run a command as root through `sudo -A`, asking for the password in a **spot** dialog instead of the polkit agent (the dialog's footer shows `<reason>`). No dialog when sudo already has credentials. Used by `arch-sockets --root`, `arch-firewall` and `arch-ufw` |
| `arch-sudo-askpass`             | The `SUDO_ASKPASS` helper behind `arch-root`: the spot password dialog, "Wrong password — try again" on a retry, never stores the password (unlike `arch-askpass`, which caches SSH key passphrases) |
| `arch-webapp-migrate`           | Rewrites Omarchy-style web app launchers (`Exec=omarchy-launch-webapp <url>`) in `~/.local/share/applications` to `arch-launch-webapp <class> <url>` (+ `StartupWMClass`), keeping `.bak.<timestamp>` copies; run by `install.sh`, safe to repeat, `--dry-run` previews. The URLs stay in your files, not the repo |
| `arch-mise-remove`              | fzf-pick installed mise tool@version; `mise uninstall`             |
| `arch-protonge-install`         | fzf-pick a GE-Proton release; downloads + sha512-verifies + extracts |
| `arch-protonge-remove`          | fzf-pick a GE-Proton release in `compatibilitytools.d/`; `rm -rf`  |
| `arch-webapp-install`           | gum prompt → desktop launcher for any URL via chromium `--app`     |
| `arch-webapp-edit`              | Menu → Webapps → Edit. Pick a web app and change its name, URL or icon (favicon / icon URL / file); renaming also renames the file, icon and window class. Rewrites only Name/Comment/Exec/Icon/StartupWMClass, keeps the rest. Flags for scripts: `arch-webapp-edit <name> [--name N] [--url U] [--icon favicon\|URL\|FILE]`, `--list` |
| `arch-webapp "<Name>"`          | launch a webapp by Name (matches `Name=` in any `~/.local/share/applications/*.desktop` whose Exec calls `arch-launch-webapp`); no args → spot picker over all discovered webapps |
| `arch-keybinds`                 | SUPER+F1; spot table of every keybind (Hyprland live, waybar clicks, installed apps read from fish `bind`, kitty's defaults, yazi's compiled-in keymap, mpv's `input.conf`, nvim's mappings; curated extras in `arch-menu/keybinds.conf`). App keys are cached 12 h in `~/.cache/arch-keybinds` (`--refresh` rebuilds). `--md` prints Markdown (`KEYBINDS.md` is that output), `--list` TSV, `--table` / `header` the dialog's rows and column header |
| `arch-remote-custom`            | gum prompt → User/Host/Port → spawns ssh in a tiled `ssh-session` window |
| `arch-power-menu`               | bound to SUPER+ESC                                                 |
| `arch-killactive`               | SUPER+W; dismisses a spot dialog (`spot --dismiss`), else closes the window |
| `arch-launch-webapp <class> <url>` | focus existing chromium-app window by class, else launch it    |
| `arch-apply-browser-theme`      | copy `chromium/policies/managed/color.json` to system policy dir   |
| `arch-askpass`                  | Password prompt (`SSH_ASKPASS`); libsecret-cached. Inline `gum` from a TTY, `spot` password dialog headless |

## Themes

Stone palette (`#0c0a09` bg, `#f5f5f4` border, `#fafaf9` fg, `#a8a29e` muted) is used everywhere:

- **Hyprland** — `looknfeel.lua` overrides for border / opacity / dim
- **Waybar** — pill bg `rgba(28,25,23,0.7)` with `stone-100 @ 50%` border, matching tooltip + tray menu styles
- **Terminal (kitty)** — stone chrome (`primary/cursor/selection/...`); ANSI 16 colors preserved (Tokyo Night)
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
