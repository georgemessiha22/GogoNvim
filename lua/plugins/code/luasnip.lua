return {
  "L3MON4D3/LuaSnip",
  -- follow latest release.
  version = "v2.*",
  dependencies = {
    {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
  },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  -- install jsregexp (optional!).
  build = "make install_jsregexp",
}
