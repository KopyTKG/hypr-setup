-- Workspace split for any second screen: 1-5 stay on the laptop panel, 6-10
-- follow whichever external monitor is plugged in (name doesn't matter). With
-- no external connected, rules for a missing monitor simply fall back to the
-- panel, so nothing is stranded.

local INTERNAL = { "eDP", "LVDS", "DSI" }

local function is_internal(name)
    for _, p in ipairs(INTERNAL) do
        if name:sub(1, #p) == p then return true end
    end
    return false
end

local function pin_externals(mon)
    if not mon or is_internal(mon.name) then return end
    for i = 6, 10 do
        hl.workspace_rule({ workspace = tostring(i), monitor = mon.name, default = (i == 6) })
    end
end

hl.on("monitor.added", pin_externals)

-- Monitors that are already up when the config loads (startup, reload).
for _, mon in ipairs(hl.get_monitors()) do pin_externals(mon) end
