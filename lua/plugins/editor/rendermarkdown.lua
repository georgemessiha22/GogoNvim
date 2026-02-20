return {
    -- Make sure to set this up properly if you have lazy=true
    'MeanderingProgrammer/render-markdown.nvim',
    config = function()
        require("render-markdown").setup({
            file_types = { "markdown", "Avante", "codecompanion" },
            completions = { lsp = { enabled = true } },
        })
    end
}
