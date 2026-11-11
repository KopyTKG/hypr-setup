-- Workspace split for any second screen: 1-5 are pinned to the laptop panel,
-- 6-10 follow whichever external monitor is plugged in (name doesn't matter).
-- Both halves are pinned, otherwise a workspace opened from the other screen
-- (say Super+5 while focused on the external) just stays there. With no
-- external connected, rules for a missing monitor simply fall back to the
-- panel, so nothing is stranded.

local INTERNAL = { "eDP", "LVDS", "DSI" }

local function is_internal(name)
    for _, p in ipairs(INTERNAL) do
        if name:sub(1, #p) == p then return true end
    end
    return false
end

local function pin(mon)
    if not mon then return end
    local first, last = 6, 10
    if is_internal(mon.name) then first, last = 1, 5 end
    for i = first, last do
        hl.workspace_rule({ workspace = tostring(i), monitor = mon.name, default = (i == first) })
    end
end

hl.on("monitor.added", pin)

-- Monitors that are already up when the config loads (startup, reload).
for _, mon in ipairs(hl.get_monitors()) do pin(mon) end
