-- config.lua
local wezterm = require("wezterm")
local act = wezterm.action

-- Import our modules
require("bar") -- Just load the tabline setup
local keymap = require("keymap")
local keymodes = require("keymap_modes")
local settings = require("settings")

-- Create configuration table
local config = {
	-- Add key mappings if they exist
	keys = keymap and keymap.keys,

	-- Add key modes if they exist
	key_tables = keymodes,
}

-- Merge settings if they exist and are a table
if settings and type(settings) == "table" then
	for k, v in pairs(settings) do
		config[k] = v
	end
end

return config
