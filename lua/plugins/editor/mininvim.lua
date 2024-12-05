return {
	"echasnovski/mini.nvim",
	version = "*",
	config = function()
		require("mini.operators").setup()
		require("mini.surround").setup()
		require("mini.ai").setup()

		-- require("mini.align").setup()
		-- require("mini.animate").setup()
		-- require("mini.basics").setup()
		-- require("mini.bracketed").setup()
		-- require("mini.bufremove").setup()
		-- local miniclue = require("mini.clue") -- replacement to whichKey
		-- miniclue.setup({
		-- 	triggers = {
		-- 		{ mode = 'n', keys = '<leader>' },
		-- 		{ mode = 'i', keys = '<C>' },
		-- 		{ mode = 'n', keys = '`' },
		-- 		{ mode = 'n', keys = '"' },
		-- 		{ mode = 'n', keys = "'" },
		-- 		{ mode = 'n', keys = 'c' },
		-- 		{ mode = 'n', keys = 'v' },
		-- 		{ mode = 'n', keys = 'g' },
		-- 		{ mode = 'n', keys = 'f' },
		-- 		{ mode = 'n', keys = 't' },
		-- 		{ mode = 'n', keys = '<C>' },
		-- 	},
		-- 	clues = { -- Enhance this by adding descriptions for <Leader> mapping groups
		-- 		miniclue.gen_clues.builtin_completion(),
		-- 		-- miniclue.gen_clues.g(),
		-- 		miniclue.gen_clues.marks(),
		-- 		miniclue.gen_clues.registers(),
		-- 		miniclue.gen_clues.windows(),
		-- 		miniclue.gen_clues.z(),
		-- 	},
		-- 	windows = {
		-- 		delay = 100,
		-- 	},
		-- })
		-- require("mini.comment").setup()
		-- require("mini.completion").setup({ set_vim_settings = true })
		require("mini.cursorword").setup() -- highlight words under cursor
		-- require("mini.doc").setup()
		require("mini.diff").setup()
		-- require("mini.extra").setup()
		require("mini.files").setup({ windows = { preview = true, width_preview = 80, }, })
		require("config").load_mapping("minifiles")
		-- require("mini.fuzzy").setup()
		require("mini.git").setup()
		--
		-- replaced with todo-comment
		-- local hipatterns = require("mini.hipatterns")
		-- hipatterns.setup({
		-- 	highlighters = {
		-- 		-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
		-- 		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		-- 		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		-- 		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		-- 		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
		-- 		ie = { pattern = "%f[%w]()I.E()%f[%W]", group = "MiniHipatternsNote" },
		-- 		ies = { pattern = "%f[%w]()i.e()%f[%W]", group = "MiniHipatternsNote" },
		--
		-- 		-- Highlight hex color strings (`#rrggbb`) using that color
		-- 		hex_color = hipatterns.gen_highlighter.hex_color(),
		-- 	},
		-- })

		require("mini.icons").setup()
		require("mini.indentscope").setup()
		-- require("mini.jump").setup()
		-- require("mini.jump2d").setup()
		-- require("mini.map").setup()
		-- require("mini.misc").setup()
		-- require("mini.move").setup()
		-- require("mini.notify").setup() -- Looks bad with lsp progress
		require("mini.pairs").setup()
		require("mini.pick").setup()
		require("mini.sessions").setup()
		-- require("mini.splitjoin").setup()
		-- require("mini.starter").setup()
		require("mini.statusline").setup({
			use_icons = vim.g.have_nerd_font,
			content = {
				active = function()
					local check_macro_recording = function()
						if vim.fn.reg_recording() ~= "" then
							return "Recording @" .. vim.fn.reg_recording()
						else
							return ""
						end
					end

					local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
					local git = MiniStatusline.section_git({ trunc_width = 40 })
					local diff = MiniStatusline.section_diff({ trunc_width = 75 })
					local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
					-- local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
					local filename = MiniStatusline.section_filename({ trunc_width = 140 })
					local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
					local location = MiniStatusline.section_location({ trunc_width = 200 })
					local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
					local macro = check_macro_recording()

					return MiniStatusline.combine_groups({
						{ hl = mode_hl,                 strings = { mode } },
						{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
						"%<", -- Mark general truncate point
						{ hl = "MiniStatuslineFilename", strings = { filename } },
						"%=", -- End left alignment
						{ hl = "MiniStatuslineFilename", strings = { macro } },
						{ hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
						{ hl = mode_hl,                  strings = { search, location } },
					})
				end,
			},
		}
		)
		-- Autocmd to track macro recording, And redraw statusline, which trigger
		-- macro function of mini.statusline
		vim.api.nvim_create_autocmd("RecordingEnter", {
			pattern = "*",
			callback = function()
				vim.cmd("redrawstatus")
			end,
		})

		-- Autocmd to track the end of macro recording
		vim.api.nvim_create_autocmd("RecordingLeave", {
			pattern = "*",
			callback = function()
				vim.cmd("redrawstatus")
			end,
		})
		-- require("mini.tabline").setup()
		-- require("mini.test").setup()
		-- require("mini.trailspace").setup()
		-- require("mini.visits").setup()
	end,
}
