return {
    { "folke/lazy.nvim",      version = "*" },
    { "nvim-lua/plenary.nvim" },
    -- colors{{{
    require("plugins.editor.colorscheme"),
    -- }}}

    -- Code {{{
    require("plugins.code.luasnip"),
    require("plugins.code.blink"),
    require("plugins.code.todo-comment"),
    -- }}}

    -- LSP {{{
    require("plugins.lsp"),
    -- }}}

    -- Git {{{
    require("plugins.code.gitsigns"),
    -- }}}

    -- Editor View {{{
    require("plugins.editor.snacks"),
    require("plugins.editor.mininvim"),
    require("plugins.editor.flash"),
    require("plugins.editor.trouble"),
    -- require("plugins.editor.harpoon2"),
    -- require("plugins.editor.telescope"),
    require("plugins.editor.fzflua"),
    -- require("plugins.editor.dressing"),
    { "MunifTanjim/nui.nvim", lazy = true },
    require("plugins.editor.noice"),
    require("plugins.editor.whichkey"),
    -- require("plugins.editor.persistence"),
    -- require("plugins.editor.dashboard"),
    require("plugins.editor.mcphub"),
    require("plugins.editor.avante"),
    -- }}}
}
