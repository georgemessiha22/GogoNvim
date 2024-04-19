return {

  "WhoIsSethDaniel/mason-tool-installer.nvim",
  config = function(_, opts)
    -- auto installer {{{
    opts = vim.tbl_deep_extend("force", opts, {
      ensure_installed = {
        "lua-language-server", -- LSP Lua
        "luacheck",
        "misspell",
        "revive",
        "latexindent",
        "ts-standard",
        "bash-debug-adapter",
        "go-debug-adapter",
        "js-debug-adapter",
        "node-debug2-adapter",
        "svelte-langauage-server",

        -- Formatters
        "stylua",
        "autopep8",
        "gofumpt",
        "golangci-lint",
        "goimports",
        "ruff",
        "sqlfmt",
        "yamllint",
        "jsonlint",
        "shellharden",
        "shfmt",
        "beautysh",
        -- "rustywind", -- TailWindCss
        "shfmt",
        "shellcheck",
        "markdownlint",
        "deno-fmt",
      },
      auto_update = true,
      run_on_start = true,
      start_delay = 3000,
      debounce_hours = 24,
    })
    require("mason-tool-installer").setup(opts)
    -- }}}
  end,
}
