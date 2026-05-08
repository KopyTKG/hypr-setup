# hyprland-config

Opinionated Hyprland desktop config — a personal starter base for Arch Linux.

Originally extracted from a working [Omarchy](https://omarchy.org/) 3.7.1
install. Trimmed to a generic Hyprland scope, then layered with these
top-level choices:

- **Start menu** on `SUPER + ALT + SPACE` → [walker](https://github.com/abenz1267/walker)
- **Chromium PWAs** as first-class apps, defined in [`webapps.list`](./webapps.list)
- **Dev tooling** is exclusively managed by [mise](https://mise.jdx.dev/) — see [`config/mise/config.toml`](./config/mise/config.toml)
- **Font** is [Geist](https://vercel.com/font) / Geist Mono everywhere

## Quick start (fresh Arch install)

```bash
git clone <this repo> ~/hyprland-config
cd ~/hyprland-config
./setup.sh                    # user layer: packages, configs, mise tools
./bootstrap-system.sh         # system layer: SDDM, networkd+iwd, polkit, keyring
```

Both scripts accept `--dry-run`. The system layer (greeter, services,
network stack) is documented in [`BOOTSTRAP.md`](./BOOTSTRAP.md) — read it
before running `bootstrap-system.sh`, especially if you've already chosen
NetworkManager or a different polkit agent.

What `setup.sh` does, in order:

1. `sudo pacman -Syu --needed` — installs everything in [`packages/pacman.txt`](./packages/pacman.txt)
2. Installs `yay` if missing, then `yay -S --needed` — installs everything in [`packages/aur.txt`](./packages/aur.txt)
3. Runs [`install.sh`](./install.sh) — symlinks `config/` → `~/.config/` and `bin/` → `~/.local/bin/`
4. Runs [`bin/install-webapps.sh`](./bin/install-webapps.sh) — registers Chromium PWAs from `webapps.list`
5. Runs `mise install` — installs dev tools declared in `config/mise/config.toml`

Step-skipping: `--skip-aur`, `--skip-mise`, `--skip-webapps`.

## Repo layout

```
.
├── config/                  # mirrors ~/.config/
│   ├── hypr/                # bindings, monitors, idle, lock, look&feel
│   ├── waybar/              # status bar
│   ├── walker/              # app launcher (start menu)
│   ├── kitty/ ghostty/      # terminals
│   ├── mako/ swayosd/       # notifications + OSD
│   ├── fontconfig/          # Geist as default sans/mono
│   ├── mise/config.toml     # single source of truth for dev tools
│   ├── btop/ fastfetch/ lazygit/ git/   # CLI tools
│   ├── starship.toml        # prompt
│   └── ...                  # fcitx5, elephant, environment.d, systemd, uwsm, …
├── bin/
│   ├── launch-webapp        # opens chromium --app=URL, focuses if running
│   ├── launch-or-focus      # focuses a window by class, else exec command
│   └── install-webapps.sh   # generates .desktop entries from webapps.list
├── packages/
│   ├── pacman.txt           # official Arch repo packages
│   └── aur.txt              # AUR packages (Geist, walker, mise, …)
├── webapps.list             # PWA definitions (Name|URL|Categories)
├── setup.sh                 # full bootstrap — call this first
├── install.sh               # configs-only deploy (called by setup.sh)
└── .gitignore
```

## Manual install (no setup.sh)

If you want finer control:

```bash
# 1. Packages
sudo pacman -S --needed - < packages/pacman.txt
yay -S --needed - < packages/aur.txt

# 2. Configs
./install.sh                  # symlinks
./install.sh --copy           # or copies
./install.sh --dry-run        # preview

# 3. Webapps
./bin/install-webapps.sh

# 4. Dev tools
mise install                  # mise reads config/mise/config.toml after step 2
```

`install.sh` backs up existing files with a timestamp suffix before replacing.

After install, reload running components:

```bash
hyprctl reload && hyprctl configerrors
killall -SIGUSR2 waybar
makoctl reload
fc-cache -f                   # if Geist was just added
```

## Webapps

Edit `webapps.list` to define which Chromium PWAs to install. Format:

```
Name|URL|Categories
```

`Categories` is optional and follows the
[freedesktop.org spec](https://specifications.freedesktop.org/menu-spec/latest/apa.html).
Default is `Network`.

After editing, rerun `./bin/install-webapps.sh`. Uninstall everything with
`./bin/install-webapps.sh --remove`. Each entry becomes
`~/.local/share/applications/webapp-<slug>.desktop` so the app shows up in
walker (and any XDG launcher).

`bin/launch-webapp NAME URL` is what desktop entries invoke. It picks the first
installed Chromium-family browser (chromium, google-chrome, brave, edge) and
runs `--app=URL --class=webapp-NAME`. If a window with that class is already
open, it focuses instead of opening a new one — same keybind, "open or raise"
behavior.

## Keybindings

`config/hypr/bindings.conf` adds these on top of upstream Hyprland defaults:

| Keys | Action |
|------|--------|
| `SUPER + ALT + SPACE` | **Start menu** (walker) |
| `SUPER + T` | Terminal (`xdg-terminal-exec`) |
| `SUPER + ALT + RETURN` | Terminal with `tmux new` |
| `SUPER + B` / `SHIFT+B` | Browser / private |
| `SUPER + F` | File manager (Nautilus) |
| `SUPER + N` | Editor (`nvim` in terminal) |
| `SUPER + M` | Music (Spotify, focus-or-launch) |
| `SUPER + D` / `SHIFT+D` | Discord (focus-or-launch) / Docker (`lazydocker`) |
| `SUPER + F11` | Fullscreen toggle |
| `SUPER + C` / `E` | Proton Calendar / Mail (PWA) |
| `SUPER + A` / `SHIFT+A` / `CTRL+A` | Claude / V0 / Gemini (PWA) |
| `SUPER + I` / `SHIFT+I` / `CTRL+I` | Instagram / WhatsApp / Messenger (PWA) |

To rebind, edit `config/hypr/bindings.conf`. Use `unbind = MOD, KEY` first
when overriding an upstream default, otherwise both fire.

## Dev tools (mise)

All dev tooling is managed by mise — never `pacman -S nodejs` or `pip install`
globally. Add a tool to `[tools]` in `config/mise/config.toml`, run
`mise install`, done.

```bash
mise install                  # install everything declared
mise list                     # show installed versions
mise use python@3.13          # add/upgrade a tool (writes config)
mise exec node -- npm i -g …  # run with mise's PATH
```

For per-project pinning, drop a `mise.toml` (or `.tool-versions`) at the
project root.

## Customizing the package set

`packages/pacman.txt` and `packages/aur.txt` are plain lists, one package per
line, blank lines and `#` comments allowed. Edit and rerun `setup.sh` (or
`pacman`/`yay` directly).

Notable choices baked in:

- **Browser**: chromium (PWAs use `--app=`, any chromium fork works)
- **Editor**: neovim (in terminal); swap by editing the `SUPER, N` bind
- **AUR helper**: yay (auto-installed if missing)
- **Login manager**: not included — use sddm/greetd/whatever you prefer; or
  start Hyprland from a TTY (`uwsm start hyprland-uwsm.desktop`)
- **Terminal default**: picked by `xdg-terminal-exec` via `~/.config/xdg-terminals.list`

## Reference

- Hyprland wiki: https://wiki.hypr.land/
- Waybar wiki: https://github.com/Alexays/Waybar/wiki
- Walker: https://github.com/abenz1267/walker
- mise: https://mise.jdx.dev/
- Geist: https://vercel.com/font
