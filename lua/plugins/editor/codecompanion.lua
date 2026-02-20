return {
    "olimorris/codecompanion.nvim",
    version = "^18.0.0",
    opts = {},
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "ravitemer/mcphub.nvim",
        {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({})
            end,
        }
    },
    config = function(opts)
        require("codecompanion").setup({
            opts = {
                enabled = true,
                language = "English",
            },
            display = {
                chat = {
                    window = {
                        layout = "vertical", -- "vertical"|"horizontal"|"float"|"buffer"
                        border = "single", -- Border style
                        width = 0.3, -- Width as percentage (0.0-1.0) or absolute columns
                        height = 1, -- Height as percentage (0.0-1.0) or absolute rows
                        relative = "cursor", -- "editor"|"win"|"cursor"
                        opts = {
                            breakindent = true,
                            cursorcolumn = false,
                            cursorline = false,
                            foldcolumn = "0",
                            linebreak = true,
                            list = false,
                            signcolumn = "no",
                            spell = true,
                            wrap = true,
                        },
                    },
                },
            },
            interactions = {
                chat = {
                    adapter = "gemini_cli",
                    enabled = true,
                },
                inline = {
                    adapter = "copilot",
                    enabled = true,
                },
            },
            extensions = {
                mcphub = {
                    callback = "mcphub.extensions.codecompanion",
                    opts = {
                        make_vars = true,
                        make_slash_commands = true,
                        show_result_in_chat = true
                    }
                }
            }

        })
    end
}
