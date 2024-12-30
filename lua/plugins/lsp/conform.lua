return {
  "stevearc/conform.nvim",
  config = function(opts)
    require("conform").setup({

      formatters_by_ft = {
        yaml = { "yamlfix" },
        fish = { "fish_indent" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      notify_on_error = true,
    })
  end
}
