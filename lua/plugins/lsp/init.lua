return {
  require("plugins.lsp.mason-tool-installer"),
  require("plugins.lsp.treesitter"),
  require("plugins.lsp.mason"),
  require("plugins.lsp.lsp_kind"),
  require("plugins.lsp.nvim-lint"),
  require("plugins.lsp.none-ls"),
  require("plugins.lsp.conform"),

  require("plugins.lsp.lspconfig"),

  -- Lang Spec {{{
  -- require("plugins.lsp.lang.rustacean"),
  require("plugins.lsp.lang.go"),
  -- }}}
}
