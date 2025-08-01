-- {{{
return {
    "ibhagwan/fzf-lua",
    config = function(_)
        -- require("fzf-lua").setup({"fzf-native"})
        -- require("fzf-lua").setup({"telescope", winopts={preview={default="bat"}}})
        require("fzf-lua").setup({
            { "telescope", "fzf-native" },
            winopts = { preview = { default = "bat" } },
            grep = {
                rg_opts =
                "--hidden --column --line-number --no-heading --sort-files --color=always --smart-case -g '!{.git,node_modules,vendor}/*'",
            },
        }, true)

        -- require("fzf-lua").setup({"fzf-vim"})
        -- require("fzf-lua").setup({"telescope"})
        GogoVIM.load_mapping("fzflua")
        require("fzf-lua.providers.ui_select").register()
        -- require("fzf-lua.config").defaults.actions.files["ctrl-t"] = require("trouble.sources.fzf").actions.open
    end
}
-- }}}
