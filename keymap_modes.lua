local wez = require("wezterm")
local act = wez.action

local keymodes = {}

-- Copy Mode key table
keymodes.copy_mode = {
	-- Basic operations
	{
		key = "Escape",
		mods = "NONE",
		action = act.CopyMode("Close"),
	},
	{
		key = "q",
		mods = "NONE",
		action = act.CopyMode("Close"),
	},
	{
		key = "Tab",
		mods = "NONE",
		action = act.CopyMode("MoveForwardWord"),
	},
	{
		key = "Tab",
		mods = "SHIFT",
		action = act.CopyMode("MoveBackwardWord"),
	},
	{
		key = "Enter",
		mods = "NONE",
		action = act.CopyMode("MoveToStartOfNextLine"),
	},
	{
		key = "Space",
		mods = "NONE",
		action = act.CopyMode({ SetSelectionMode = "Cell" }),
	},

	-- Line navigation
	{
		key = "0",
		mods = "NONE",
		action = act.CopyMode("MoveToStartOfLine"),
	},
	{
		key = "$",
		mods = "SHIFT",
		action = act.CopyMode("MoveToEndOfLineContent"),
	},
	{
		key = "^",
		mods = "NONE",
		action = act.CopyMode("MoveToStartOfLineContent"),
	},

	-- Jump operations
	{
		key = ",",
		mods = "NONE",
		action = act.CopyMode("JumpReverse"),
	},
	{
		key = ";",
		mods = "NONE",
		action = act.CopyMode("JumpAgain"),
	},
	{
		key = "F",
		mods = "SHIFT",
		action = act.CopyMode({ JumpBackward = { prev_char = false } }),
	},
	{
		key = "f",
		mods = "NONE",
		action = act.CopyMode({ JumpForward = { prev_char = false } }),
	},
	{
		key = "T",
		mods = "SHIFT",
		action = act.CopyMode({ JumpBackward = { prev_char = true } }),
	},
	{
		key = "t",
		mods = "NONE",
		action = act.CopyMode({ JumpForward = { prev_char = true } }),
	},

	-- Scrollback navigation
	{
		key = "G",
		mods = "SHIFT",
		action = act.CopyMode("MoveToScrollbackBottom"),
	},
	{
		key = "g",
		mods = "NONE",
		action = act.CopyMode("MoveToScrollbackTop"),
	},

	-- Basic movement
	{
		key = "h",
		mods = "NONE",
		action = act.CopyMode("MoveLeft"),
	},
	{
		key = "j",
		mods = "NONE",
		action = act.CopyMode("MoveDown"),
	},
	{
		key = "k",
		mods = "NONE",
		action = act.CopyMode("MoveUp"),
	},
	{
		key = "l",
		mods = "NONE",
		action = act.CopyMode("MoveRight"),
	},

	-- Viewport navigation
	{
		key = "H",
		mods = "SHIFT",
		action = act.CopyMode("MoveToViewportTop"),
	},
	{
		key = "L",
		mods = "SHIFT",
		action = act.CopyMode("MoveToViewportBottom"),
	},
	{
		key = "M",
		mods = "SHIFT",
		action = act.CopyMode("MoveToViewportMiddle"),
	},

	-- Selection modes
	{
		key = "V",
		mods = "SHIFT",
		action = act.CopyMode({ SetSelectionMode = "Line" }),
	},
	{
		key = "v",
		mods = "NONE",
		action = act.CopyMode({ SetSelectionMode = "Cell" }),
	},
	{
		--NOTE: i use ctrl b in vim to replace ctrl V for visual block mode for better cross compatibility with shell/ os
		key = "b",
		mods = "CTRL",
		action = act.CopyMode({ SetSelectionMode = "Block" }),
	},
	{
		key = "s",
		mods = "CTRL",
		action = act.CopyMode({ SetSelectionMode = "SemanticZone" }),
	},

	-- Word movement
	{
		key = "F",
		mods = "NONE",
		action = act.CopyMode({ JumpBackward = { prev_char = false } }),
	},
	{
		key = "F",
		mods = "SHIFT",
		action = act.CopyMode({ JumpBackward = { prev_char = false } }),
	},
	{
		key = "E",
		mods = "SHIFT",
		action = act.CopyMode("MoveForwardWordEnd"),
	},
	{
		key = "B",
		mods = "SHIFT",
		action = act.CopyMode("MoveBackwardWord"),
	},
	{
		key = "W",
		mods = "SHIFT",
		action = act.CopyMode("MoveForwardWord"),
	},
	{
		key = "b",
		mods = "NONE",
		action = act.CopyMode("MoveBackwardWord"),
	},
	{
		key = "e",
		mods = "NONE",
		action = act.CopyMode("MoveForwardWordEnd"),
	},
	{
		key = "w",
		mods = "NONE",
		action = act.CopyMode("MoveForwardWord"),
	},

	-- Page movement
	{
		key = "d",
		mods = "CTRL",
		action = act.CopyMode({ MoveByPage = 0.5 }),
	},
	{
		key = "u",
		mods = "CTRL",
		action = act.CopyMode({ MoveByPage = -0.5 }),
	},

	-- Copy operation
	{
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			{ CopyMode = "Close" },
		}),
	},
}

