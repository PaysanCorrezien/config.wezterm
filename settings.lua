-- settings.lua
local wez = require("wezterm")
local resurrect = wez.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Initialize settings table
local M = {
	-- General settings
	automatically_reload_config = true,
	warn_about_missing_glyphs = false,
	check_for_updates = false,
	-- enable_wayland = true,
	front_end = "WebGpu",
	enable_wayland = false,

	-- Leader key configuration
	leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 500 },

	-- Window settings
	-- window_decorations = "NONE", -- Removes window borders
	tab_bar_at_bottom = true, -- Places tab bar at bottom
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

-- Saves the state whenever I select a workspace
wez.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	resurrect.save_state(workspace_state.get_workspace_state())
end)

-- Configure auto save every 15 minutes by default
resurrect.periodic_save()

return M
