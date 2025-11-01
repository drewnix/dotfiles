-- Yazi Init.lua - Plugin initialization and customizations
-- This file runs synchronously at startup

-- ============================================================================
-- PLUGIN INITIALIZATION
-- ============================================================================

-- Full border plugin - enhanced visual clarity
require("full-border"):setup()

-- Git integration - shows file status in linemode
require("git"):setup()

-- Smart enter - open files or enter directories with single key
require("smart-enter"):setup({
	open_multi = false,  -- Don't open multiple files at once
})

-- ============================================================================
-- CUSTOM LINEMODE: SIZE AND MODIFICATION TIME
-- ============================================================================
-- Shows file size and modification time in a compact format
-- Example: "2.5 MB  Nov 01 14:23" or "1.2 KB  Nov 01 2023"

function Linemode:size_and_mtime()
	local time = self._file.cha.mtime
	local size = self._file:size()

	if not time or not size then
		return ui.Line("")
	end

	-- Format time based on whether it's current year
	local current_year = os.date("%Y")
	local file_year = os.date("%Y", time)
	local time_str

	if current_year == file_year then
		-- Same year: show month, day, and time
		time_str = os.date("%b %d %H:%M", time)
	else
		-- Different year: show month, day, and year
		time_str = os.date("%b %d  %Y", time)
	end

	-- Combine size and time with proper spacing
	local size_str = ya.readable_size(size):gsub(" ", "")
	return ui.Line(string.format("%s  %s", size_str, time_str))
end

-- ============================================================================
-- FOLDER-SPECIFIC RULES
-- ============================================================================
-- Note: Folder-specific auto-sorting disabled to avoid ps.sub() issues
-- You can manually change sorting with:
--   Sa - Sort alphabetically
--   Ss - Sort by size
--   Sm - Sort by modified time
--   Sn - Sort naturally

-- ============================================================================
-- STATUS BAR CUSTOMIZATION
-- ============================================================================
-- Add symlink target display to status bar

Status:children_add(function()
	local h = cx.active.current.hovered
	if not h or not h.link_to then
		return ui.Line("")
	end

	return ui.Line {
		ui.Span(" -> "),
		ui.Span(tostring(h.link_to)):fg("cyan"),
	}
end, 500, Status.RIGHT)

-- ============================================================================
-- UNIX PERMISSIONS DISPLAY (Linux/macOS)
-- ============================================================================
-- Show file owner and group in status bar

if ya.target_family() ~= "windows" then
	Status:children_add(function()
		local h = cx.active.current.hovered
		if not h or not h.cha then
			return ui.Line("")
		end

		local user = ya.user_name(h.cha.uid) or tostring(h.cha.uid)
		local group = ya.group_name(h.cha.gid) or tostring(h.cha.gid)

		return ui.Line {
			ui.Span(" "),
			ui.Span(user):fg("magenta"),
			ui.Span(":"),
			ui.Span(group):fg("blue"),
			ui.Span(" "),
		}
	end, 1000, Status.RIGHT)
end

-- ============================================================================
-- ADDITIONAL CUSTOMIZATIONS
-- ============================================================================

-- Example: Custom header with current directory info
-- Uncomment and modify as needed
--[[
Header:children_add(function()
	local cwd = cx.active.current.cwd
	return ui.Line {
		ui.Span(" " .. tostring(cwd)):fg("blue"):bold(),
	}
end, 1000, Header.LEFT)
]]

-- Example: Confirm dialog on quit with multiple tabs
-- Uncomment to enable quit confirmation when tabs > 1
--[[
function Manager:quit()
	if #cx.tabs > 1 then
		local yes = ya.confirm({
			pos = { "center", w = 60, h = 10 },
			title = "Quit Yazi?",
			content = ui.Text("You have multiple tabs open. Really quit?"):wrap(ui.Wrap.YES),
		})
		if not yes then
			return
		end
	end
	ya.manager_emit("quit", {})
end
]]
