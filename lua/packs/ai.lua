-- Markdown-render
GogoVIM.AddPack({
    src = GogoVIM.GH("MeanderingProgrammer/render-markdown.nvim"),
    data = {
        config = function()
            require("render-markdown").setup({
                file_types = { "markdown", "Avante", "codecompanion" },
                completions = { lsp = { enabled = true } },
            })
        end
    },
})

-- MCPHub
GogoVIM.AddPack({
    src = GogoVIM.GH("nvim-lua/plenary.nvim"),
    name = "plenary.nvim",
    data = {
        name = "plenary",
        skip_load = true,
    }
})

GogoVIM.AddPack({
    src = GogoVIM.GH("ravitemer/mcphub.nvim"),
    name = "mcphub.nvim",
    data = {
        name = "mcphub",
        build = { "npm", "install", "-g", "mcp-hub@latest" },
        config = function()
            require("mcphub").setup({
                --- `mcp-hub` binary related options-------------------
                config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
                port = 37373,                                            -- The port `mcp-hub` server listens to
                shutdown_delay = 60 * 10 * 000,                          -- Delay in ms before shutting down the server when last instance closes (default: 10 minutes)
                use_bundled_binary = false,                              -- Use local `mcp-hub` binary (set this to true when using build = "bundled_build.lua")

                ---Chat-plugin related options-----------------
                auto_approve = false,           -- Auto approve mcp tool calls
                auto_toggle_mcp_servers = true, -- Let LLMs start and stop MCP servers automatically
                extensions = {
                    avante = {
                        make_slash_commands = true, -- make /slash commands from MCP server prompts
                    }
                },

                --- Plugin specific options-------------------
                native_servers = {}, -- add your custom lua native servers here
                ui = {
                    window = {
                        width = 0.8,  -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
                        height = 0.8, -- 0-1 (ratio); "50%" (percentage); 50 (raw number)
                        relative = "editor",
                        zindex = 50,
                        border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
                    },
                    wo = {                  -- window-scoped options (vim.wo)
                        winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
                    },
                },
                -- on_ready = function(hub)
                --     -- Called when hub is ready
                -- end,
                -- on_error = function(err)
                --     -- Called on errors
                -- end,
                log = {
                    level = vim.log.levels.WARN,
                    to_file = false,
                    file_path = nil,
                    prefix = "MCPHub",
                },
            })
        end
    },
})

-- Copilot
GogoVIM.AddPack({
    src = GogoVIM.GH("zbirenbaum/copilot.lua"),
    name = "copilot.lua",
    data = {
        config = function()
            require("copilot").setup({})
        end
    },
})

