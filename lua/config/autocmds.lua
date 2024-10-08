-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
	return vim.api.nvim_create_augroup("GogoVIM_" .. name, { clear = true })
end

-- format on save all files
-- autocmd("BufWritePre", {
--   pattern = "*",
--   -- exclude = { "*.rb" },
--   callback = function(args)
--     require("conform").format({ bufnr = args.buf })
--   end,
--   group = augroup("Format"),
-- })

-- autocmd("BufWritePost", {
-- 	pattern = "*.go",
-- 	callback = function()
-- 		vim.notify("PostWrite", vim.log.levels.WARN, {})
-- 	end,
-- 	group = format_sync_grp,
-- })
-- dont list quickfix buffers
-- autocmd("FileType", {
-- 	pattern = "qf",
-- 	callback = function()
-- 		vim.opt_local.buflisted = false
-- 	end,
-- })

-- reload some options on-save
-- autocmd("BufWritePost", {
--   pattern = vim.tbl_map(function(path)
--     return vim.fs.normalize(vim.loop.fs_realpath(path))
--   end, vim.fn.glob(vim.fn.stdpath("config") .. "/lua/*.lua", true, true, true)),
--   group = vim.api.nvim_create_augroup("ReloadConfig", {}),
--
--   callback = function(opts)
--     local fp = vim.fn.fnamemodify(vim.fs.normalize(vim.api.nvim_buf_get_name(opts.buf)), ":r") --[[@as string]]
--     local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"
--
--     local module = string.gsub(fp, "^.*/" .. app_name .. "/lua/", ""):gsub("/", ".")
--     -- vim.notify(vim.inspect(module))
--
--     require("plenary.reload").reload_module(module)
--
--     require("config").load_config()
--
--     vim.cmd("redraw!")
--   end,
-- })

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		GogoVIM.on_very_lazy(function()
			if vim.o.buftype ~= "nofile" then
				vim.cmd("checktime")
			end
		end)
	end,
})

-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		GogoVIM.on_very_lazy(function()
			vim.highlight.on_yank()
		end)
	end,
})

-- resize splits if window got resized
autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		GogoVIM.on_very_lazy(function()
			local current_tab = vim.fn.tabpagenr()
			vim.cmd("tabdo wincmd =")
			vim.cmd("tabnext " .. current_tab)
		end)
	end,
})

-- go to last loc when opening a buffer
autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		GogoVIM.on_very_lazy(function()
			local exclude = { "gitcommit" }
			local buf = event.buf
			if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
				return
			end
			vim.b[buf].lazyvim_last_loc = true
			local mark = vim.api.nvim_buf_get_mark(buf, '"')
			local lcount = vim.api.nvim_buf_line_count(buf)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end)
	end,
})

-- close some filetypes with <q>
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		GogoVIM.on_very_lazy(function()
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
		end)
	end,
})

-- make it easier to close man-files when opened inline
autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		GogoVIM.on_very_lazy(function()
			vim.bo[event.buf].buflisted = false
		end)
	end,
})

-- wrap and check for spell in text filetypes
autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		GogoVIM.on_very_lazy(function()
			vim.opt_local.wrap = true
			vim.opt_local.spell = true
		end)
	end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		GogoVIM.on_very_lazy(function()
			vim.opt_local.conceallevel = 0
		end)
	end,
})

-- Fix tabexpand for yaml files
autocmd({ "FileType" }, {
	group = augroup("yaml"),
	pattern = { "yaml", "yml" },
	callback = function(_)
		GogoVIM.on_very_lazy(function()
			vim.opt_local.expandtab = true
		end)
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		GogoVIM.on_very_lazy(function()
			if event.match:match("^%w%w+:[\\/][\\/]") then
				return
			end
			local file = vim.uv.fs_realpath(event.match) or event.match
			vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
		end)
	end,
})
