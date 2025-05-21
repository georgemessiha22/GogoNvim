return {
    "saghen/blink.cmp",
    dependencies = {
        {
            "saghen/blink.compat",
            lazy = true,
            opts = {},
            config = function()
                -- monkeypatch cmp.ConfirmBehavior for Avante
                require("cmp").ConfirmBehavior = {
                    Insert = "insert",
                    Replace = "replace",
                }
            end,
        },
    },
    lazy = false, -- lazy loading handled internally

    -- use a release tag to download pre-built binaries
    version = "v0.*",
    -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- On musl libc based systems you need to add this flag
    -- build = 'RUSTFLAGS="-C target-feature=-crt-static" cargo build --release',

    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
        keymap = {
            ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            ['<C-e>'] = { 'hide' },
            ['<C-y>'] = { 'select_and_accept' },

            ['<C-p>'] = { 'select_prev', 'fallback' },
            ['<C-n>'] = { 'select_next', 'fallback' },

            ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

            ['<Tab>'] = { 'snippet_forward', 'fallback' },
            ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        },

        snippets = {
            expand = function(snippet)
                -- vim.snippet.expand(snippet)
                require('luasnip').lsp_expand(snippet)
            end,
            -- Function to use when checking if a snippet is active
            active = function(filter)
                if filter and filter.direction then
                    return require('luasnip').jumpable(filter.direction)
                end
                return require('luasnip').in_snippet()
                -- return vim.snippet.active(filter)
            end,
            jump = function(direction)
                -- vim.snippet.jump(direction)
                require('luasnip').jump(direction)
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

            --- @type blink.cmp.CompletionListConfig
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
                winhighlight =
                "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
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
                    columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
                    -- for a setup similar to nvim-cmp: https://github.com/Saghen/blink.cmp/pull/245#issuecomment-2463659508
                    -- columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },

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
                    winhighlight =
                    "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
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
            -- frencency tracks the most recently/frequently used items and boosts the score of the item
            use_frecency = true,
            -- proximity bonus boosts the score of items matching nearby words
            use_proximity = true,
            -- controls which sorts to use and in which order, these three are currently the only allowed options
            sorts = {"score", "exact", "sort_text", "kind", "label",},

            prebuilt_binaries = {
                -- Whether or not to automatically download a prebuilt binary from github. If this is set to `false`
                -- you will need to manually build the fuzzy binary dependencies by running `cargo build --release`
                download = true,
                -- When downloading a prebuilt binary, force the downloader to resolve this version. If this is unset
                -- then the downloader will attempt to infer the version from the checked out git tag (if any).
                --
                -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
                force_version = nil,
                -- When downloading a prebuilt binary, force the downloader to use this system triple. If this is unset
                -- then the downloader will attempt to infer the system triple from `jit.os` and `jit.arch`.
                -- Check the latest release for all available system triples
                --
                -- Beware that if the FFI ABI changes while tracking main then this may result in blink breaking.
                force_system_triple = nil,
            },
        },

        sources = {
            default = function()
                local _defaults = { 'lsp', 'path', 'snippets', "avante_commands", "avante_mentions", "avante_files", }

                --- @type boolean, TSNode|nil
                local isTreeSitter, node = pcall(vim.treesitter.get_node)
                if not isTreeSitter then
                    return _defaults
                end

                if vim.bo.filetype == 'lua' then
                    return { 'lsp', 'path', 'lazydev', "snippets", }
                elseif node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                    return { 'buffer', "path", "avante_commands", "avante_mentions", "avante_files", }
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
                    enabled = true,           -- Whether or not to enable the provider
                    transform_items = nil,    -- Function to transform the items before they're returned
                    should_show_items = true, -- Whether or not to show the items
                    max_items = 25,           -- Maximum number of items to display in the menu
                    min_keyword_length = 0,   -- Minimum number of characters in the keyword to trigger the provider
                    score_offset = 0,         -- Boost/penalize the score of the items
                    override = nil,           -- Override the source's functions
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
                lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                avante_commands = {
                    name = "avante_commands",
                    module = "blink.compat.source",
                    score_offset = 90, -- show at a higher priority than lsp
                    opts = {},
                },
                avante_files = {
                    name = "avante_commands",
                    module = "blink.compat.source",
                    score_offset = 100, -- show at a higher priority than lsp
                    opts = {},
                },
                avante_mentions = {
                    name = "avante_mentions",
                    module = "blink.compat.source",
                    score_offset = 1000, -- show at a higher priority than lsp
                    opts = {},
                },
            },
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
}
