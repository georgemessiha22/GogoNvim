return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.icons").setup()
    require("mini.surround").setup()
    require("mini.ai").setup()
    require("mini.doc").setup()
    -- require("mini.notify").setup()
    require("mini.statusline").setup()
    require("mini.tabline").setup()
    require("mini.files").setup()
    require("mini.completion").setup()
    require("config").load_mapping("minifiles")
    require("mini.comment").setup()
    local hipatterns = require("mini.hipatterns")
    hipatterns.setup({
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
      },
    })
  end,
}
