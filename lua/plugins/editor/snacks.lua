return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("snacks").setup(
            {
                -- picker = {
                --     enabled = false,
                -- },
                -- dashboard = {
                --     enabled = true,
                --     preset = {
                --         header = GogoUI.dash.header,
                --     },
                -- },
                -- dim = { enabled = true },
                -- indent = { enabled = true },
                -- input = {  prompt_pos="title", expand=true},
                -- bigfile = { enabled = true },
                notify = { enabled = true },
                notifier = { enabled = true },
                -- quickfile = { enabled = true },
                -- scope = { enabled = true },
                -- scratch = { enabled = true },
                -- statuscolumn = {
                --     enabled = true,
                --     left = { "mark", "sign" }, -- priority of signs on the left (high to low)
                --     right = { "fold", "git" }, -- priority of signs on the right (high to low)
                --     folds = {
                --         open = false, -- show open fold icons
                --         git_hl = false, -- use Git Signs hl for fold icons
                --     },
                --     git = {
                --         -- patterns to match Git signs
                --         patterns = { "GitSign", "MiniDiffSign" },
                --     },
                --     refresh = 50, -- refresh at most every 50ms
                -- },
                -- words = { enabled = true },
                terminal = { enabled = false },
                lazygit = { enabled = true },
            })
        GogoVIM.load_mapping("snacks")
    end
}
