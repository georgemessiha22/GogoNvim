local M = {
    did_init = false,
}

function M.init()
    if M.did_init then
        return
    end

    -- Load leader keys {{{
    vim.g.mapleader = GogoVIM.UI.leader
    vim.g.maplocalleader = GogoVIM.UI.localleader
    -- }}}

    require("config.packs")

    -- Load colorscheme
    vim.cmd.colorscheme(GogoVIM.UI.theme)

    GogoVIM.load_mapping()

    require("config.options")
    require("config.lsp")
    require("config.autocmds")
    M.did_init = true
end

return M
