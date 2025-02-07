-- keymap.lua
local wez = require("wezterm")
local wezterm = require("wezterm")
local act = wez.action
-- Plugin imports
local workspace_switcher = wez.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")
local resurrect = wez.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local platform = require("platform")
local paths = require("config_paths")

local hostname = wez.hostname()
local username = os.getenv("USER") or os.getenv("USERNAME")

-- Declare variables before if block to maintain scope
local previous_workspace
local semantic_zones
local marks
local portal
local ssh
local workspace_manager

if username == "dylan" and (hostname == "workstation" or hostname == "lenovo") then
	-- Set package path for local modules
	package.path = package.path .. ";" .. platform.join_path(platform.home_dir, "repo", "?.wezterm", "init.lua")
	-- Local module imports
	previous_workspace = require("previous_workspace")
	semantic_zones = require("semantic_zones")
	marks = require("marks")
	portal = require("portal")
	ssh = require("ssh_menu")
	workspace_manager = require("workspace_manager")
else
	-- GitHub imports
	previous_workspace = wez.plugin.require("https://github.com/paysancorrezien/previous_workspace.wezterm")
	semantic_zones = wez.plugin.require("https://github.com/paysancorrezien/semantic_zones.wezterm")
	marks = wez.plugin.require("https://github.com/paysancorrezien/marks.wezterm")
	portal = wez.plugin.require("https://github.com/paysancorrezien/portal.wezterm")
	ssh = wez.plugin.require("https://github.com/paysancorrezien/ssh_menu.wezterm")
	workspace_manager = wez.plugin.require("https://github.com/paysancorrezien/workspace_manager.wezterm")
end

-- Create module table
local M = {}

-- Helper function to create platform-agnostic shell command
local function create_shell_command(cmd)
	if platform.is_windows then
		-- Escape backslashes in the command for PowerShell
		cmd = cmd:gsub("\\", "\\\\")
		return { "pwsh.exe", "-NoLogo", "-NoProfile", "-Command", cmd }
	else
		return { "zsh", "-c", "source " .. paths.shell.rc_file .. " && " .. cmd }
	end
end

