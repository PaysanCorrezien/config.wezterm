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
	enable_kitty_keyboard = true,
	max_fps = 144,

	-- Leader key configuration
	leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 500 },

	-- window_decorations = "NONE", -- Removes window borders
	tab_bar_at_bottom = true, -- Places tab bar at bottom

	--NOTE: https://github.com/wez/wezterm/pull/5576
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	floating_pane_padding = {
		left = "5%",
		right = "5%",
		top = "10%",
		bottom = "10%",
	},

	floating_pane_border = {
		left_width = "0.2cell",
		right_width = "0.2cell",
		bottom_height = "0.10cell",
		top_height = "0.10cell",
		left_color = "#c4a7e7",
		right_color = "#c4a7e7",
		bottom_color = "#c4a7e7",
		top_color = "#c4a7e7",
	},
}

-- Saves the state whenever I select a workspace
wez.on("smart_workspace_switcher.workspace_switcher.selected", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	resurrect.save_state(workspace_state.get_workspace_state())
end)

-- loads the state whenever I create a new workspace
wez.on("smart_workspace_switcher.workspace_switcher.created", function(window, path, label)
	local workspace_state = resurrect.workspace_state
	workspace_state.restore_workspace(resurrect.load_state(label, "workspace"), {
		window = window,
		relative = true,
		restore_text = true,
		on_pane_restore = resurrect.tab_state.default_on_pane_restore,
	})
end)

-- Configure auto save every 15 minutes by default
resurrect.periodic_save()

return M
