vim.diagnostic.config(
    {
        severity_sort = true,
        float = {
            border = 'single',
            source = true,
        },
        virtual_text = true,
        virtual_lines = {
            current_line = true,
            format = function(diagnostic)
                if diagnostic.source then
                    return string.format('[%s] %s', diagnostic.source, diagnostic.message)
                end
                return diagnostic.message
            end,
        },
        signs = {
            text = {
                [vim.diagnostic.severity.ERROR] = GogoVIM.UI.icons.diagnostics.Error,
                [vim.diagnostic.severity.WARN] = GogoVIM.UI.icons.diagnostics.Warn,
                [vim.diagnostic.severity.INFO] = GogoVIM.UI.icons.diagnostics.Info,
                [vim.diagnostic.severity.HINT] = GogoVIM.UI.icons.diagnostics.Hint,
            },
        },
    })

vim.lsp.document_color.enable(true, nil, { style = 'virtual' })
vim.lsp.codelens.enable(true)
vim.lsp.inlay_hint.enable(true)
vim.lsp.inline_completion.enable(true)

GogoVIM.lsp_on_attach = function(client, bufnr)
end

local capabilites = vim.lsp.protocol.make_client_capabilities()
if GogoVIM.has("blink.cmp") then
    capabilites = require("blink.cmp").get_lsp_capabilities(nil, true)
end

GogoVIM.lsp_capabilites = capabilites

-- auto enable few servers.
local auto_enable = {
    "lua_ls",
    "solargraph",                      -- LSP for Ruby on Rails
    "golangci_lint_ls",                -- LSP for Golang format
    "gopls",                           -- LSP for Golang
    "ruff",                            -- LSP for python
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
    vim.lsp.config[server] = {
        capabilites = capabilites,
        on_attach = GogoVIM.lsp_on_attach,
    }
end

vim.lsp.enable(auto_enable)
