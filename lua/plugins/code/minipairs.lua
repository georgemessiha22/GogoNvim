-- auto pairs
return {
	"echasnovski/mini.pairs",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>up",
			function()
				vim.g.minipairs_disable = not vim.g.minipairs_disable
				if vim.g.minipairs_disable then
					GogoVIM.warn("Disabled auto pairs", { title = "Option" })
				else
					GogoVIM.info("Enabled auto pairs", { title = "Option" })
				end
			end,
			desc = "Toggle auto pairs",
		},
	},
}
