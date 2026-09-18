-- See https://wiki.hypr.land/Configuring/Core/Rules/Window-Rules/
-- Rules apply top to bottom; the last match wins.

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Tag all windows for default opacity (apps can override with -default-opacity tag)
hl.window_rule({ match = { class = ".*" }, tag = "+default-opacity" })

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- App-specific tweaks (may remove default-opacity tag)
require("defaults.apps")

-- Apply default opacity after apps have had a chance to opt out
hl.window_rule({ match = { tag = "default-opacity" }, opacity = "0.97 0.9" })
