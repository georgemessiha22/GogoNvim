--[[
-- Here add all variables needed to configure neovim, or basically any settings that subject to change.
--]]
return {
  localleader = "\\",
  font = "JetBrainsMonoNL Nerd Font",

  ------------------------------- base46 -------------------------------------
  theme = "catppuccin", -- "lunaperche", "zaibatsu", "habamax", "retrobox", "flow", "rose-pine-moon", -- default theme
  transparency = false,
  lsp_semantic_tokens = true, -- needs nvim v0.9, just adds highlight groups for lsp semantic tokens
  termguicolors = true,

  -- Default Plugins {{{
  disabled_builtins = {
    --	"netrw",
    --	"netrwPlugin",
    --	"netrwSettings",
    --	"netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    -- "getscript",
    -- "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    -- "2html_plugin",
    -- "logipat",
    -- "rrhelper",
    -- "spellfile_plugin",
    -- "matchit",
  },
  icons = require("gogovim.ui.icons"),
}
