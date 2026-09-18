-- Control your input devices
-- See https://wiki.hypr.land/Configuring/Core/Config-Options/#input
hl.config({
    input = {
        -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt
        kb_layout = "us,cz",
        kb_options = "grp:alts_toggle", -- ,compose:caps

        -- Change speed of keyboard repeat
        repeat_rate = 40,
        repeat_delay = 600,

        -- Start with numlock on by default
        numlock_by_default = true,

        -- Increase sensitity for mouse/trackpack (default: 0)
        -- sensitivity = 0.35,

        touchpad = {
            -- Use natural (inverse) scrolling
            natural_scroll = true,

            -- Use two-finger clicks for right-click instead of lower-right corner
            -- clickfinger_behavior = true,

            -- Control the speed of your scrolling
            scroll_factor = 0.4,
        },
    },
})

-- Scroll faster in the terminal
hl.window_rule({ match = { class = "(Alacritty|kitty|foot)" }, scroll_touchpad = 1.5 })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, scroll_touchpad = 0.2 })

-- Enable touchpad gestures for changing workspaces
-- See https://wiki.hypr.land/Configuring/Core/Binds/Gestures/
-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
