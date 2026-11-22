-- Minimal Hyprland config for the SDDM Wayland greeter (Lua, like the user config:
-- the old hyprlang /usr/share/sddm/hyprland.conf no longer parses).
-- SDDM starts the greeter itself after the compositor is ready.
hl.config({
    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
    },
    animations = {
        enabled = false,
    },
})
