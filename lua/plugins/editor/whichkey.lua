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
    defaults = { -- Topics with keys
      {
        mode = { "n", "v" },
        { "<leader><leader>", group = "IconPicker" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>n", group = "Explore" },
        { "<leader>sn", group = "Noice" },
        { "[", group = "prev" },
        { "]", group = "next" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "z", group = "fold" },
        { "gc", group = "Comment" },
      },
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
