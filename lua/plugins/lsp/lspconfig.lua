return {
    "neovim/nvim-lspconfig",
    event = { "LazyFile" },
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "SmiteshP/nvim-navic", -- A simple statusline/winbar component that uses LSP to show your current code context.
        -- Named after the Indian satellite navigation system.
        "j-hui/fidget.nvim",   -- Extensible UI for Neovim notifications and LSP progress messages.
    },
    config = function(_)
        vim.diagnostic.config({ virtual_lines = true })
        local on_attach = function(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                -- A simple statusline/winbar component that uses LSP to show your current code context. Named after the Indian satellite navigation system.
                require("nvim-navic").attach(client, bufnr)
            end
        end

        local lspconfig = require("lspconfig")

        local capabilites = vim.lsp.protocol.make_client_capabilities()
        if GogoVIM.has("blink") then
            capabilites = require("blink.cmp").get_lsp_capabilities()
        end

        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
            automatic_installation = false,
            ensure_installed = {
                "bashls",                          -- LSP for bash shell
                "lua_ls",                          -- LSP for Lua language
                "ts_ls",                           -- LSP for Typescript and Javascript
                "emmet_ls",                        -- LSP for Emmet (Vue, HTML, CSS)
                "cssls",                           -- LSP for CSS
                "ruff",                            -- LSP for Python
                "gopls",                           -- LSP for Go
                "golangci_lint_ls",                -- LSP for golangci-lint
                "svelte",                          -- LSP for Svelte
                "volar",                           -- LSP Vue.JS
                "tailwindcss",                     -- LSP for TailWindCss
                "marksman",                        -- LSP for Markdown
                "dockerls",                        -- LSP for Dockerfile
                "docker_compose_language_service", -- LSP for Docker-compose
                -- "denols", -- LSP for deno
                "sqlls",                           -- LSP SQL
                "yamlls",                          -- LSP yaml
                "rust_analyzer",                   -- LSP Rust rust_analyzer
                "jsonls",                          -- LSP json
                "html",                            -- LSP html
                "eslint",                          -- LSP eslint
                "texlab",                          -- LSP Latex
                "taplo",                           -- LSP TOML
                "pbls",                            -- LSP PROTO
            },
            handlers = {
                function(server_name)
                    if server_name == "gopls" then
                        lspconfig.gopls.setup({
                            capabilites = capabilites,
                            on_attach = on_attach,
                            filetypes = { "go", "gomod", "gowork", "gotmpl" },
                            fillstruct = "gopls",
                            settings = {
                                gopls = {
                                    analyses = {
                                        unusedparams = true,
                                        unusedwrite = true,
                                        shadow = true,
                                        unusedvariable = true,
                                        useany = true,
                                    },
                                    staticcheck = true,
                                    gofumpt = true,
                                    buildFlags = { "-tags=functional,integration,unit,functional_1" },
                                    vulncheck = { "Imports" },
                                    hints = {
                                        assignVariableTypes = true,
                                        compositeLiteralFields = true,
                                        compositeLiteralTypes = true,
                                        constantValues = true,
                                        functionTypeParameters = true,
                                        parameterNames = true,
                                        rangeVariableTypes = true,
                                    },
                                },
                                codelenses = {
                                    gc_details = true,
                                    generate = true,
                                    regenerate_cgo = true,
                                    run_govulncheck = true,
                                    tidy = true,
                                    upgrade_dependency = true,
                                    vendor = true,
                                },
                            },
                        })
                    elseif server_name == "lua_ls" then
                        lspconfig.lua_ls.setup({
                            capabilites = capabilites,
                            on_attach = on_attach,
                            settings = {
                                Lua = {
                                    completion = {
                                        callSnippet = "Replace",
                                    },
                                },
                            },
                        })
                    elseif server_name == "golangci_lint_ls" then
                        lspconfig.golangci_lint_ls.setup({
                            capabilites = capabilites,
                            command = {
                                "golangci-lint",
                                "run",
                                "--out-format", "json",
                                "--tests",
                                "--issues-exit-code", "1",
                                "--build-tags", "unit,integration,functional",
                                "--timeout", "30s"
                            },
                        })
                    elseif server_name == "ruff" then
                        lspconfig.ruff.setup({
                            capabilites = capabilites,
                            on_attach = on_attach,
                            init_options = {
                                settings = {
                                    interpreter = { './venv/bin/python' },
                                }
                            },
                        })
                    else
                        lspconfig[server_name].setup({
                            capabilites = capabilites,
                            on_attach = on_attach,
                        })
                    end
                end,
            },
        })

        -- Check if solargraph is installed and run the configurations.
        local solargraphLocation = os.getenv("HOME") .. "/.rbenv/shims/solargraph"
        local file = io.open(solargraphLocation, "r")
        if file ~= nil then
            io.close(file)
            lspconfig.solargraph.setup({
                cmd = { solargraphLocation, "stdio" },
                root_dir = lspconfig.util.root_pattern("Gemfile", ".git", "."),
                handlers = {
                    ["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
                        virtual_lines = true,
                    }),
                },
                settings = {
                    solargraph = {
                        autoformat = false,
                        formatting = false,
                        completion = true,
                        diagnostic = true,
                        folding = true,
                        references = true,
                        rename = true,
                        symbols = true,
                    },
                },
                filetypes = { "ruby" },
            })
        end

        require("config").load_mapping("lspconfig")
    end,
}
