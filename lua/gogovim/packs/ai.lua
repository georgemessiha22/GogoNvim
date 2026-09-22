-- Markdown-render
GogoVIM.AddPack({
  src = GogoVIM.GH("MeanderingProgrammer/render-markdown.nvim"),
  data = {
    ft = { "markdown", "Avante", "codecompanion" },
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "Avante", "codecompanion" },
        completions = { lsp = { enabled = true } },
      })
    end,
  },
})

