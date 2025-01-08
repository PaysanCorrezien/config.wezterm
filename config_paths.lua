-- config_paths.lua
local platform = require("platform")

local M = {}

-- Base directories
M.base = {
    config = platform.join_path(platform.config_dir, "wezterm"),
    documents = platform.documents_dir,
    home = platform.home_dir,
    music = platform.join_path(platform.home_dir, platform.is_windows and "Music" or "Musique"),
}

-- Application directories
M.apps = {
    notes = platform.join_path(M.base.documents, "Notes"),
    config = M.base.config,
    music = M.base.music,
}

-- Commands
M.commands = {
    -- Editor commands
    editor = platform.is_windows and "nvim.exe" or "nvim",
    
    -- Music player commands
    music_player = platform.is_windows and {"explorer.exe"} or {"termusic"},
    
    -- File search commands
    file_search = platform.is_windows 
        and "rg.exe --files --type md" 
        or "rg --files --type md",
}

-- Shell configuration
M.shell = {
    -- Default shell command
    command = platform.default_shell,
    
    -- Shell initialization files
    rc_file = platform.is_windows 
        and platform.join_path(M.base.home, "Documents", "PowerShell", "Microsoft.PowerShell_profile.ps1")
        or platform.join_path(M.base.home, ".zshrc"),
}

return M 