-- TODO comments
GogoVIM.AddPack({
  src = GogoVIM.GH("folke/todo-comments.nvim"),
  name = "todo-comments",
  data = {
    config = function()
      require("todo-comments").setup({
        signs = true,
        keywords = {
          TODO = { icon = " ", color = "info" },
          DONE = { icon = " ", color = "warning" },
          HACK = { icon = " ", color = "warning" },
          WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
          PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
          NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        },
        highlight = {
          before = "",
          keyword = "fg",
          comments_only = true,
        },
        colors = {
          error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
          warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
          info = { "DiagnosticInfo", "#2563EB" },
          hint = { "DiagnosticHint", "#10B981" },
          default = { "Identifier", "#7C3AED" },
        },
      })
      GogoVIM.load_mapping("todo")
    end,
  },
})

-- treesitter TODO: check for updated version
GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-treesitter/nvim-treesitter-locals"),
  name = "nvim-treesitter-locals",
  version = "main",
  data = {
    config = function() end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-treesitter/nvim-treesitter"),
  name = "nvim-treesitter",
  version = "main",
  data = {
    config = function()
      local opts = {
        highlight = {
          -- Enabling highlight for all files
          enable = true,
          disable = function(lang)
            if lang == "avanteinput" then
              return true
            end
          end,
          additional_vim_regex_highlighting = true,
        },
        indent = { enable = true },
        ensure_installed = {
          -- "bash",
          -- "c",
          "diff",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "json5",
          "lua",
          "luadoc",
          -- "luap",
          "markdown",
          "markdown_inline",
          "python",
          -- "query",
          "regex",
          "toml",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "xml",
          "yaml",
          "go",
          "gomod",
          "gowork",
          "gosum",
          "gotmpl",
          "git_config",
          "gitcommit",
          "git_rebase",
          "gitignore",
          "sql",
          -- "astro",
          "svelte",
          "ruby",
          -- "nu",
          "fish",
          "comment",
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          move = {
            enable = true,
            goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },
        },

        -- Install all parsers synchronously
        sync_install = true,
        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        -- List of parsers to ignore installing (or "all")
        ignore_install = { "C", "avanteinput" },

        refactor = {
          -- highlight_current_scope = { enable = true },
          highlight_definitions = {
            enable = true,
            -- Set to false if you have an `updatetime` of ~100.
            clear_on_cursor_move = false,
          },
          smart_rename = {
            enable = false,
            -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
            keymaps = {
              smart_rename = "grr",
            },
          },
        },
        tree_docs = {
          enable = true,
          spec_config = {
            jsdoc = {
              slots = {
                class = { author = true },
              },
              processors = {
                author = function()
                  return " * @author George Messiha"
                end,
              },
            },
          },
        },
        texobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              -- You can also use captures from other query groups like `locals.scm`
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ["@parameter.outer"] = "v", -- charwise
              ["@function.outer"] = "V", -- linewise
              ["@class.outer"] = "<c-v>", -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true or false
            include_surrounding_whitespace = true,
          },
        },
        modules = {
          "nvim-treesitter/nvim-treesitter-refactor",
          "nvim-treesitter/nvim-tree-docs",
          "nvim-treesitter/nvim-treesitter-textobjects",
        },
      }

      if type(opts.ensure_installed) == "table" then
        ---@type table<string, boolean>
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter").install(opts.ensure_installed)
      require("nvim-treesitter.config").setup(opts)
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-treesitter/nvim-treesitter-textobjects"),
  name = "nvim-treesitter-textobjects",
  version = "main",
  data = {
    config = function()
      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require("nvim-treesitter-textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.config")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-treesitter/nvim-treesitter-context"),
  name = "nvim-treesitter-context",
  data = {
    config = function()
      vim.keymap.set("v", "<leader>ut", function()
        local tsc = require("treesitter-context")
        tsc.toggle()
        if tsc.enabled() then
          vim.notify("Enabled Treesitter Context", vim.log.levels.INFO, { title = "TreeSitter" })
        else
          vim.notify("Disabled Treesitter Context", vim.log.levels.WARN, { title = "TreeSitter" })
        end
      end, { desc = "Toggle Treesitter context" })

      require("treesitter-context").setup({
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        max_lines = 5, -- How many lines the window should span. Values <= 0 mean no limit.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 3, -- Maximum number of lines to show for a single context
        trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
      })
    end,
  },
})

