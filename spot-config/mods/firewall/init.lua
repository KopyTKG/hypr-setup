-- firewall.status  for the bar: shield on or off
-- firewall.rules   the rows of arch-firewall's table
-- firewall.title   state, default policies and the number of rules
-- It only reads. Changing the firewall stays with arch-firewall and arch-root.
local parse = spot.use("ufw")

-- A file that cannot be read is an error, never "off" or "no rules".
local function must(what, text, err)
  if not text then error(what .. ": " .. tostring(err)) end
  return text
end

local function enabled()
  return ("\n" .. must("ufw.conf", spot.read("/etc/ufw/ufw.conf"))):find("\nENABLED=yes", 1, true) ~= nil
end

local function rules()
  local v4 = must("user.rules", spot.read("/etc/ufw/user.rules"))
  local v6 = must("user6.rules", spot.read("/etc/ufw/user6.rules"))
  return parse(v4 .. "\n" .. v6)
end

spot.value("status", { every = 5000 }, function()
  if enabled() then
    return { text = "\243\176\149\165", tooltip = "Firewall active", class = "active" }
  end
  return { text = "\243\176\166\158", tooltip = "Firewall inactive" }
end)

spot.value("rules", { ttl = 1000 }, function()
  local out = {}
  for _, r in ipairs(rules()) do out[#out + 1] = { label = r.label, key = r.key } end
  return out
end)

spot.value("title", { ttl = 1000 }, function()
  local defaults = "\n" .. must("defaults", spot.read("/etc/default/ufw"))
  local names = { DROP = "deny", ACCEPT = "allow", REJECT = "reject" }
  local function policy(chain)
    return names[defaults:match("\nDEFAULT_" .. chain .. '_POLICY="?(%u+)')] or "?"
  end
  return ("Firewall · %s · in: %s · out: %s · %d rule(s)"):format(
    enabled() and "ACTIVE" or "INACTIVE", policy("INPUT"), policy("OUTPUT"), #rules())
end)
