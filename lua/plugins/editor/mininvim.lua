return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.icons").setup()
    require("mini.surround").setup()
    require("mini.ai").setup()
    require("mini.doc").setup()
    require("mini.notify").setup()
    require("mini.statusline").setup()
    require("mini.tabline").setup()
    require("mini.files").setup()
    require("config").load_mapping("minifiles")
  end,
}
