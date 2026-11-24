-- Application bindings
local exec = hl.dsp.exec_cmd

local terminal = "uwsm app -- $TERMINAL"
local browser = "chromium"

local function bind(keys, action, desc)
  hl.bind(keys, action, { description = desc })
end

-- Keybinds
bind("SUPER + F1", exec "arch-keybinds", "Keybinds")

bind("SUPER + ALT + SPACE", exec "arch-menu", "Arch menu")
bind("SUPER + SHIFT + P", exec "arch-display", "Display settings")

-- Cleanup: drop defaults that get rebound below
hl.unbind "SUPER + T"
hl.unbind "SUPER + B"
hl.unbind "SUPER + F"
hl.unbind "SUPER + CTRL + A"
hl.unbind "SUPER + F11"
hl.unbind "SUPER + W"

-- Rebind fullscreen toggle
bind(
  "SUPER + F11",
  hl.dsp.window.fullscreen { mode = "fullscreen" },
  "Fullscreen"
)

-- Smart close: dismiss a spot dialog if one is showing, otherwise kill the focused window
bind("SUPER + W", exec "arch-killactive", "Close (or dismiss a spot dialog)")

-- Default
bind(
  "SUPER + T",
  exec(terminal .. ' --dir="$(arch-cmd-terminal-cwd)"'),
  "Terminal"
)
bind("SUPER + B", exec(browser), "Browser")
bind("SUPER + SHIFT + B", exec(browser .. " --incognito"), "Browser (private)")
bind(
  "SUPER + F",
  exec 'arch-floatterm yazi yazi "$(arch-cmd-terminal-cwd)"',
  "File manager (yazi)"
)

-- Apps
bind(
  "SUPER + M",
  exec 'arch-launch-app spotify "uwsm-app -- flatpak run com.spotify.Client"',
  "Music"
)
bind("SUPER + N", exec "uwsm-app -- xdg-terminal-exec nvim", "Editor")
bind(
  "SUPER + D",
  exec 'arch-launch-app discord "uwsm-app -- flatpak run com.discordapp.Discord"',
  "Discord"
)

-- Password extensions as floating windows over any webapp (see bin/arch-passwords)
bind(
  "SUPER + ALT + P",
  exec "arch-passwords",
  "Passwords (Nextcloud extension popup)"
)
bind(
  "SUPER + ALT + O",
  exec "arch-passwords otp",
  "One-time codes (Nextcloud OTP popup)"
)

bind(
  "SUPER + E",
  exec 'arch-launch-app thunderbird "uwsm-app -- flatpak run org.mozilla.thunderbird"',
  "Email"
)
