--[[
-- File: dashboard.lua
-- Description: Fancy and Blazing Fast start screen plugin of neovim
-- See: https://github.com/nvimdev/dashboard-nvim
--]]
return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  config = function()
    require("dashboard").setup({ theme = "doom", config = GogoVIM.UI.dash })
  end,
}