-- Define keybindings
M.keys = {
	{ key = "`", mods = "CTRL", action = act.ToggleFloatingPane },
	{
		key = "g",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			-- First check if we're already in a lazygit pane
			local current_title = pane:get_title()
			if current_title:match("lazygit") then
				window:perform_action(wezterm.action.ToggleFloatingPane, pane)
				return
			end

			-- Create new lazygit pane with platform-specific command
			local lazygit_cmd = platform.is_windows and { "lazygit.exe" } -- Windows
				or { "lazygit" } -- Unix-like systems

			window:perform_action(
				wezterm.action.SpawnCommandInNewFloatingPane({
					args = lazygit_cmd,
				}),
				pane
			)
		end),
	},
	{
		key = "Tab",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			-- Get current pane text
			local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
			wezterm.log_info("Got pane text")

			-- Create a temporary file for the processed text
			local name = os.tmpname()
			local f = io.open(name, "w+")

			-- Use a set to track unique entries
			local seen = {}
			local unique_entries = {}

			-- Helper function to add unique entries
			local function add_unique(entry)
				if not seen[entry] then
					seen[entry] = true
					table.insert(unique_entries, entry)
				end
			end

			-- Process lines, skip empty lines and duplicates
			for line in text:gmatch("[^\r\n]+") do
				local trimmed = line:match("^%s*(.-)%s*$") -- Trim whitespace
				if #trimmed > 0 then -- Skip empty lines
					add_unique(trimmed)
				end

				-- Split line into words and word pairs
				local words = {}
				for word in line:gmatch("%S+") do
					table.insert(words, word)
				end

				-- Add significant words (longer than 3 chars)
				for _, word in ipairs(words) do
					if #word > 3 then
						add_unique(word)
					end
				end

				-- Add word pairs
				for i = 1, #words - 1 do
					local pair = words[i] .. " " .. words[i + 1]
					if #pair > 7 then -- Only add meaningful pairs
						add_unique(pair)
					end
				end
			end

			-- Write unique entries to file
			f:write(table.concat(unique_entries, "\n"))
			f:flush()
			f:close()

			-- Create new floating pane with fzf
			local current_pane_id = pane:pane_id()

			-- Platform-specific script content
			local script_content
			if platform.is_windows then
				script_content = string.format(
					[[
$selected_text = Get-Content %s | fzf --multi --height=80%% --layout=reverse --border --preview 'echo {}' --preview-window=up:3:wrap --header='Select text (TAB for multi-select)'
if ($selected_text) {
    wezterm cli activate-pane --pane-id %s
    wezterm cli send-text --pane-id %s -- $selected_text
}]],
					name,
					current_pane_id,
					current_pane_id
				)
			else
				script_content = string.format(
					[[
selected_text=$(cat %s | fzf \
    --multi \
    --height=80%% \
    --layout=reverse \
    --border \
    --preview 'echo {}' \
    --preview-window=up:3:wrap \
    --header="Select text (TAB for multi-select)")
if [ -n "$selected_text" ]; then
    wezterm cli activate-pane --pane-id %s
    wezterm cli send-text --pane-id %s -- "$selected_text"
fi]],
					name,
					current_pane_id,
					current_pane_id
				)
			end

			-- Save the script with platform-appropriate extension
			local script_ext = platform.is_windows and ".ps1" or ".sh"
			local script_name = os.tmpname() .. script_ext
			local script = io.open(script_name, "w+")
			script:write(script_content)
			script:flush()
			script:close()

			-- Make script executable on Unix systems
			if not platform.is_windows then
				os.execute("chmod +x " .. script_name)
			end

			-- Run the script in a floating pane with platform-appropriate shell
			local shell_cmd = platform.is_windows and { "pwsh.exe", "-NoLogo", "-NoProfile", "-File", script_name }
				or { "bash", script_name }

			window:perform_action(
				wezterm.action.SpawnCommandInNewFloatingPane({
					args = shell_cmd,
				}),
				pane
			)

			-- Cleanup after a delay
			wezterm.sleep_ms(1000)
			os.remove(name)
			os.remove(script_name)
		end),
	},
	{
		key = "Tab",
		mods = "CTRL",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "Tab",
		mods = "CTRL|SHIFT",
		action = act.ActivateTabRelative(-1),
	},

	-- Clipboard operations
	{
		key = "c",
		mods = "CTRL|SHIFT",
		action = act.CopyTo("Clipboard"),
	},
	{
		key = "v",
		mods = "CTRL|SHIFT",
		action = act.PasteFrom("Clipboard"),
	},
	{
		key = "v",
		mods = "CTRL",
		action = act.PasteFrom("Clipboard"),
	},

	-- System operations
	{
		key = "d",
		mods = "CTRL|SHIFT",
		action = act.ShowDebugOverlay,
	},
	{
		key = "n",
		mods = "CTRL|SHIFT",
		action = act.SpawnWindow,
	},
	{
		key = "p",
		mods = "CTRL|SHIFT",
		action = act.ActivateCommandPalette,
	},
	{
		key = "r",
		mods = "CTRL|SHIFT",
		action = act.ReloadConfiguration,
	},
	{
		key = "t",
		mods = "CTRL|SHIFT",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = act.CharSelect({
			copy_on_select = true,
			copy_to = "ClipboardAndPrimarySelection",
		}),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = act.CloseCurrentTab({ confirm = true }),
	},

	-- Scrolling
	{
		key = "PageUp",
		mods = "NONE",
		action = act.ScrollByPage(-1),
	},
	{
		key = "PageDown",
		mods = "NONE",
		action = act.ScrollByPage(1),
	},

	-- Selection and paste
	{
		key = "Insert",
		mods = "CTRL|SHIFT",
		action = act.PasteFrom("PrimarySelection"),
	},

	-- Split operations
	{
		key = "h",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = '"',
		mods = "CTRL|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "%",
		mods = "CTRL|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wez.action.SplitPane({
			direction = "Right",
		}),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wez.action.SplitPane({
			direction = "Down",
		}),
	},

	-- Search and copy mode
	{
		key = "x",
		mods = "CTRL|SHIFT",
		action = act.ActivateCopyMode,
	},
	{
		key = "f",
		mods = "CTRL|SHIFT",
		action = act.Search("CurrentSelectionOrEmptyString"),
	},

	-- Pane size adjustments
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Left", 10 }),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Down", 10 }),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Up", 10 }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = act.AdjustPaneSize({ "Right", 10 }),
	},

	-- Number key passthrough
	{
		key = "1",
		mods = "CTRL",
		action = act.SendKey({ key = "1", mods = "CTRL" }),
	},
	{
		key = "2",
		mods = "CTRL",
		action = act.SendKey({ key = "2", mods = "CTRL" }),
	},
	{
		key = "3",
		mods = "CTRL",
		action = act.SendKey({ key = "3", mods = "CTRL" }),
	},
	{
		key = "4",
		mods = "CTRL",
		action = act.SendKey({ key = "4", mods = "CTRL" }),
	},
	{
		key = "5",
		mods = "CTRL",
		action = act.SendKey({ key = "5", mods = "CTRL" }),
	},
	{
		key = "6",
		mods = "CTRL",
		action = act.SendKey({ key = "6", mods = "CTRL" }),
	},
	{
		key = "7",
		mods = "CTRL",
		action = act.SendKey({ key = "7", mods = "CTRL" }),
	},
	{
		key = "m",
		mods = "CTRL",
		action = act.SendKey({ key = "m", mods = "CTRL" }),
	},

	-- Semantic zone navigation
	{
		key = "o",
		mods = "CTRL|SHIFT",
		action = wez.action_callback(function(window, pane)
			local output = semantic_zones.get_last_command_output(pane)
			if output then
				window:copy_to_clipboard(output)
				window:toast_notification("WezTerm", "Last command output copied to clipboard", nil, 2000)
			else
				window:toast_notification("WezTerm", "No command output found", nil, 4000)
			end
		end),
	},
	{
		key = ",",
		mods = "CTRL",
		action = wez.action_callback(function(window, pane)
			return semantic_zones.select_output_zone(window, pane, "previous")
		end),
	},
	{
		key = ".",
		mods = "CTRL",
		action = wez.action_callback(function(window, pane)
			return semantic_zones.select_output_zone(window, pane, "next")
		end),
	},

	-- Portal teleport bindings
	{
		key = "N",
		mods = "LEADER",
		action = portal.teleport({
			name = "Notes",
			action = {
				args = create_shell_command(
					string.format(
						"%s -c \"lua require('fzf-lua').files({cwd = [[%s]], cmd = [[%s]], prompt = 'Notes> '})\"",
						paths.commands.editor,
						paths.apps.notes,
						paths.commands.file_search
					)
				),
				cwd = paths.apps.notes,
				env = { EDITOR = paths.commands.editor },
			},
		}),
	},
	{
		key = "n",
		mods = "LEADER",
		action = portal.teleport({
			name = "Config",
			action = {
				args = create_shell_command(
					string.format(
						"%s -c \"lua require('fzf-lua').files({cwd = [[%s]], prompt = 'Config> '})\"",
						paths.commands.editor,
						paths.apps.config
					)
				),
				cwd = paths.apps.config,
			},
		}),
	},
	{
		key = ".",
		mods = "LEADER",
		action = portal.teleport({
			name = "Music",
			action = {
				args = paths.commands.music_player,
				cwd = paths.apps.music,
			},
		}),
	},

	-- Workspace and pane management
	{
		--TODO: make use of resurrect here
		key = "F",
		mods = "LEADER",
		action = workspace_switcher.switch_workspace(),
	},
	{
		key = "f",
		mods = "LEADER",
		action = workspace_manager.SwitchPanes(),
	},
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "s",
		mods = "SHIFT|LEADER",
		action = wez.action_callback(function(window, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
	{
		key = "o",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			resurrect.fuzzy_load(window, pane, function(id, label)
				local type = string.match(id, "^([^/]+)")
				id = string.match(id, "([^/]+)$")
				id = string.match(id, "(.+)%..+$")
				local state
				if type == "workspace" then
					state = resurrect.load_state(id, "workspace")
					resurrect.workspace_state.restore_workspace(state, {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					})
				elseif type == "window" then
					state = resurrect.load_state(id, "window")
					resurrect.window_state.restore_window(window:mux_window(), state, {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					})
				end
			end)
		end),
	},
	{
		key = "m",
		mods = "LEADER",
		action = wez.action_callback(function(window)
			marks.AccessMarkFromMemory(window)
		end),
	},
	{
		key = "M",
		mods = "LEADER",
		action = wez.action_callback(function(window)
			marks.WriteMarkToMemory(window)
		end),
	},

	-- SSH menu (marked as not working)
	{
		key = "Z",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			ssh.ssh_menu(window, pane)
		end),
	},

	-- Previous workspace switcher
	{
		key = "b",
		mods = "LEADER",
		action = previous_workspace.switch_to_previous_workspace(),
	},

	-- Session state management
	{
		key = "S",
		mods = "LEADER",
		action = wez.action_callback(function(window, pane)
			resurrect.save_state(resurrect.workspace_state.get_workspace_state())
		end),
	},
}
return M