-- Conform
GogoVIM.AddPack({
  src = GogoVIM.GH("stevearc/conform.nvim"),
  name = "conform.nvim",
  data = {
    name = "conform",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          python = { "ruff_fix", "ruff_organize_imports" },
          -- yaml = { "yamlfix" },
          fish = { "fish_indent" },
          -- bash = { "bash" },
          sql = { "sqruff" },
          go = { "goimports" },
          tf = { "tfmt" },
          terraform = { "tfmt" },
          hcl = { "tfmt" },
          kdl = { "kdlfmt" },
        },
        formatters = {
          tfmt = {
            command = "tofu",
            args = { "fmt", "-" },
            stdin = true,
          },
        },
        default_format_opts = {
          lsp_format = "fallback",
        },
        notify_on_error = true,
      })

      GogoVIM.load_mapping("conform")
    end,
  },
})

-- Blink.cmp
GogoVIM.AddPack({
  src = GogoVIM.GH("saghen/blink.compat"),
  name = "blink.compat",
  data = {
    config = function()
      require("cmp").ConfirmBehavior = {
        Insert = "insert",
        Replace = "replace",
      }
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("Kaiser-Yang/blink-cmp-avante"),
  name = "blink-cmp-avante",
  data = {
    skip_load = true,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("saghen/blink.cmp"),
  version = vim.version.range("v1.x"),
  name = "blink.cmp",
  data = {
    name = "blink.cmp",
    opts = {
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },

        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },

      snippets = {
        expand = function(snippet)
          -- vim.snippet.expand(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        -- Function to use when checking if a snippet is active
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
          -- return vim.snippet.active(filter)
        end,
        jump = function(direction)
          -- vim.snippet.jump(direction)
          require("luasnip").jump(direction)
        end,
      },

      completion = {
        keyword = {
          range = "prefix",
        },

        trigger = {
          -- When false, will not show the completion window automatically when in a snippet
          show_in_snippet = true,
          -- When true, will show the completion window after typing a character that matches the `keyword.regex`
          show_on_keyword = true,
          -- When true, will show the completion window after typing a trigger character
          show_on_trigger_character = true,
          -- LSPs can indicate when to show the completion window via trigger characters
          -- however, some LSPs (i.e. tsserver) return characters that would essentially
          -- always show the window. We block these by default.
          show_on_blocked_trigger_characters = { " ", "\n", "\t" },
          -- When both this and show_on_trigger_character are true, will show the completion window
          -- when the cursor comes after a trigger character after accepting an item
          show_on_accept_on_trigger_character = true,
          -- When both this and show_on_trigger_character are true, will show the completion window
          -- when the cursor comes after a trigger character when entering insert mode
          show_on_insert_on_trigger_character = true,
          -- List of trigger characters (on top of `show_on_blocked_trigger_characters`) that won't trigger
          -- the completion window when the cursor comes after a trigger character when
          -- entering insert mode/accepting an item
          show_on_x_blocked_trigger_characters = { "'", '"', "(" },
        },

        -- @type blink.cmp.CompletionListConfig
        list = {
          max_items = 200,
          selection = {
            preselect = false,
            auto_insert = true,
          },
          cycle = {
            from_bottom = true,
            from_top = true,
          },
        },

        accept = {
          -- Create an undo point when accepting a completion item
          create_undo_point = true,
          -- Experimental auto-brackets support
          auto_brackets = {
            -- Whether to auto-insert brackets for functions
            enabled = true,
            -- Default brackets to use for unknown languages
            default_brackets = { "(", ")" },
            -- Overrides the default blocked filetypes
            override_brackets_for_filetypes = {},
            -- Synchronously use the kind of the item to determine if brackets should be added
            kind_resolution = {
              enabled = true,
              blocked_filetypes = { "typescriptreact", "javascriptreact", "vue" },
            },
            -- Asynchronously use semantic token to determine if brackets should be added
            semantic_token_resolution = {
              enabled = true,
              blocked_filetypes = {},
              -- How long to wait for semantic tokens to return before assuming no brackets should be added
              timeout_ms = 400,
            },
          },
        },

        menu = {
          enabled = true,
          min_width = 15,
          max_height = 25,
          border = "none",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
          -- Keep the cursor X lines away from the top/bottom of the window
          scrolloff = 2,
          -- Note that the gutter will be disabled when border ~= 'none'
          scrollbar = true,
          -- Which directions to show the window,
          -- falling back to the next direction when there's not enough space
          direction_priority = { "s", "n" },

          -- Whether to automatically show the window when new completion items are available
          auto_show = true,

          -- Controls how the completion items are rendered on the popup window
          draw = {
            -- Left and right padding, optionally { left, right } for different padding on each side
            padding = 1,
            -- Gap between columns
            gap = 1,
            -- Use treesitter to highlight the label text
            treesitter = {},

            -- Components to render, grouped by column
            columns = { { "kind_icon" }, { "label", "label_description" }, { "source_name" } },

            -- Definitions for possible components to render. Each component defines:
            --   ellipsis: whether to add an ellipsis when truncating the text
            --   width: control the min, max and fill behavior of the component
            --   text function: will be called for each item
            --   highlight function: will be called only when the line appears on screen
            components = {
              kind_icon = {
                ellipsis = false,
                text = function(ctx)
                  return ctx.kind_icon .. ctx.icon_gap
                end,
                highlight = function(ctx)
                  return "BlinkCmpKind" .. ctx.kind
                end,
              },

              kind = {
                ellipsis = false,
                width = { fill = true },
                text = function(ctx)
                  return ctx.kind
                end,
                highlight = function(ctx)
                  return "BlinkCmpKind" .. ctx.kind
                end,
              },

              label = {
                width = { fill = true, max = 60 },
                text = function(ctx)
                  return ctx.label .. ctx.label_detail
                end,
                highlight = function(ctx)
                  -- label and label details
                  local highlights = {
                    { 0, #ctx.label, group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel" },
                  }
                  if ctx.label_detail then
                    table.insert(
                      highlights,
                      { #ctx.label, #ctx.label + #ctx.label_detail, group = "BlinkCmpLabelDetail" }
                    )
                  end

                  -- characters matched on the label by the fuzzy matcher
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end

                  return highlights
                end,
              },

              label_description = {
                width = { max = 30 },
                text = function(ctx)
                  return ctx.label_description
                end,
                highlight = "BlinkCmpLabelDescription",
              },

              source_name = {
                width = { max = 30 },
                text = function(ctx)
                  return ctx.source_name
                end,
                highlight = "BlinkCmpSource",
              },
            },
          },
        },

        documentation = {
          -- Controls whether the documentation window will automatically show when selecting a completion item
          auto_show = false,
          -- Delay before showing the documentation window
          auto_show_delay_ms = 500,
          -- Delay before updating the documentation window when selecting a new item,
          -- while an existing item is still visible
          update_delay_ms = 50,
          -- Whether to use treesitter highlighting, disable if you run into performance issues
          treesitter_highlighting = true,
          window = {
            min_width = 10,
            max_width = 60,
            max_height = 20,
            border = "padded",
            winblend = 0,
            winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
            -- Note that the gutter will be disabled when border ~= 'none'
            scrollbar = true,
            -- Which directions to show the documentation window,
            -- for each of the possible menu window directions,
            -- falling back to the next direction when there's not enough space
            direction_priority = {
              menu_north = { "e", "w", "n", "s" },
              menu_south = { "e", "w", "s", "n" },
            },
          },
        },

        -- Displays a preview of the selected item on the current line
        ghost_text = {
          enabled = true,
          show_with_menu = false,
        },
      },

      -- Experimental signature help support
      signature = {
        enabled = true,
        trigger = {
          blocked_trigger_characters = {},
          blocked_retrigger_characters = {},
          -- When true, will show the signature help window when the cursor comes after a trigger character when entering insert mode
          show_on_insert_on_trigger_character = true,
        },
        window = {
          min_width = 1,
          max_width = 100,
          max_height = 10,
          border = "padded",
          winblend = 0,
          winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
          scrollbar = true, -- Note that the gutter will be disabled when border ~= 'none'
          -- Which directions to show the window,
          -- falling back to the next direction when there's not enough space,
          -- or another window is in the way
          direction_priority = { "n", "s" },
          -- Disable if you run into performance issues
          treesitter_highlighting = true,
        },
      },

      fuzzy = {
        -- proximity bonus boosts the score of items matching nearby words
        use_proximity = true,
        -- controls which sorts to use and in which order, these three are currently the only allowed options
        sorts = { "score", "exact", "sort_text", "kind", "label" },

        prebuilt_binaries = {
          -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
          -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
          download = true,
        },
      },

      sources = {
        default = function()
          local _defaults = { "lsp", "avante", "path", "omni", "snippets", "cmdline" }

          --- @type boolean, TSNode|nil
          local isTreeSitter, node = pcall(vim.treesitter.get_node)
          if not isTreeSitter then
            return _defaults
          end

          if vim.bo.filetype == "lua" then
            return { "lsp", "omni", "path", "snippets" }
          elseif vim.bo.filetype == "codecompanion" then
            return { "codecompanion" }
          elseif node and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type()) then
            return { "avante", "buffer", "path" }
          else
            return _defaults
          end
        end,

        -- Please see https://github.com/Saghen/blink.compat for using `nvim-cmp` sources
        providers = {
          lsp = {
            name = "LSP",
            module = "blink.cmp.sources.lsp",
            fallbacks = { "buffer" },
            --- *All* of the providers have the following options available
            --- NOTE: All of these options may be functions to get dynamic behavior
            --- See the type definitions for more information.
            --- Check the enabled_providers config for an example
            enabled = true, -- Whether or not to enable the provider
            transform_items = nil, -- Function to transform the items before they're returned
            should_show_items = true, -- Whether or not to show the items
            max_items = 25, -- Maximum number of items to display in the menu
            min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
            score_offset = 0, -- Boost/penalize the score of the items
            override = nil, -- Override the source's functions
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 3,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = false,
            },
          },
          snippets = {
            name = "Snippets",
            module = "blink.cmp.sources.snippets",
            score_offset = -3,
            opts = {
              friendly_snippets = true,
              search_paths = { vim.fn.stdpath("config") .. "/snippets" },
              global_snippets = { "all" },
              extended_filetypes = {},
              ignored_filetypes = {},
              get_filetype = function(context)
                return vim.bo.filetype
              end,
            },
          },
          buffer = {
            name = "Buffer",
            module = "blink.cmp.sources.buffer",
            opts = {
              -- default to all visible buffers
              get_bufnrs = function()
                return vim
                  .iter(vim.api.nvim_list_wins())
                  :map(function(win)
                    return vim.api.nvim_win_get_buf(win)
                  end)
                  :filter(function(buf)
                    return vim.bo[buf].buftype ~= "nofile"
                  end)
                  :totable()
              end,
            },
          },
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            opts = {
              -- options for blink-cmp-avante
            },
          },
        },
        -- codecompanion = {
        --     name="codecompanion",
        --     module="codecompanion",
        -- },
      },

      appearance = {
        highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = false,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",
        kind_icons = {
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",

          Field = "󰜢",
          Variable = "󰆦",
          Property = "󰖷",

          Class = "󱡠",
          Interface = "󱡠",
          Struct = "󱡠",
          Module = "󰅩",

          Unit = "󰪚",
          Value = "󰦨",
          Enum = "󰦨",
          EnumMember = "󰦨",

          Keyword = "󰻾",
          Constant = "󰏿",

          Snippet = "󱄽",
          Color = "󰏘",
          File = "󰈔",
          Reference = "󰬲",
          Folder = "󰉋",
          Event = "󱐋",
          Operator = "󰪚",
          TypeParameter = "󰬛",
        },
      },
    },
  },
})

-- GitSigns
GogoVIM.AddPack({
  src = GogoVIM.GH("lewis6991/gitsigns.nvim"),
  name = "gitsigns.nvim",
  data = {
    name = "gitsigns",
    config = function()
      local gitIcons = GogoVIM.UI.icons.git
      require("gitsigns").setup({
        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

                    -- stylua: ignore start
                    -- map("n", "]h", gs.next_hunk, "Next Hunk")
                    -- map("n", "[h", gs.prev_hunk, "Prev Hunk")
                    map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
                    map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
                    map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
                    map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
                    map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
                    map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
                    map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
                    map("n", "<leader>ghd", gs.diffthis, "Diff This")
                    map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        end,
        signs = {
          add = { text = gitIcons.LineAdded },
          change = { text = gitIcons.LineModified },
          delete = { text = gitIcons.LineRemoved },
          topdelete = { text = gitIcons.LineRemoved },
          changedelete = { text = gitIcons.LineChangeDelete },
          untracked = { text = gitIcons.FileUnstaged },
        },
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align",
          delay = 1000,
          ignore_whitespace = false,
        },
      })
    end,
  },
})
