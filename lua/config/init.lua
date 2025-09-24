_G.GogoVIM = require("util")
_G.GogoUI = require("ui")

local M = {
    did_init = false,
    settings_loader = require("config.loader")
}

function M.init()
    if M.did_init then
        return
    end

    -- Load leader keys {{{
    vim.g.mapleader = GogoUI.leader
    vim.g.maplocalleader = GogoUI.localleader
    vim.opt.termguicolors = GogoUI.termguicolors
    -- }}}

    -- Setup Lazy {{{
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.loop.fs_stat(lazypath) then
        M.echo("  Installing lazy.nvim")
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end

    vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
    -- }}}

    -- Install Plugins from plugins directory and disable some builtins from `GogoUI.disabled_builtins`
    GogoVIM.lazy_file()

    -- Load Plugins {{{
    require("lazy").setup(require("plugins"), {
        defaults = {
            lazy = false,
            -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
            -- have outdated releases, which may break your Neovim install.
            version = false, -- always use the latest git commit
            -- version = "*", -- try installing the latest stable version for plugins that support semver
        },
        checker = { enabled = false }, -- automatically check for plugin updates
        performance = {
            rtp = {
                -- disable some rtp plugins
                disabled_plugins = GogoUI.disabled_builtins,
            },
        },
    })
    -- }}}
    --
    -- Load colorscheme
    vim.cmd.colorscheme(GogoUI.theme)
    -- M.Reload()

    M.settings_loader.options()
    GogoVIM.load_mapping()
    require("config.autocmds")

    M.lsp_defentions()
    M.did_init = true
end

function M.lsp_defentions()
    vim.diagnostic.config({ virtual_lines = true })

    local on_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
            -- A simple statusline/winbar component that uses LSP to show your current code context. Named after the Indian satellite navigation system.
            if GogoVIM.has("nvim-navic") then
                require("nvim-navic").attach(client, bufnr)
            end
        end
    end

    local capabilites = vim.lsp.protocol.make_client_capabilities()
    if GogoVIM.has("blink") then
        capabilites = require("blink.cmp").get_lsp_capabilities(nil, true)
    end


    -- Check if solargraph is installed and run the configurations.
    local solargraphLocation = os.getenv("HOME") .. "/.rbenv/shims/solargraph"
    local file = io.open(solargraphLocation, "r")
    if file ~= nil then
        io.close(file)
        vim.lsp.config.solargraph = {
            cmd = { solargraphLocation, "stdio" },
            root_markers = { 'Gemfile', '.git' },
            handlers = {
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
            init_options = { formatting = true },
            filetypes = { "ruby" },
        }
        vim.lsp.enable("solargraph")
    end

    vim.lsp.config.gopls = {
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
                    ST1019 = true,
                    ST1020 = true,
                    ST1021 = true,
                    ST1022 = true,
                    ST1023 = true,
                },
                staticcheck = true,
                gofumpt = true,
                buildFlags = { "-tags=functional,integration,unit,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6" },
                vulncheck = "Imports",
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
                -- run_govulncheck = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
            },
        },
    }
    vim.lsp.enable("gopls")

    vim.lsp.config.lua_ls = {
        capabilites = capabilites,
        on_attach = on_attach,
        init_options = {
            formatting = true,
        },
        settings = {
            Lua = {
                completion = {
                    callSnippet = "Replace",
                },
            },
        },
    }
    vim.lsp.enable("lua_ls")

    -- vim.lsp.config.golangci_lint_ls = {
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
    -- }
    -- vim.lsp.enable("golangci_lint_ls")

    vim.lsp.config.ruff = {
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        capabilites = capabilites,
        on_attach = on_attach,
        init_options = {
            settings = {
                interpreter = { './venv/bin/python' },
            }
        },
        root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    }
    vim.lsp.enable("ruff")

    GogoVIM.load_mapping("lspkeys")

    -- auto enable few servers.
    local auto_enable = {
        "bashls",                          -- LSP for bash shell
        "ts_ls",                           -- LSP for Typescript and Javascript
        "emmet_ls",                        -- LSP for Emmet (Vue, HTML, CSS)
        "cssls",                           -- LSP for CSS
        "svelte",                          -- LSP for Svelte
        "tailwindcss",                     -- LSP for TailWindCss
        "marksman",                        -- LSP for Markdown
        "dockerls",                        -- LSP for Dockerfile
        "docker_compose_language_service", -- LSP for Docker-compose
        "sqlls",                           -- LSP SQL
        "yamlls",                          -- LSP yaml
        "rust_analyzer",                   -- LSP Rust rust_analyzer
        "jsonls",                          -- LSP json
        "html",                            -- LSP html
        "eslint",                          -- LSP eslint
        "texlab",                          -- LSP Latex
        "taplo",                           -- LSP TOML
        "pbls",                            -- LSP PROTO
        "pyright",                         -- LSP Python
        "rust_analyzer",                   -- LSP Rust
    }
    for _, server in pairs(auto_enable) do
        vim.lsp.config[server].setup({
            capabilites = capabilites,
            on_attach = on_attach,
        })
        vim.lsp.enable(server)
    end
end

return M
