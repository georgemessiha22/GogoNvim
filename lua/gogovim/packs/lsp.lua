GogoVIM.AddPack({
  src = GogoVIM.GH("rafamadriz/friendly-snippets"),
  name = "friendly-snippets",
  data = { skip_load = true },
})
GogoVIM.AddPack({
  src = GogoVIM.GH("L3MON4D3/LuaSnip"),
  name = "LuaSnip",
  version = vim.version.range("v2.x"),
  data = {
    name = "luasnip",
    build = { "make", "install_jsregexp" },
  },
})

-- Mason
GogoVIM.AddPack({
  src = GogoVIM.GH("williamboman/mason.nvim"),
  name = "mason.nvim",
  data = {
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = GogoVIM.UI.icons.misc.Package,
            package_pending = GogoVIM.UI.icons.kinds.Property,
            package_uninstalled = GogoVIM.UI.icons.ui.BoldClose,
          },
        },
      })
    end,
  },
})

-- LSPConfig
GogoVIM.AddPack({
  src = GogoVIM.GH("williamboman/mason-lspconfig.nvim"),
  name = "mason-lspconfig",
  data = {
    opts = {
      automatic_enable = false,
      ensure_installed = {
        "bashls", -- LSP for bash shell
        "ts_ls", -- LSP for Typescript and Javascript
        "emmet_ls", -- LSP for Emmet (Vue, HTML, CSS)
        "cssls", -- LSP for CSS
        "ruff", -- LSP for Python
        "svelte", -- LSP for Svelte
        "tailwindcss", -- LSP for TailWindCss
        "marksman", -- LSP for Markdown
        "dockerls", -- LSP for Dockerfile
        "docker_compose_language_service", -- LSP for Docker-compose
        -- "denols", -- LSP for deno
        "sqlls", -- LSP SQL
        "yamlls", -- LSP yaml
        "rust_analyzer", -- LSP Rust rust_analyzer
        "jsonls", -- LSP json
        "html", -- LSP html
        "eslint", -- LSP eslint
        "texlab", -- LSP Latex
        "taplo", -- LSP TOML
        "pbls", -- LSP PROTO
        "pyright", -- LSP Python
        "rust_analyzer", -- LSP Rust
        "gopls", -- LSP Go
        "stylua", -- LSP lua formatter
        "lua_ls",
        "kdlfmt",
      },
    },
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("neovim/nvim-lspconfig"),
  name = "nvim-lspconfig",
  data = {
    config = function() end,
  },
})
--
-- GogoVIM.AddPack({
--     src = GogoVIM.GH("folke/lazydev.nvim"),
--     name = "lazydev.nvim",
--     data = {
--         config = function()
--             require("lazydev").setup()
--         end
--     }
-- })

-- Go by RayX
GogoVIM.AddPack({
  src = GogoVIM.GH("ray-x/guihua.lua"),
  name = "guihua",
  version = "master",
  data = {
    skip_load = true,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("ray-x/go.nvim"),
  name = "go.nvim",
  version = "master",
  -- version = vim.version.range("v0.x"),
  data = {
    name = "go",
    opts = {
      gotests_template_dir = vim.fn.stdpath("config") .. "/templates/gotest/testify",
      luasnip = true,
      trouble = true,
      gofmt = "golines",
      goimports = "gopls",
      fillstruct = "gopls",
      max_line_len = 80,
      -- lsp_on_attach = on_attach,
      build_tags = "functional,integration,unit,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6,functional_http,functional_grpc",
      lsp_cfg = false,
      lsp_inlay_hints = {
        enable = true,

        -- Only show inlay hints for the current line
        only_current_line = true,

        -- Event which triggers a refresh of the inlay hints.
        -- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
        -- not that this may cause higher CPU usage.
        -- This option is only respected when only_current_line and
        -- autoSetHints both are true.
        only_current_line_autocmd = "CursorHold",

        -- whether to show variable name before type hints with the inlay hints or not
        -- default: false
        show_variable_name = true,

        -- prefix for parameter hints
        parameter_hints_prefix = "󰊕 ",
        show_parameter_hints = true,

        -- prefix for all the other hints (type, chaining)
        other_hints_prefix = "=> ",

        -- whether to align to the length of the longest line in the file
        max_len_align = false,

        -- padding from the left if max_len_align is true
        max_len_align_padding = 1,

        -- whether to align to the extreme right or not
        right_align = true,

        -- padding from the right if right_align is true
        right_align_padding = 6,

        -- The color of the hints
        highlight = "Comment",
      },
      lsp_gofumpt = true,
      dap_debug_keymap = false,
    },
  },
})
