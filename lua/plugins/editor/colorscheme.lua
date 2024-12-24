-- Theme
return {
  -- Theme: catppuccin {{{
  -- {
  --   "catppuccin/nvim",
  --   lazy = false,
  --   name = "catppuccin",
  --   opts = {
  --     flavour = "frappe",
  --     integrations = {
  --       aerial = true,
  --       alpha = true,
  --       cmp = true,
  --       dashboard = true,
  --       flash = true,
  --       gitsigns = true,
  --       headlines = true,
  --       illuminate = true,
  --       indent_blankline = { enabled = true },
  --       leap = true,
  --       lsp_trouble = true,
  --       mason = true,
  --       markdown = true,
  --       mini = true,
  --       native_lsp = {
  --         enabled = true,
  --         underlines = {
  --           errors = { "undercurl" },
  --           hints = { "undercurl" },
  --           warnings = { "undercurl" },
  --           information = { "undercurl" },
  --         },
  --       },
  --       navic = { enabled = true, custom_bg = "lualine" },
  --       neotest = true,
  --       neotree = true,
  --       noice = true,
  --       notify = true,
  --       semantic_tokens = true,
  --       telescope = true,
  --       treesitter = true,
  --       treesitter_context = true,
  --       which_key = true,
  --     },
  --   },
  -- },
  -- }}}

  -- Theme: Tokyonight {{{
  -- {
  --   "folke/tokyonight.nvim",
  --   lazy = false,
  --   opts = { style = "moon" },
  --   config = function(_)
  --     vim.g.tokyodark_enable_italic_comment = true
  --     vim.g.tokyodark_enable_italic = true
  --   end,
  -- },
  -- }}}

  -- Theme Rose-pine {{{
  -- {
  --   "rose-pine/neovim",
  --   lazy = false
  -- },
  -- }}}
  -- Theme Flow {{{
  {
    "0xstepit/flow.nvim",
    lazy = false,
    priority = 1000,
    tag = "v2.0.0",
    opts = {
      theme = {
        style = "dark",       --  "dark" | "light"
        contrast = "default", -- "default" | "high"
        transparent = false,  -- true | false
      },
      colors = {
        mode = "default", -- "default" | "dark" | "light"
        fluo = "cyan",    -- "pink" | "cyan" | "yellow" | "orange" | "green"
      },
      ui = {
        borders = "theme",        -- "theme" | "inverse" | "fluo" | "none"
        aggressive_spell = true, -- true | false
      },
    },
    config = function(_, opts)
      require("flow").setup(opts)
    end,
  },
  -- }}}
}