-- Search Mode key table
keymodes.search_mode = {
	{
		key = "Escape",
		mods = "NONE",
		action = act.CopyMode("Close"),
	},
	{
		key = "q",
		mods = "NONE",
		action = act.CopyMode("Close"),
	},
	{
		key = "Enter",
		mods = "NONE",
		action = act.CopyMode("PriorMatch"),
	},
	{
		key = "n",
		mods = "CTRL",
		action = act.CopyMode("NextMatch"),
	},
	{
		key = "N",
		mods = "CTRL|SHIFT",
		action = act.CopyMode("PriorMatch"),
	},
	{
		key = "r",
		mods = "CTRL",
		action = act.CopyMode("CycleMatchType"),
	},
	{
		key = "u",
		mods = "CTRL",
		action = act.CopyMode("ClearPattern"),
	},
	{
		key = "PageUp",
		mods = "NONE",
		action = act.CopyMode("PriorMatchPage"),
	},
	{
		key = "PageDown",
		mods = "NONE",
		action = act.CopyMode("NextMatchPage"),
	},
	{
		key = "UpArrow",
		mods = "NONE",
		action = act.CopyMode("PriorMatch"),
	},
	{
		key = "DownArrow",
		mods = "NONE",
		action = act.CopyMode("NextMatch"),
	},
}

-- Font Mode key table
keymodes.font_mode = {
	{
		key = "+",
		mods = "NONE",
		action = act.IncreaseFontSize,
	},
	{
		key = "-",
		mods = "NONE",
		action = act.DecreaseFontSize,
	},
	{
		key = "0",
		mods = "NONE",
		action = act.ResetFontSize,
	},
}

-- Window Mode key table
keymodes.window_mode = {
	{
		key = "p",
		mods = "NONE",
		action = act.PaneSelect,
	},
	{
		key = "x",
		mods = "NONE",
		action = act.PaneSelect({ mode = "SwapWithActive" }),
	},
	{
		key = "q",
		mods = "NONE",
		action = act.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "o",
		mods = "NONE",
		action = act.TogglePaneZoomState,
	},
	{
		key = "v",
		mods = "NONE",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "s",
		mods = "NONE",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "LeftArrow",
		mods = "NONE",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "DownArrow",
		mods = "NONE",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "UpArrow",
		mods = "NONE",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "RightArrow",
		mods = "NONE",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "h",
		mods = "NONE",
		action = act.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "NONE",
		action = act.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "NONE",
		action = act.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "NONE",
		action = act.ActivatePaneDirection("Right"),
	},
	{
		key = "<",
		mods = "NONE",
		action = act.AdjustPaneSize({ "Left", 2 }),
	},
	{
		key = ">",
		mods = "SHIFT",
		action = act.AdjustPaneSize({ "Right", 2 }),
	},
	{
		key = "+",
		mods = "NONE",
		action = act.AdjustPaneSize({ "Up", 2 }),
	},
	{
		key = "-",
		mods = "NONE",
		action = act.AdjustPaneSize({ "Down", 2 }),
	},
}

return keymodes
