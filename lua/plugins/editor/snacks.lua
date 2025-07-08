return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
        require("snacks").setup(
            {
                picker = {
                    enabled = false,
                },
                dashboard = {
                    enabled = true,
                    preset = {
                        header = GogoUI.dash.header,
                    },
                },
                dim = { enabled = true },
                -- indent = { enabled = true },
                input = { enabled = true },
                bigfile = { enabled = true },
                notify = { enabled = true },
                notifier = { enabled = true },
                quickfile = { enabled = true },
                scope = { enabled = true },
                scratch = { enabled = true },
                statuscolumn = { enabled = true },
                words = { enabled = true },
                lazygit = { enabled = true },
            })
        GogoVIM.load_mapping("snacks")
    end
}
