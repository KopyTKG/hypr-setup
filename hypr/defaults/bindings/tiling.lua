local dsp = hl.dsp

local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end

-- Close windows
bind("SUPER + W", dsp.window.close(), "Close window")
bind("CTRL + ALT + DELETE", dsp.exec_cmd("arch-window-close-all"), "Close all windows")

-- Control tiling
bind("SUPER + J", dsp.layout("togglesplit"), "Toggle window split")
bind("SUPER + P", dsp.window.pseudo(), "Pseudo window") -- dwindle
bind("SUPER + T", dsp.window.float({ action = "toggle" }), "Toggle window floating/tiling")
bind("SUPER + F", dsp.window.fullscreen({ mode = "fullscreen" }), "Full screen")
bind("SUPER + CTRL + F", dsp.window.fullscreen_state({ internal = 0, client = 2 }), "Tiled full screen")
bind("SUPER + ALT + F", dsp.window.fullscreen({ mode = "maximized" }), "Full width")
bind("SUPER + O", dsp.exec_cmd("arch-window-pop"), "Pop window out (float & pin)")
bind("SUPER + L", dsp.exec_cmd("arch-toggle-workspace-layout"), "Toggle workspace layout")

-- Move focus with SUPER + arrow keys
bind("SUPER + LEFT", dsp.focus({ direction = "left" }), "Focus on left window")
bind("SUPER + RIGHT", dsp.focus({ direction = "right" }), "Focus on right window")
bind("SUPER + UP", dsp.focus({ direction = "up" }), "Focus on above window")
bind("SUPER + DOWN", dsp.focus({ direction = "down" }), "Focus on below window")

-- Workspaces 1-10 on the number row. Keysyms resolve against the first layout (us),
-- so these keep working while typing in cz.
for i = 1, 10 do
    local key = tostring(i % 10) -- 10 maps to key 0
    bind("SUPER + " .. key, dsp.focus({ workspace = i }), "Switch to workspace " .. i)
    bind("SUPER + SHIFT + " .. key, dsp.window.move({ workspace = i, follow = true }), "Move window to workspace " .. i)
    bind("SUPER + SHIFT + ALT + " .. key, dsp.window.move({ workspace = i, follow = false }),
        "Move window silently to workspace " .. i)
end

-- Control scratchpad
bind("SUPER + S", dsp.workspace.toggle_special("scratchpad"), "Toggle scratchpad")
bind("SUPER + ALT + S", dsp.window.move({ workspace = "special:scratchpad", follow = false }), "Move window to scratchpad")

-- TAB between workspaces
bind("SUPER + TAB", dsp.focus({ workspace = "e+1" }), "Next workspace")
bind("SUPER + SHIFT + TAB", dsp.focus({ workspace = "e-1" }), "Previous workspace")
bind("SUPER + CTRL + TAB", dsp.focus({ workspace = "previous" }), "Former workspace")

-- Move workspaces to other monitors
bind("SUPER + SHIFT + ALT + LEFT", dsp.workspace.move({ monitor = "l" }), "Move workspace to left monitor")
bind("SUPER + SHIFT + ALT + RIGHT", dsp.workspace.move({ monitor = "r" }), "Move workspace to right monitor")
bind("SUPER + SHIFT + ALT + UP", dsp.workspace.move({ monitor = "u" }), "Move workspace to up monitor")
bind("SUPER + SHIFT + ALT + DOWN", dsp.workspace.move({ monitor = "d" }), "Move workspace to down monitor")

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
bind("SUPER + SHIFT + LEFT", dsp.window.swap({ direction = "left" }), "Swap window to the left")
bind("SUPER + SHIFT + RIGHT", dsp.window.swap({ direction = "right" }), "Swap window to the right")
bind("SUPER + SHIFT + UP", dsp.window.swap({ direction = "up" }), "Swap window up")
bind("SUPER + SHIFT + DOWN", dsp.window.swap({ direction = "down" }), "Swap window down")

-- Cycle through applications on active workspace, revealing the focused one on top
bind("ALT + TAB", function()
    hl.dispatch(dsp.window.cycle_next())
    hl.dispatch(dsp.window.bring_to_top())
end, "Focus on next window")
bind("ALT + SHIFT + TAB", function()
    hl.dispatch(dsp.window.cycle_next({ next = false }))
    hl.dispatch(dsp.window.bring_to_top())
end, "Focus on previous window")

-- Cycle through monitors
bind("CTRL + ALT + TAB", dsp.focus({ monitor = "+1" }), "Focus on next monitor")
bind("CTRL + ALT + SHIFT + TAB", dsp.focus({ monitor = "-1" }), "Focus on previous monitor")

-- Resize active window
bind("SUPER + minus", dsp.window.resize({ x = -100, y = 0, relative = true }), "Expand window left")
bind("SUPER + equal", dsp.window.resize({ x = 100, y = 0, relative = true }), "Shrink window left")
bind("SUPER + SHIFT + minus", dsp.window.resize({ x = 0, y = -100, relative = true }), "Shrink window up")
bind("SUPER + SHIFT + equal", dsp.window.resize({ x = 0, y = 100, relative = true }), "Expand window down")

-- Scroll through existing workspaces with SUPER + scroll
bind("SUPER + mouse_down", dsp.focus({ workspace = "e+1" }), "Scroll active workspace forward")
bind("SUPER + mouse_up", dsp.focus({ workspace = "e-1" }), "Scroll active workspace backward")

-- Move/resize windows with SUPER + LMB/RMB and dragging
bind("SUPER + mouse:272", dsp.window.drag(), "Move window", { mouse = true })
bind("SUPER + mouse:273", dsp.window.resize(), "Resize window", { mouse = true })

-- Toggle groups
bind("SUPER + G", dsp.group.toggle(), "Toggle window grouping")
bind("SUPER + ALT + G", dsp.window.move({ out_of_group = true }), "Move active window out of group")

-- Join groups
bind("SUPER + ALT + LEFT", dsp.window.move({ into_group = "l" }), "Move window to group on left")
bind("SUPER + ALT + RIGHT", dsp.window.move({ into_group = "r" }), "Move window to group on right")
bind("SUPER + ALT + UP", dsp.window.move({ into_group = "u" }), "Move window to group on top")
bind("SUPER + ALT + DOWN", dsp.window.move({ into_group = "d" }), "Move window to group on bottom")

-- Navigate a single set of grouped windows
bind("SUPER + ALT + TAB", dsp.group.next(), "Next window in group")
bind("SUPER + ALT + SHIFT + TAB", dsp.group.prev(), "Previous window in group")

-- Window navigation for grouped windows
bind("SUPER + CTRL + LEFT", dsp.group.prev(), "Move grouped window focus left")
bind("SUPER + CTRL + RIGHT", dsp.group.next(), "Move grouped window focus right")

-- Scroll through a set of grouped windows with SUPER + ALT + scroll
bind("SUPER + ALT + mouse_down", dsp.group.next(), "Next window in group")
bind("SUPER + ALT + mouse_up", dsp.group.prev(), "Previous window in group")

-- Activate window in a group by number
for i = 1, 5 do
    bind("SUPER + ALT + " .. i, dsp.group.active({ index = i }), "Switch to group window " .. i)
end

-- Cycle monitor scaling with SUPER + /
bind("SUPER + slash", dsp.exec_cmd("arch-monitor-scaling-cycle"), "Cycle monitor scaling")
bind("SUPER + ALT + slash", dsp.exec_cmd("arch-monitor-scaling-cycle --reverse"), "Cycle monitor scaling backwards")
