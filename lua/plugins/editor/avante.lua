return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
        ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
        provider = "copilot",
        providers = {
            gemini = {
                model = "gemini-2.5-pro",
            },
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
                model = "deepseek-coder:6.7b",
                maxtokens = 4096,
                -- timeout = 3000,
                extra_request_body = {
                    options = {
                        temperature = 0.75,
                        num_ctx = 20480,
                        keep_alive = "4m",
                    },
                },
                disable_tools = true,
            },
        }, -- Recommend using Claude
        -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
        -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
        -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
        auto_suggestions_provider = "ollama",
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
            minimize_diff = true,         -- Whether to remove unchanged lines when applying a code block
            enable_token_counting = true, -- Whether to enable token counting. Default to true.
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
        -- suggestion = {
        --     debounce = 300,
        --     throttle = 300,
        -- },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                -- { latex = { enabled = false } },
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
        {
            "zbirenbaum/copilot.lua",
            cmd = "Copilot",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({})
            end,
        }
    },
}
