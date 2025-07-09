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
        })
        -- require("fzf-lua").setup({"fzf-vim"})
        -- require("fzf-lua").setup({"telescope"})
        GogoVIM.load_mapping("fzflua")
    end
}
-- }}}
