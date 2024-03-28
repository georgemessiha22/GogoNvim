--[[
  File: neotree.lua
  Description: NeoTree plugin configuration
  See: https://github.com/nvim-neo-tree/neo-tree.nvim
]]
-- Neo Tree {{{
return {
	"nvim-neo-tree/neo-tree.nvim",
	event = "LazyFile",
	branch = "v3.x",
	dependencies = {
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		{
			"s1n7ax/nvim-window-picker",
			version = "2.*",
			config = function()
				require("window-picker").setup({
					hint = "statusline-windbar",
					filter_rules = {
						include_current_win = false,
						autoselect_one = true,
						-- filter using buffer options
						bo = {
							-- if the file type is one of following, the window will be ignored
							filetype = { "neo-tree", "neo-tree-popup", "notify" },
							-- if the buffer type is one of following, the window will be ignored
							buftype = { "terminal", "quickfix" },
						},
					},
				})
			end,
		},
	},
	config = function()
		local icons = GogoUI.icons
		-- If you want icons for diagnostic errors, you'll need to define them somewhere:
		vim.fn.sign_define("DiagnosticSignError", { text = icons.diagnostics.Error, texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = icons.diagnostics.BoldWarning, texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define(
			"DiagnosticSignInfo",
			{ text = icons.diagnostics.BoldInformation, texthl = "DiagnosticSignInfo" }
		)
		vim.fn.sign_define("DiagnosticSignHint", { text = icons.diagnostics.BoldHint, texthl = "DiagnosticSignHint" })
		require("neo-tree").setup({
			sources = { "filesystem", "buffers", "git_status", "document_symbols" },
			open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
			filesystem = {
				bind_to_cwd = false,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
			},
			window = {
				mappings = {
					["l"] = "open",
					["h"] = "close_node",
					["<space>"] = "none",
					["Y"] = {
						function(state)
							local node = state.tree:get_node()
							local path = node:get_id()
							vim.fn.setreg("+", path, "c")
						end,
						desc = "copy path to clipboard",
					},
				},
			},
			default_component_configs = {
				indent = {
					with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
					expander_collapsed = "",
					expander_expanded = "",
					expander_highlight = "NeoTreeExpander",
				},
			},

			close_if_last_window = true,
			name = {
				trailing_slash = true,
				use_git_status_colors = true,
				highlight = "NeoTreeFileName",
			},
			source_selector = {
				winbar = false,
				statusline = true,
			},
		})

		vim.api.nvim_create_autocmd("TermClose", {
			pattern = "*lazygit",
			callback = function()
				if package.loaded["neo-tree.sources.git_status"] then
					require("neo-tree.sources.git_status").refresh()
				end
			end,
		})

		require("config").load_mapping("neotree")
	end,

	cmd = "Neotree",
	deactivate = function()
		vim.cmd([[Neotree close]])
	end,
	init = function()
		if vim.fn.argc(-1) == 1 then
			local stat = vim.uv.fs_stat(vim.fn.argv(0))
			if stat and stat.type == "directory" then
				require("neo-tree")
			end
		end
	end,
}
-- }}}
