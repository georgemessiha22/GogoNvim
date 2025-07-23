return {
    "neovim/nvim-lspconfig",
    event = { "LazyFile" },
    dependencies = {
        {
            "williamboman/mason-lspconfig.nvim",
            opts = {
                automatic_enable = false,
                ensure_installed = {
                    "bashls",                      -- LSP for bash shell
                    "ts_ls",                       -- LSP for Typescript and Javascript
                    "emmet_ls",                    -- LSP for Emmet (Vue, HTML, CSS)
                    "cssls",                       -- LSP for CSS
                    "ruff",                        -- LSP for Python
                    "svelte",                      -- LSP for Svelte
                    "tailwindcss",                 -- LSP for TailWindCss
                    "marksman",                    -- LSP for Markdown
                    "dockerls",                    -- LSP for Dockerfile
                    "docker_compose_language_service", -- LSP for Docker-compose
                    -- "denols", -- LSP for deno
                    "sqlls",                       -- LSP SQL
                    "yamlls",                      -- LSP yaml
                    "rust_analyzer",               -- LSP Rust rust_analyzer
                    "jsonls",                      -- LSP json
                    "html",                        -- LSP html
                    "eslint",                      -- LSP eslint
                    "texlab",                      -- LSP Latex
                    "taplo",                       -- LSP TOML
                    "pbls",                        -- LSP PROTO
                    "pyright",                     -- LSP Python
                    "rust_analyzer",               -- LSP Rust
                    "gopls",                       -- LSP Go
                }
                ,
            }
        },
        -- "SmiteshP/nvim-navic", -- A simple statusline/winbar component that uses LSP to show your current code context.
        -- Named after the Indian satellite navigation system.
        "j-hui/fidget.nvim",   -- Extensible UI for Neovim notifications and LSP progress messages.
    },
}
