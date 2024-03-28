--[[
  File: whichkey.lua
  Description: WhichKey plugin configuration
  See: https://github.com/folke/which-key.nvim
]]
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = { "<leader>", '"', "'", "`", "c", "v", "g", "f", "c", "<C>", "t" },
  opts = {
    plugins = { spelling = true },
    defaults = {
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["gs"] = { name = "+surround" },
      ["z"] = { name = "+fold" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      ["<leader><tab>"] = { name = "+tabs" },
      ["<leader>n"] = { name = "+NeoTree" },
      -- ["<leader>b"] = { name = "+buffer" },
      -- ["<leader>c"] = { name = "+code" },
      -- ["<leader>f"] = { name = "+file/find" },
      -- ["<leader>g"] = { name = "+git" },
      -- ["<leader>gh"] = { name = "+hunks" },
      -- ["<leader>q"] = { name = "+quit/session" },
      -- ["<leader>s"] = { name = "+search" },
      -- ["<leader>u"] = { name = "+ui" },
      -- ["<leader>w"] = { name = "+windows" },
      -- ["<leader>x"] = { name = "+diagnostics/quickfix" },
    },
  },
  config = function(_, opts)
    if GogoVIM.has("noice.nvim") then
      opts.defaults["<leader>sn"] = { name = "+noice" }
    end
    require("which-key").setup(opts)
    require("which-key").register(opts.defaults)
    require("config").load_mapping("whichkey")
  end,
}
