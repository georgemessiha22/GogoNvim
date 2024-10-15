return {
  { "folke/lazy.nvim", version = "*" },
  { "nvim-lua/plenary.nvim" },
  -- colors{{{
  require("plugins.colors.colorscheme"),
  -- require("plugins.colors.colorizer"),
  -- require("plugins.colors.illuminate"),
  -- }}}

  -- Code {{{
  require("plugins.code.luasnip"),
  -- require("plugins.code.autopairs"),
  require("plugins.code.cmp"),
  -- require("plugins.code.blink"),
  -- require("plugins.code.comment"),
  require("plugins.code.iconpicker"),
  require("plugins.code.todo-comment"),
  -- require("plugins.code.indentscope"),
  -- }}}

  -- LSP {{{
  require("plugins.lsp"),
  -- }}}

  -- Git {{{
  require("plugins.git.gitsigns"),
  require("plugins.git.lazygit"),
  -- }}}

  -- Editor View {{{
  require("plugins.editor.mininvim"),
  -- require("plugins.editor.startuptime"),
  -- require("plugins.editor.persistence"),
  require("plugins.editor.flash"),
  require("plugins.editor.fzf"),
  require("plugins.editor.trouble"),
  require("plugins.editor.harpoon2"),
  require("plugins.editor.telescope"),
  require("plugins.editor.spectre"),
  -- require("plugins.editor.neotree"),
  -- require("plugins.editor.lualine"),
  -- require("plugins.editor.bufferline"),
  -- require("plugins.editor.blankline"),
  require("plugins.editor.dressing"),
  require("plugins.editor.noice"),
  require("plugins.editor.notify"),
  require("plugins.editor.codeshot"),
  { "MunifTanjim/nui.nvim", lazy = true },
  require("plugins.editor.whichkey"),
  require("plugins.editor.dashboard"),
  -- }}}
}
