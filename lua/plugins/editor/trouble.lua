--[[
  File: trouble.lua
  Description: Configuration of trouble.nvim
  See: https://github.com/folke/trouble.nvim
]]
-- Trouble {{{
return {
	"folke/trouble.nvim",
	lazy = false,
	cmd = { "TroubleToggle", "Trouble" },
	opts = { use_diagnostic_signs = true },
	config = function(_, opts)
		require("trouble").setup(opts)
		GogoVIM.load_mapping("trouble")
	end,
}
-- }}}
