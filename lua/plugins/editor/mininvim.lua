return {
  "echasnovski/mini.nvim",
  version = "*",
  config = function()
    require("mini.ai").setup()
    require("mini.align").setup()
    -- require("mini.animate").setup()
    require("mini.basics").setup()
    require("mini.bracketed").setup()
    require("mini.bufremove").setup()
    -- require("mini.clue").setup() -- replacement to whichKey
    require("mini.comment").setup()
    -- require("mini.completion").setup({ set_vim_settings = false })
    -- require("mini.cursorword").setup() -- highlight words under cursor
    -- require("mini.doc").setup()
    -- require("mini.extra").setup()
    require("mini.files").setup()
    require("config").load_mapping("minifiles")
    -- require("mini.fuzzy").setup()
    -- require("mini.git").setup()
    --
    -- replaced with todo-comment
    -- local hipatterns = require("mini.hipatterns")
    -- hipatterns.setup({
    --   highlighters = {
    --     -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    --     fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    --     hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    --     todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    --     note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
    --     ie = { pattern = "%f[%w]()I.E()%f[%W]", group = "MiniHipatternsNote" },
    --     ies = { pattern = "%f[%w]()i.e()%f[%W]", group = "MiniHipatternsNote" },
    --
    --     -- Highlight hex color strings (`#rrggbb`) using that color
    --     hex_color = hipatterns.gen_highlighter.hex_color(),
    --   },
    -- })

    require("mini.icons").setup()
    require("mini.indentscope").setup()
    -- require("mini.jump").setup()
    -- require("mini.jump2d").setup()
    -- require("mini.map").setup()
    require("mini.misc").setup()
    -- require("mini.move").setup()
    -- require("mini.notify").setup()
    -- require("mini.operators").setup()
    require("mini.pairs").setup()
    require("mini.pick").setup()
    require("mini.sessions").setup()
    -- require("mini.splitjoin").setup()
    require("mini.starter").setup()
    require("mini.statusline").setup()
    require("mini.surround").setup()
    require("mini.tabline").setup()
    -- require("mini.test").setup()
    require("mini.trailspace").setup()
    require("mini.visits").setup()
  end,
}
