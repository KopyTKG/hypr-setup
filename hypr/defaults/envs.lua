-- Cursor size
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Force all apps to use Wayland
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_STYLE_OVERRIDE", "Breeze")
-- Loads the KDE platform theme (from plasma-integration) so Qt/KDE apps read the
-- colour scheme in ~/.config/kdeglobals — without this they stay light regardless.
hl.env("QT_QPA_PLATFORMTHEME", "kde")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM", "wayland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Flatpak app launchers: the session env arrives without flatpak's export dirs,
-- so walker/elephant can't see flatpak .desktop files. Prepend any that are missing.
local dataDirs = os.getenv("XDG_DATA_DIRS") or "/usr/local/share:/usr/share"
for _, dir in ipairs({ "/var/lib/flatpak/exports/share", os.getenv("HOME") .. "/.local/share/flatpak/exports/share" }) do
    if not (":" .. dataDirs .. ":"):find(":" .. dir .. ":", 1, true) then
        dataDirs = dir .. ":" .. dataDirs
    end
end
hl.env("XDG_DATA_DIRS", dataDirs)

-- Use XCompose file
hl.env("XCOMPOSEFILE", os.getenv("HOME") .. "/.XCompose")

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
    -- Don't show update on first launch
    ecosystem = {
        no_update_news = true,
    },
})
