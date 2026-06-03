-- Diagnostic UI (cheap, runs at startup).
vim.diagnostic.config({
    severity_sort = true,
    float = {
        border = "single",
        source = true,
    },
    virtual_text = true,
    virtual_lines = {
        current_line = true,
        format = function(diagnostic)
            if diagnostic.source then
                return string.format("[%s] %s", diagnostic.source, diagnostic.message)
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

GogoVIM.lsp_on_attach = function(client, bufnr) end

-- Lazy capabilities: avoids forcing blink.cmp to load at startup.
local _caps
local function _get_caps()
    if _caps ~= nil then
        return _caps
    end
    if GogoVIM.has("blink.cmp") then
        local ok, blink = pcall(require, "blink.cmp")
        if ok then
            _caps = blink.get_lsp_capabilities(nil, true)
            return _caps
        end
    end
    _caps = vim.lsp.protocol.make_client_capabilities()
    return _caps
end

GogoVIM.lsp_capabilites = setmetatable({}, {
    __index = function(_, k)
        return _get_caps()[k]
    end,
})

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
    "docker_language_server",          -- LSP for Docker-file
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
    "stylua",                          -- LSP stylua formatter
    "tofu_ls",                         -- LSP for terraform
    "terraform_lsp",
    "fish_lsp",
}

-- Defer heavy LSP init (enable + per-server config) until the first buffer is
-- read or the UI is up. This avoids ~260ms at startup.
local lsp_inited = false
local function init_lsp()
    if lsp_inited then
        return
    end
    lsp_inited = true

    pcall(vim.lsp.document_color.enable, true, nil, { style = "virtual" })
    pcall(vim.lsp.codelens.enable, true)
    pcall(vim.lsp.inlay_hint.enable, true)
    if vim.lsp.inline_completion and vim.lsp.inline_completion.enable then
        pcall(vim.lsp.inline_completion.enable, true)
    end

    local capabilites = _get_caps()

    for _, server in pairs(auto_enable) do
        vim.lsp.config[server] = {
            capabilites = capabilites,
            on_attach = GogoVIM.lsp_on_attach,
        }
    end

    vim.lsp.enable(auto_enable)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "UIEnter" }, {
    group = vim.api.nvim_create_augroup("GogoVIM.lsp_deferred_init", { clear = true }),
    once = true,
    callback = function()
        vim.schedule(init_lsp)
    end,
})

GogoVIM.lsp_init = init_lsp
