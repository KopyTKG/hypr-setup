-- App-specific window and layer rules
local rule = hl.window_rule

-- Media windows that should never be transparent
local function opaque(match)
    rule({ match = match, tag = "-default-opacity" })
    rule({ match = match, opacity = "1 1" })
end

---- Password managers ----
rule({ match = { class = "^(1[p|P]assword)$" }, no_screen_share = true, tag = "+floating-window" })
rule({ match = { class = "^(Bitwarden)$" }, no_screen_share = true, tag = "+floating-window" })
-- Bitwarden Chrome Extension
rule({ match = { class = "chrome-nngceckbapebfimnlniiiahkandclblb-Default" }, no_screen_share = true, tag = "+floating-window" })

---- Browsers ----
rule({ match = { class = "((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)" }, tag = "+chromium-based-browser" })
rule({ match = { class = "([fF]irefox|zen|librewolf)" }, tag = "+firefox-based-browser" })
rule({ match = { tag = "chromium-based-browser" }, tag = "-default-opacity" })
rule({ match = { tag = "firefox-based-browser" }, tag = "-default-opacity" })

-- Video apps: remove chromium browser tag so they don't get opacity applied
local videoApps = "(chrome-youtube.com__-Default|chrome-app.zoom.us__wc_home-Default)"
rule({ match = { class = videoApps }, tag = "-chromium-based-browser" })
rule({ match = { class = videoApps }, tag = "-default-opacity" })

-- Force chromium-based browsers into a tile to deal with --app bug
rule({ match = { tag = "chromium-based-browser" }, tile = true })

-- Only a subtle opacity change, but not for video sites
rule({ match = { tag = "chromium-based-browser" }, opacity = "1.0 0.97" })
rule({ match = { tag = "firefox-based-browser" }, opacity = "1.0 0.97" })

-- Hide the screen-sharing notification bar (the "Hide" button on it is broken on Wayland)
rule({ match = { title = ".*is sharing.*" }, workspace = "special silent" })

---- Screenshots / launchers ----
-- Remove 1px border around hyprshot screenshots
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "walker" }, no_anim = true })

---- Dev ----
rule({ name = "jetbrains-focus", match = { class = "^(jetbrains-.*)$" }, no_follow_mouse = true })

---- LocalSend (flatpak) and fzf file picker ----
local localsend = "(localsend|org.localsend.localsend_app)"
rule({ match = { class = "(Share|" .. localsend .. ")" }, float = true, center = true })
rule({ match = { class = localsend }, size = { 1100, 700 } })

---- Picture-in-picture overlays ----
rule({ match = { title = "(Picture.?in.?[Pp]icture)" }, tag = "+pip" })
rule({ match = { tag = "pip" }, tag = "-default-opacity" })
rule({
    match = { tag = "pip" },
    float = true,
    pin = true,
    size = { 600, 338 },
    keep_aspect_ratio = true,
    border_size = 0,
    opacity = "1 1",
    move = { "(monitor_w-window_w-40)", "(monitor_h*0.04)" },
})

---- Games / streaming ----
opaque({ class = "qemu" })

rule({ match = { class = "com.libretro.RetroArch" }, fullscreen = true, idle_inhibit = "fullscreen" })
opaque({ class = "com.libretro.RetroArch" })

rule({ match = { class = "steam" }, float = true, idle_inhibit = "fullscreen" })
rule({ match = { class = "steam", title = "Steam" }, center = true, size = { 1100, 700 } })
rule({ match = { class = "steam", title = "Friends List" }, size = { 460, 800 } })
opaque({ class = "steam.*" })

rule({ name = "geforce", match = { class = "GeForceNOW" }, idle_inhibit = "fullscreen" })
rule({ name = "moonlight", match = { class = "com.moonlight_stream.Moonlight" }, fullscreen = true, idle_inhibit = "fullscreen" })

---- System ----
-- Floating windows
rule({ match = { tag = "floating-window" }, float = true, center = true, size = { 875, 600 } })

rule({ match = { class = "(org.codeberg.dnkl.foot|org.kde.okular|com.gabm.satty|org.kde.gwenview|mpv)" }, tag = "+floating-window" })
rule({
    match = {
        class = "(xdg-desktop-portal-gtk|sublime_text|DesktopEditors|ONLYOFFICE)",
        title = "^(Open.*Files?|Open [F|f]older.*|Save.*Files?|Save.*As|Save|All Files|.*wants to [open|save].*|[C|c]hoose.*)",
    },
    tag = "+floating-window",
})
rule({ match = { class = "org.kde.kcalc" }, float = true })

-- No transparency on media windows
opaque({ class = "^(zoom|vlc|mpv|org.kde.kdenlive|com.obsproject.Studio|com.github.PintaProject.Pinta|org.kde.gwenview)$" })

-- Popped window rounding
rule({ match = { tag = "pop" }, rounding = 8 })

-- Prevent idle while open
rule({ match = { tag = "noidle" }, idle_inhibit = "always" })

---- Messaging ----
-- Prevent Telegram from stealing focus on new messages
rule({ match = { class = "org.telegram.desktop" }, focus_on_activate = false })

---- Typora print dialog ----
rule({ match = { class = "^Typora$", title = "^Print$" }, float = true, center = true })

---- Terminals ----
-- Define terminal tag to style them uniformly
rule({ match = { class = "(Alacritty|kitty|com.mitchellh.ghostty|foot)" }, tag = "+terminal" })
rule({ match = { tag = "terminal" }, tag = "-default-opacity" })
rule({ match = { tag = "terminal" }, opacity = "0.97 0.9" })

---- Webcam overlay for screen recording ----
rule({
    match = { title = "WebcamOverlay" },
    float = true,
    pin = true,
    no_initial_focus = true,
    no_dim = true,
    move = { "(monitor_w-window_w-40)", "(monitor_h-window_h-40)" },
})
