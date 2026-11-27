-- Lines like this one, one per rule (twice when it holds for IPv4 and IPv6):
--   ### tuple ### <action> <proto> <dport> <dst> <sport> <src> <dir> [comment=<hex>]
-- The columns are those of arch-firewall's header, which reads a picked row back.
local function any(a) return (a == "0.0.0.0/0" or a == "::/0") and "Anywhere" or a end
local function cut(s, w) return #s > w and s:sub(1, w - 1) .. "~" or s end
local function unhex(h)
  local s = h:gsub("%x%x", function(x) return string.char(tonumber(x, 16)) end)
  return (s:gsub("%c", " ")) -- a comment stays on its own row
end

return function(input, options)
  local rows, seen, tables = {}, {}, 0
  for line in input:gmatch("[^\n]+") do
    if line == "*filter" then tables = tables + 1 end
    if line:match("^### tuple ### ") then
      local f = {}
      for word in line:gmatch("%S+") do f[#f + 1] = word end
      if #f < 10 then error("a rule line is cut short: " .. line) end
      local action = f[4]:gsub("^route:", "rt:")
      local proto, dport, to, sport, from, dir = f[5], f[6], any(f[7]), f[8], any(f[9]), f[10]
      local note = f[11] and f[11]:match("^comment=(%x*)$")
      note = note and unhex(note) or ""
      local port = sport == "any" and dport or (dport .. " (sport " .. sport .. ")")
      local id = table.concat({ action, proto, port, to, from, dir }, "|")
      if not seen[id] then -- the IPv4 and IPv6 twins are one rule to you
        seen[id] = true
        local label = ("%-8s %-9s %-5s %-13s %-22s %-18s %s"):format(
          action, dir, proto, cut(port, 13), cut(from, 22), cut(to, 18), note)
        rows[#rows + 1] = { label = label, key = label, action = action, dir = dir,
          proto = proto, port = port, from = from, to = to, note = note }
      end
    end
  end
  -- Text that is not a rules file must not look like "no rules".
  if tables == 0 and input:match("%S") then error("this is not a ufw rules file") end
  return rows
end
