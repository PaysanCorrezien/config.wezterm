-- Access the shared config object
local config = _G.config
local wezterm = require("wezterm")

-- Add Windows-specific settings
config.default_prog = { "nu.exe" } -- Setting Nushell as default
config.tab_bar_at_bottom = true

-- Expanded launch menu with more shell options
config.launch_menu = {
	{
		label = "Nushell",
		args = { "nu.exe" },
	},
	{
		label = "PowerShell Core",
		args = { "pwsh.exe" },
	},
	{
		label = "Command Prompt",
		args = { "cmd.exe" },
	},
	{
		label = "WSL (Ubuntu)",
		args = { "wsl.exe", "--distribution", "Ubuntu" },
	},
	{
		label = "WSL (Default)",
		args = { "wsl.exe" },
	},
	{
		label = "Git Bash",
		args = { "C:\\Program Files\\Git\\bin\\bash.exe" },
	},
}

config.unix_domains = {
	{
		name = "windows",
	},
}
config.mux_enable_ssh_agent = false

-- Quick launcher key bindings for different shells
-- config.keys = config.keys or {}
-- table.insert(config.keys, {
--     key = "n",
--     mods = "CTRL|SHIFT",
--     action = wezterm.action.SpawnCommandInNewTab {
--         args = { "nu.exe" },
--     },
-- })
-- table.insert(config.keys, {
--     key = "w",
--     mods = "CTRL|SHIFT",
--     action = wezterm.action.SpawnCommandInNewTab {
--         args = { "wsl.exe" },
--     },
-- })

-- Windows UI tweaks
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Windows-specific font adjustments
config.font_size = 11

-- Windows renderer settings
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- Performance settings
config.animation_fps = 240
config.max_fps = 240
config.enable_wayland = false

-- Additional Windows-specific settings
config.use_resize_increments = false
config.adjust_window_size_when_changing_font_size = false
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- Optional: better color handling for Windows
config.bold_brightens_ansi_colors = true
