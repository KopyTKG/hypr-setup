local exec = hl.dsp.exec_cmd

-- Held keys repeat and work on the lock screen
local function held(keys, cmd, desc)
    hl.bind(keys, exec(cmd), { locked = true, repeating = true, description = desc })
end

local function locked(keys, cmd, desc)
    hl.bind(keys, exec(cmd), { locked = true, description = desc })
end

-- Laptop multimedia keys for volume and LCD brightness (with OSD)
held("XF86AudioRaiseVolume", "swayosd-client --output-volume raise", "Volume up")
held("XF86AudioLowerVolume", "swayosd-client --output-volume lower", "Volume down")
held("XF86AudioMute", "swayosd-client --output-volume mute-toggle", "Mute")
held("XF86AudioMicMute", "swayosd-client --input-volume mute-toggle", "Mute microphone")
held("XF86MonBrightnessUp", "swayosd-client --brightness raise", "Brightness up")
held("XF86MonBrightnessDown", "swayosd-client --brightness lower", "Brightness down")
held("SHIFT + XF86MonBrightnessUp", "swayosd-client --brightness 100", "Brightness maximum")
held("SHIFT + XF86MonBrightnessDown", "swayosd-client --brightness 1", "Brightness minimum")
held("XF86KbdBrightnessUp", "arch-brightness-keyboard up", "Keyboard brightness up")
held("XF86KbdBrightnessDown", "arch-brightness-keyboard down", "Keyboard brightness down")
locked("XF86KbdLightOnOff", "arch-brightness-keyboard cycle", "Keyboard backlight cycle")
locked("XF86TouchpadToggle", "arch-toggle-touchpad", "Toggle touchpad")
locked("XF86TouchpadOn", "arch-toggle-touchpad on", "Enable touchpad")
locked("XF86TouchpadOff", "arch-toggle-touchpad off", "Disable touchpad")

-- Precise 1% multimedia adjustments with Alt modifier
held("ALT + XF86AudioRaiseVolume", "swayosd-client --output-volume +1", "Volume up precise")
held("ALT + XF86AudioLowerVolume", "swayosd-client --output-volume -1", "Volume down precise")
held("ALT + XF86MonBrightnessUp", "swayosd-client --brightness +1", "Brightness up precise")
held("ALT + XF86MonBrightnessDown", "swayosd-client --brightness -1", "Brightness down precise")

-- Media controls via playerctl
locked("XF86AudioNext", "playerctl next", "Next track")
locked("XF86AudioPause", "playerctl play-pause", "Pause")
locked("XF86AudioPlay", "playerctl play-pause", "Play")
locked("XF86AudioPrev", "playerctl previous", "Previous track")

-- Switch audio output with Super + Mute
locked("SUPER + XF86AudioMute", "arch-audio-output-switch", "Switch audio output")
