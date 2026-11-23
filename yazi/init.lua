-- yazi init.lua: plugin setup + status bar.

require("full-border"):setup()

-- git status signs; colours stay in the stone palette except for meaning
th.git = th.git or {}
th.git.modified  = ui.Style():fg("#fbbf24")
th.git.added     = ui.Style():fg("#a3e635")
th.git.untracked = ui.Style():fg("#78716c")
th.git.deleted   = ui.Style():fg("#f87171")
th.git.updated   = ui.Style():fg("#a3e635")
th.git.ignored   = ui.Style():fg("#57534e")
require("git"):setup { order = 1500 }

require("smart-enter"):setup { open_multi = true }

-- owner:group of the hovered file, right side of the status bar
Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Line {
		ui.Span(ya.user_name(h.cha.uid) or tostring(h.cha.uid)):fg("#a8a29e"),
		ui.Span(":"):fg("#57534e"),
		ui.Span(ya.group_name(h.cha.gid) or tostring(h.cha.gid)):fg("#a8a29e"),
		ui.Span(" "),
	}
end, 500, Status.RIGHT)

-- user@host in the header when inside an SSH session
Header:children_add(function()
	if ya.target_family() ~= "unix" then
		return ""
	end
	return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ": "):fg("#78716c")
end, 500, Header.LEFT)
