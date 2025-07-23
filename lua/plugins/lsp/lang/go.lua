--[[
-- File: go.lua
-- Description: Go lang helper better than just LSP.
-- See: https://github.com/ray-x/go.nvim
--]]

return {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
        -- "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        require("go").setup({
            gotests_template_dir= vim.fn.stdpath('config') .. "/templates/gotest/testify",
            luasnip = true,
            trouble = true,
            gofmt = "golines",
            goimports = "gopls",
            fillstruct = "gopls",
            max_line_len = 80,
            -- lsp_on_attach = on_attach,
            build_tags = "functional,integration,unit,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6",
            lsp_cfg = false,
            -- lsp_cfg = {
            --     -- capabilites = capabilites,
            --     -- on_attach = on_attach,
            --     filetypes = { "go", "gomod", "gowork", "gotmpl" },
            --     settings = {
            --         gopls = {
            --             analyses = {
            --                 unusedparams = true,
            --                 unusedwrite = true,
            --                 shadow = true,
            --                 unusedvariable = true,
            --                 useany = true,
            --                 ST1019 = true,
            --                 ST1020 = true,
            --                 ST1021 = true,
            --                 ST1022 = true,
            --                 ST1023 = true,
            --             },
            --             staticcheck = true,
            --             gofumpt = true,
            --             buildFlags = { "-tags=functional,integration,unit,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6" },
            --             -- vulncheck = { "Imports" },
            --             hints = {
            --                 assignVariableTypes = true,
            --                 compositeLiteralFields = true,
            --                 compositeLiteralTypes = true,
            --                 constantValues = true,
            --                 functionTypeParameters = true,
            --                 parameterNames = true,
            --                 rangeVariableTypes = true,
            --             },
            --         },
            --         codelenses = {
            --             gc_details = true,
            --             generate = true,
            --             regenerate_cgo = true,
            --             run_govulncheck = true,
            --             tidy = true,
            --             upgrade_dependency = true,
            --             vendor = true,
            --         },
            --     },
            -- },
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
            -- golangci_lint = {
            --     cmd = { 'golangci-lint-langserver' },
            --     filetypes = { 'go', 'gomod' },
            --     root_markers = {
            --         '.golangci.yml',
            --         '.golangci.yaml',
            --         '.golangci.toml',
            --         '.golangci.json',
            --     },
            --
            --     capabilites = capabilites,
            --     on_attach = on_attach,
            --     init_options = {
            --         command = {
            --             "golangci-lint",
            --             "run",
            --             "--output.text.path", "/dev/null",
            --             "--output.json.path", "stdout",
            --             "--show-stats=false",
            --             "--issues-exit-code", "1",
            --             "--build-tags",
            --             "unit,integration,functional,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6",
            --             "--timeout", "5s"
            --         },
            --     },
            -- },
        })

        -- local null_ls = require("null-ls")
        --
        -- null_ls.register(require("go.null_ls").gotest())
        -- null_ls.register(require("go.null_ls").gotest_action())
        -- null_ls.register(require("go.null_ls").golangci_lint())
    end,
    event = { "CmdlineEnter" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
