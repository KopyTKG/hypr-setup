-- Custom window rules

-- All arch-* alacritty windows (installers + TUI control panels) float centered
hl.window_rule({ match = { class = "arch-.*" }, float = true, center = true, size = { 1400, 900 } })

-- Steam games auto-fullscreen so they draw above the floating Steam client window
hl.window_rule({ match = { class = "steam_app_.*" }, fullscreen = true })

-- Keep the Steam client window on its own workspace so it never sits over a game
hl.window_rule({ match = { class = "steam", title = "Steam" }, workspace = "9 silent" })
