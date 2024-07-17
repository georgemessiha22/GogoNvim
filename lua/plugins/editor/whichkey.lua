--[[
  File: whichkey.lua
  Description: WhichKey plugin configuration
  See: https://github.com/folke/which-key.nvim
]]
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = { "<leader>", '"', "'", "`", "c", "v", "g", "f", "c", "<C>", "t" },
  dependencies = {
    { "echasnovski/mini.nvim", version = false },
  },
  opts = {
    plugins = { spelling = true },
    defaults = {
      {
        mode = { "n", "v" },
        { "<leader><leader>", group = "IconPicker" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>n", group = "NeoTree" },
        { "<leader>sn", group = "Noice" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "z", group = "fold" },
        { "gc", group = "Comment" },
      },
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
      opts.defaults["<leader>sn"] = { name = "+Noice" }
    end
    require("which-key").setup(opts)
    require("config").load_mapping("whichkey")
  end,
}
