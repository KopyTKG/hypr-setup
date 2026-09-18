-- Application bindings
local exec = hl.dsp.exec_cmd

local terminal = "uwsm app -- $TERMINAL"
local browser = "chromium"

local function bind(keys, action, desc)
    hl.bind(keys, action, { description = desc })
end

local function webapp(keys, desc, class, url)
    bind(keys, exec(string.format('arch-launch-webapp %s "%s"', class, url)), desc)
end

-- Keybinds
bind("SUPER + F1", exec("arch-floatterm arch-installer arch-keybinds"), "Keybinds")

bind("SUPER + ALT + SPACE", exec("arch-menu"), "Arch menu")

-- Cleanup: drop defaults that get rebound below
hl.unbind("SUPER + T")
hl.unbind("SUPER + B")
hl.unbind("SUPER + F")
hl.unbind("SUPER + CTRL + A")
hl.unbind("SUPER + F11")
hl.unbind("SUPER + W")

-- Rebind fullscreen toggle
bind("SUPER + F11", hl.dsp.window.fullscreen({ mode = "fullscreen" }), "Fullscreen")

-- Smart close: dismiss walker if visible, otherwise kill the focused window
bind("SUPER + W", exec("arch-killactive"), "Close (or dismiss walker)")

-- Default
bind("SUPER + T", exec(terminal .. ' --dir="$(arch-cmd-terminal-cwd)"'), "Terminal")
bind("SUPER + B", exec(browser), "Browser")
bind("SUPER + SHIFT + B", exec(browser .. " --incognito"), "Browser (private)")
bind("SUPER + F", exec("uwsm app -- dolphin"), "File manager")

-- Apps
bind("SUPER + M", exec("arch-launch-app spotify"), "Music")
bind("SUPER + N", exec("uwsm-app -- xdg-terminal-exec nvim"), "Editor")
bind("SUPER + SHIFT + D", exec("uwsm-app -- xdg-terminal-exec lazydocker"), "Docker")
bind("SUPER + D", exec("discord-canary"), "Discord")

-- Proton stuff
webapp("SUPER + C", "Calendar", "proton-calendar", "https://calendar.proton.me/u/0/")
webapp("SUPER + E", "Email", "proton-mail", "https://mail.proton.me/u/0/inbox")

-- AI stuff
webapp("SUPER + A", "Claude", "claude-ai", "https://claude.ai/")
webapp("SUPER + SHIFT + A", "V0", "v0-app", "https://v0.app/")
webapp("SUPER + CTRL + A", "Gemini", "gemini", "https://gemini.google.com/app?hl=cs")

-- Coms
webapp("SUPER + I", "Instagram", "instagram", "https://www.instagram.com/")
webapp("SUPER + SHIFT + I", "WhatsApp", "whatsapp", "https://web.whatsapp.com/")
webapp("SUPER + CTRL + I", "Messenger", "messenger", "https://www.messenger.com/e2ee/t/28395601576750106/")