-- Codecompanion
GogoVIM.AddPack({
    src = GogoVIM.GH("olimorris/codecompanion.nvim"),
    name = "codecompanion.nvim",
    version = vim.version.range("v19.x"),
    data = {
        name = "codecompanion",
        config = function()
            require("codecompanion").setup({
                opts = {
                    enabled = true,
                    language = "English",
                },
                display = {
                    chat = {
                        window = {
                            layout = "vertical", -- "vertical"|"horizontal"|"float"|"buffer"
                            border = "single",   -- Border style
                            width = 0.3,         -- Width as percentage (0.0-1.0) or absolute columns
                            height = 1,          -- Height as percentage (0.0-1.0) or absolute rows
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
                -- extensions = {
                --     mcphub = {
                --         callback = "mcphub.extensions.codecompanion",
                --         opts = {
                --             make_vars = true,
                --             make_slash_commands = true,
                --             show_result_in_chat = true
                --         }
                --     }
                -- }

            })
        end
    },
})

-- Avante
GogoVIM.AddPack({
    src = GogoVIM.GH("yetone/avante.nvim"),
    name = "avante.nvim",
    version = vim.version.range("v0.x"),
    data = {
        name = "avante",
        build = { "make", "BUILD_FROM_SOURCE=true" },
        config = function()
            local opts = {
                ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
                provider = "copilot",
                providers = {
                    copilot = {
                        model = "gpt-4.1",
                    },
                    ollama = {
                        endpoint = "http://127.0.0.1:11434",
                        -- codellama:latest
                        -- codellama:7b-instruct
                        -- codellama:34b
                        -- qwen3:latest
                        -- deepseek-coder:33b
                        -- starcoder2:15b
                        -- hf.co/lmstudio-community/Qwen2.5-7B-Instruct-1M-GGUF:Q8_0
                        -- qwen2.5-coder:1.5b
                        -- codegemma:latest
                        model = "deepseek-coder:33b",
                        maxtokens = 4096,
                        -- timeout = 3000,
                        extra_request_body = {
                            options = {
                                temperature = 0.75,
                                num_ctx = 20480,
                                keep_alive = "4m",
                            },
                        },
                        disable_tools = false,
                    },
                },
                acp_providers = {
                    ["gemini-cli"] = {
                        command = "gemini",
                        args = {
                            "--experimental-acp"
                        }
                    },
                },
                -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
                -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
                -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
                -- auto_suggestions_provider = "ollama",
                use_absolute_path = true,
                system_promt = function()
                    local default = [[
You are an expert Golang programmer that writes simple, concise code and explanations. Write a python function to generate the nth fibonacci number.

- write testcases using table driven pattern in form of `map[string]sturct`.
- using `require` and `mocks` as your go to tools.
- testcases is well structured and every external call will be mocked is presented by pointer to struct of inputs and mocked outputs, to be only mock the function if the value is provided in the testcase loop.

tools: use LSP feedback to know about errors, and don't stop until you fix all of them one by one.
        ]]
                    local hub = require('mcphub').get_hub_instance()
                    return hub and hub:get_active_servers_prompt() or default
                end,
                custom_tools = function()
                    return {
                        require('mcphub.extensions.avante').mcp_tool(),
                    }
                end,
                ---Specify the special dual_boost mode
                ---1. enabled: Whether to enable dual_boost mode. Default to false.
                ---2. first_provider: The first provider to generate response. Default to "openai".
                ---3. second_provider: The second provider to generate response. Default to "claude".
                ---4. prompt: The prompt to generate response based on the two reference outputs.
                ---5. timeout: Timeout in milliseconds. Default to 60000.
                ---How it works:
                --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
                ---Note: This is an experimental feature and may not work as expected.
                dual_boost = {
                    enabled = false,
                    -- first_provider = "openai",
                    -- second_provider = "claude",
                    -- prompt =
                    -- "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
                    -- timeout = 60000, -- Timeout in milliseconds
                },
                behaviour = {
                    auto_suggestions = false, -- Experimental stage
                    auto_set_highlight_group = true,
                    auto_set_keymaps = true,
                    auto_apply_diff_after_generation = false,
                    support_paste_from_clipboard = true,
                    enable_cursor_planning_mode = true,
                    minimize_diff = true,          -- Whether to remove unchanged lines when applying a code block
                    enable_token_counting = false, -- Whether to enable token counting. Default to true.
                    confirmation_ui_style = true,
                    acp_follow_agent_locations = true,
                },
                mappings = {
                    --- @class AvanteConflictMappings
                    diff = {
                        ours = "co",
                        theirs = "ct",
                        all_theirs = "ca",
                        both = "cb",
                        cursor = "cc",
                        next = "]x",
                        prev = "[x",
                    },
                    -- suggestion = {
                    --     accept = "<M-l>",
                    --     next = "<M-]>",
                    --     prev = "<M-[>",
                    --     dismiss = "<C-]>",
                    -- },
                    jump = {
                        next = "]]",
                        prev = "[[",
                    },
                    submit = {
                        normal = "<CR>",
                        insert = "<C-s>",
                    },
                    sidebar = {
                        apply_all = "A",
                        apply_cursor = "a",
                        switch_windows = "<Tab>",
                        reverse_switch_windows = "<S-Tab>",
                    },
                },
                hints = { enabled = true },
                windows = {
                    ---@type "right" | "left" | "top" | "bottom"
                    position = "right",   -- the position of the sidebar
                    wrap = true,          -- similar to vim.o.wrap
                    width = 30,           -- default % based on available width
                    sidebar_header = {
                        enabled = true,   -- true, false to enable/disable the header
                        align = "center", -- left, center, right for title
                        rounded = true,
                    },
                    input = {
                        prefix = "> ",
                        height = 8, -- Height of the input window in vertical layout
                    },
                    edit = {
                        border = "rounded",
                        start_insert = true, -- Start insert mode when opening the edit window
                    },
                    ask = {
                        floating = false,    -- Open the 'AvanteAsk' prompt in a floating window
                        start_insert = true, -- Start insert mode when opening the ask window
                        border = "rounded",
                        ---@type "ours" | "theirs"
                        focus_on_apply = "ours", -- which diff to focus after applying
                    },
                },
                highlights = {
                    diff = {
                        current = "DiffText",
                        incoming = "DiffAdd",
                    },
                },
                --- @class AvanteConflictUserConfig
                diff = {
                    autojump = true,
                    ---@type string | fun(): any
                    list_opener = "copen",
                    --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
                    --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
                    --- Disable by setting to -1.
                    override_timeoutlen = 500,
                },
                suggestion = {
                    debounce = 300,
                    throttle = 300,
                },
            }
            require("avante").setup(opts)
        end
    },
})
