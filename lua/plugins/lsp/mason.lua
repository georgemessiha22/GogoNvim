--[[
  File: mason.lua
  Description: Mason plugin configuration (with lspconfig)
  See: https://github.com/williamboman/mason.nvim
]]

-- Mason {{{
return {
  "williamboman/mason.nvim",
  build = ":MasonUpdate",
  config = function(_, opts)
    local icons = GogoUI.icons
    opts = vim.tbl_deep_extend("force", opts, {
      ui = {
        icons = {
          package_installed = icons.misc.Package,
          package_pending = icons.kinds.Property,
          package_uninstalled = icons.ui.BoldClose,
        },
      },
    })
    require("mason").setup(opts)
  end,
}
-- }}}
