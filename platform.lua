-- platform.lua
local wezterm = require("wezterm")

local M = {}

-- Detect the platform
M.is_windows = wezterm.target_triple:find("windows") ~= nil
M.is_linux = wezterm.target_triple:find("linux") ~= nil
M.is_macos = wezterm.target_triple:find("darwin") ~= nil

-- Get platform-specific path separator
M.path_sep = M.is_windows and '\\' or '/'

-- Get platform-specific home directory
M.home_dir = M.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")

-- Get default shell
M.default_shell = (function()
    if M.is_windows then
        return {"pwsh.exe"}  -- PowerShell Core
    elseif M.is_linux then
        return {"zsh"}
    else  -- macOS
        return {"zsh"}
    end
end)()

-- Platform-specific command prefixes/wrappers
M.cmd_prefix = M.is_windows and {"cmd.exe", "/c"} or {"/bin/sh", "-c"}

-- Helper function to convert paths between platforms
function M.convert_path(path)
    if M.is_windows then
        return path:gsub("/", "\\")
    else
        return path:gsub("\\", "/")
    end
end

-- Helper function to join paths in a platform-agnostic way
function M.join_path(...)
    local args = {...}
    return table.concat(args, M.path_sep)
end

-- Get user's config directory
M.config_dir = (function()
    if M.is_windows then
        return M.join_path(M.home_dir, "AppData", "Local")
    elseif M.is_linux then
        return M.join_path(M.home_dir, ".config")
    else  -- macOS
        return M.join_path(M.home_dir, "Library", "Application Support")
    end
end)()

-- Get user's documents directory
M.documents_dir = (function()
    if M.is_windows then
        return M.join_path(M.home_dir, "Documents")
    else
        return M.join_path(M.home_dir, "Documents")
    end
end)()

-- Platform-specific command execution wrapper
function M.execute_command(cmd, args)
    if M.is_windows then
        -- For Windows, we might need to wrap certain commands
        if type(cmd) == "string" and cmd:find("/") then
            -- Convert Unix-style paths to Windows
            cmd = M.convert_path(cmd)
        end
    end
    
    if type(cmd) == "string" then
        return wezterm.action.SpawnCommandInNewTab({
            args = {cmd, unpack(args or {})},
        })
    else
        return wezterm.action.SpawnCommandInNewTab({
            args = {unpack(cmd), unpack(args or {})},
        })
    end
end

return M 