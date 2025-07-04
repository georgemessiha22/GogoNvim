return {
    "stevearc/conform.nvim",
    config = function(opts)
        require("conform").setup({

            formatters_by_ft = {
                python = { "ruff_fix", "ruff_organize_imports" },
                -- yaml = { "yamlfix" },
                fish = { "fish_indent" },
                -- bash = { "bash" },
                sql = { "sqruff" },
                go = { "goimports" },
                tf = { "tfmt" },
                terraform = { "tfmt" },
                hcl = { "tfmt" },
            },
            formatters = {
                tfmt = {
                    command = "tofu",
                    args = { "fmt", "-" },
                    stdin = true,
                },
            },
            default_format_opts = {
                lsp_format = "fallback",
            },
            notify_on_error = true,
        })


        GogoVIM.load_mapping("conform")
    end
}
