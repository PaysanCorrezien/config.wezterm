-- bar.lua
local wezterm = require("wezterm")
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")

-- Setup tabline plugin
tabline.setup({
	options = {
		icons_enabled = true,
		-- theme = "Catppuccin Mocha",
		color_overrides = {},
		section_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
		component_separators = {
			left = wezterm.nerdfonts.pl_left_soft_divider,
			right = wezterm.nerdfonts.pl_right_soft_divider,
		},
		tab_separators = {
			left = wezterm.nerdfonts.pl_left_hard_divider,
			right = wezterm.nerdfonts.pl_right_hard_divider,
		},
	},
	sections = {
		tabline_a = { "mode" },
		tabline_b = {
			{
				"workspace",
				icon = { wezterm.nerdfonts.md_tab, color = { fg = "#89b4fa" } },
			},
		},
		tabline_c = { " " },
		tab_active = {
			"index",
			"./",
			{ "parent", padding = 0 },
			"/",
			{ "cwd", padding = { left = 0, right = 1 } },
			{
				"process",
				icons_only = true --[[ , padding = { left = 1, right = 1 } ]],
			},
			{ "zoomed", padding = 0 },
		},
		tab_inactive = {
			"index",
			{ "process", padding = { left = 1, right = 1 } },
			-- FIX:
			-- { "parent", padding = 0 },
			-- "/",
			-- { "cwd", padding = { left = 0, right = 1 } },
		},
		tabline_x = { "cpu" },
		tabline_y = { "datetime", "battery" },
		tabline_z = { "hostname" },
	},
	extensions = { "resurrect" },
})
