--[[
  File: telescope.lua
  Description: Telescope plugin configuration
  See: https://github.com/nvim-telescope/telescope.nvim
]]

-- Fuzzy finder.
-- The default key bindings to find files will use Telescope's
-- `find_files` or `git_files` depending on whether the
-- directory is a git repo.
-- Telescope {{{
return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-telescope/telescope-symbols.nvim",
	},
	tag = "0.1.8",
	cmd = "Telescope",
	lazy = false,
	config = function(_, opts)
		local opts_extend = {
			pickers = {
				find_files = {
					hidden = true,
				},
			},
			defaults = {
				layout_strategy = "flex",
				layout_config = {
					-- flip_columns = 120,
					vertical = { width = 0.5 },
				},
				vimgrep_arguments = {
					"rg",
					"-L",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				file_ignore_patterns = {
					".git",
					"node%_modules",
				},
			},

			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},

			picker = GogoUI.telescope,
		}
		opts_extend = vim.tbl_deep_extend("error", opts, opts_extend)

		local flash = function(prompt_bufnr)
			require("flash").jump({
				pattern = "^",
				label = { after = { 0, 0 } },
				search = {
					mode = "search",
					exclude = {
						function(win)
							return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
						end,
					},
				},
				action = function(match)
					local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
					picker:set_selection(match.pos[1] - 1)
				end,
			})
		end
		opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
			mappings = { n = { s = flash }, i = { ["<c-s>"] = flash } },
		})

		require("telescope").setup(opts_extend)
		require("config").load_mapping("telescope")
	end,

	opts = function()
		local actions = require("telescope.actions")

		local open_selected_with_trouble = function(...)
			return require("trouble.providers.telescope").open_selected_with_trouble(...)
		end

		return {
			defaults = {
				prompt_prefix = GogoUI.icons.ui.Scopes .. " ",
				selection_caret = " ",
				-- open files in the first window that is an actual file.
				-- use the current window if no other window is available.
				get_selection_window = function()
					local wins = vim.api.nvim_list_wins()
					table.insert(wins, 1, vim.api.nvim_get_current_win())
					for _, win in ipairs(wins) do
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.bo[buf].buftype == "" then
							return win
						end
					end
					return 0
				end,
				mappings = {
					i = {
						["<C-t>"] = open_selected_with_trouble,
						["<C-Down>"] = actions.cycle_history_next,
						["<C-Up>"] = actions.cycle_history_prev,
						["<C-f>"] = actions.preview_scrolling_down,
						["<C-b>"] = actions.preview_scrolling_up,
					},
					n = {
						["q"] = actions.close,
					},
				},
			},
		}
	end,
}
-- }}}

