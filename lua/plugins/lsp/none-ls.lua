--[[
-- File: none-ls
-- Description: Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
-- See: https://github.com/nvimtools/none-ls.nvim
--]]

return {
  "nvimtools/none-ls.nvim",
  branch = "main",
  config = function()
    local null_ls = require("null-ls")
    local codespellConfig = null_ls.builtins.diagnostics.codespell.with({
      args = {
        "--ignore-words=" .. vim.fn.expand("~/.config/nvim/spell/codespell-ignore"),
        "-",
      },
    })

    null_ls.setup({
      autostart = true,
      sources = {

        -- formatters
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.rubocop,
        null_ls.builtins.formatting.sqlfmt,
        null_ls.builtins.formatting.shellharden,
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.fish_indent,
        null_ls.builtins.formatting.yamlfmt,
        null_ls.builtins.formatting.yamlfix,

        -- Diagnostics
        null_ls.builtins.diagnostics.zsh,
        codespellConfig,
        null_ls.builtins.diagnostics.commitlint,
        null_ls.builtins.diagnostics.fish,
        null_ls.builtins.diagnostics.rubocop,
        null_ls.builtins.diagnostics.yamllint,

        -- Code Actions
        null_ls.builtins.code_actions.gitsigns,
        null_ls.builtins.code_actions.impl,

        -- completion
        null_ls.builtins.completion.vsnip,
        null_ls.builtins.completion.luasnip,
        null_ls.builtins.completion.tags,
        null_ls.builtins.completion.spell,
      },
    })
  end,
}
