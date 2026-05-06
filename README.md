# hyprland-config

Generic Hyprland desktop configuration — a starting point to build on.

Originally extracted from a working [Omarchy](https://omarchy.org/) 3.7.1
install, but Omarchy-specific bits (the `omarchy/` config tree, app launcher
hooks, custom themes, distro-tied app configs) have been stripped so this
works as a base for any Arch + Hyprland setup.

## Layout

The `config/` tree mirrors `~/.config/`. The install script symlinks each
file into `~/.config/<same-relative-path>`.

```
config/
├── hypr/                # Hyprland: bindings, monitors, animations, idle, lock
├── waybar/              # Status bar layout + style
├── walker/              # App launcher
├── kitty/ ghostty/      # Terminals
├── mako/                # Notification daemon
├── swayosd/             # OSD overlays (volume / brightness / caps lock)
├── btop/ fastfetch/ lazygit/ git/   # CLI tools
├── starship.toml        # Prompt
├── elephant/            # Walker backend
├── fcitx5/              # Input method
├── fontconfig/ environment.d/ systemd/ uwsm/
├── imv/ xournalpp/ Typora/   # Image / note apps
├── chromium/ chromium-flags.conf brave-flags.conf  # Browser flags + Wayland tweaks
├── hyprland-preview-share-picker/   # Screen-share picker for Hyprland
├── wiremix/             # PipeWire mixer TUI
├── omarchy.ttf          # Icon font used by waybar (safe to swap)
└── xdg-terminals.list   # Default terminal preference
```

## Install

```bash
./install.sh           # symlinks config/* into ~/.config/
./install.sh --copy    # copies instead of symlinking
./install.sh --dry-run # show what would happen, change nothing
```

Existing files are backed up with a timestamp suffix before being replaced.

After install, restart components that don't auto-reload:

```bash
hyprctl reload && hyprctl configerrors   # validate Hyprland config
killall -SIGUSR2 waybar                  # reload waybar
makoctl reload                           # reload mako
```

## Build on top

- **Keybindings** → `config/hypr/bindings.conf`. When overriding an existing
  binding, add `unbind = <MOD>, <KEY>` first or Hyprland will keep both.
- **Monitors** → `config/hypr/monitors.conf`. List current monitors with
  `hyprctl monitors`.
- **Look & feel** (gaps, borders, animations) → `config/hypr/looknfeel.conf`.
- **Window rules** → `config/hypr/hyprland.conf`. Hyprland window-rule syntax
  changes between versions; verify against
  https://wiki.hypr.land/Configuring/Window-Rules/ before writing rules.
- **Status bar modules** → `config/waybar/config.jsonc`; styling in
  `config/waybar/style.css`. Waybar does not auto-reload — restart it.
- **App launcher entries** → walker reads `~/.local/share/applications/`;
  config lives in `config/walker/config.toml`.

## Dependencies

This config assumes the following are installed (Arch package names):

```
hyprland hypridle hyprlock hyprsunset
waybar walker mako swayosd
kitty ghostty
btop fastfetch lazygit git starship
fcitx5 imv xournalpp
xdg-desktop-portal-hyprland uwsm
```

Adjust to taste. None of the configs hard-require all of these — drop the
relevant `config/<app>/` dir if you don't use the app.

## Reference

- Hyprland wiki: https://wiki.hypr.land/
- Waybar wiki: https://github.com/Alexays/Waybar/wiki
- Walker: https://github.com/abenz1267/walker
