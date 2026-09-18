local exec = hl.dsp.exec_cmd

local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end

-- Menus
bind("SUPER + SPACE", exec("walker"), "Launch apps")
bind("SUPER + CTRL + E", exec("walker -m symbols"), "Emoji picker")
bind("SUPER + ESCAPE", exec("arch-power-menu"), "Power menu")
bind("XF86PowerOff", exec("arch-power-menu"), "Power menu", { locked = true })
bind("XF86Calculator", exec("kcalc"), "Calculator")

-- Aesthetics
bind("SUPER + SHIFT + SPACE", exec("arch-toggle-waybar"), "Toggle top bar")
bind("SUPER + BACKSPACE", exec("arch-toggle-window-transparency"), "Toggle window transparency")
bind("SUPER + SHIFT + BACKSPACE", exec("arch-toggle-window-gaps"), "Toggle window gaps")

-- Notifications
bind("SUPER + COMMA", exec("makoctl dismiss"), "Dismiss last notification")
bind("SUPER + SHIFT + COMMA", exec("makoctl dismiss --all"), "Dismiss all notifications")
bind("SUPER + CTRL + COMMA", exec("arch-toggle-notification-silencing"), "Toggle silencing notifications")
bind("SUPER + ALT + COMMA", exec("makoctl invoke"), "Invoke last notification")
bind("SUPER + SHIFT + ALT + COMMA", exec("makoctl restore"), "Restore last notification")

-- Toggles
bind("SUPER + CTRL + I", exec("arch-toggle-idle"), "Toggle locking on idle")
bind("SUPER + CTRL + N", exec("arch-toggle-nightlight"), "Toggle nightlight")
bind("SUPER + CTRL + Delete", exec("arch-monitor-internal toggle"), "Toggle laptop display")

-- Captures
bind("PRINT", exec("hyprshot -m region"), "Screenshot (region)")
bind("ALT + PRINT", exec("hyprshot -m window"), "Screenshot (window)")
bind("SHIFT + PRINT", exec("hyprshot -m output"), "Screenshot (output)")
bind("SUPER + PRINT", exec("pkill hyprpicker || hyprpicker -a"), "Color picker")

-- Waybar-less information
bind("SUPER + CTRL + ALT + T", exec([[notify-send -u low "$(date +"%A %H:%M  ·  %d %B %Y  ·  Week %V")"]]), "Show time")
bind("SUPER + CTRL + ALT + B", exec([[notify-send -u low "$(arch-battery-status)"]]), "Show battery remaining")

-- Control panels (TUI, in floating terminal)
bind("SUPER + CTRL + A", exec("arch-floatterm arch-wiremix wiremix"), "Audio controls")
bind("SUPER + CTRL + B", exec("arch-floatterm arch-bluetui sh -c 'rfkill unblock bluetooth; exec bluetui'"),
    "Bluetooth controls")
bind("SUPER + CTRL + W", exec("arch-floatterm arch-impala sh -c 'rfkill unblock wifi; exec impala'"), "Wifi controls")
bind("SUPER + CTRL + T", exec("arch-floatterm arch-btop btop"), "Activity")

-- Zoom
bind("SUPER + CTRL + Z", function()
    hl.config({ cursor = { zoom_factor = hl.get_config("cursor.zoom_factor") + 1 } })
end, "Zoom in")
bind("SUPER + CTRL + ALT + Z", function()
    hl.config({ cursor = { zoom_factor = 1 } })
end, "Reset zoom")

-- Lock system
bind("SUPER + CTRL + L", exec("hyprlock"), "Lock system")
