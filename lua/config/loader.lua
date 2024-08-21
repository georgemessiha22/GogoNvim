--[[
  File: settings.lua
  Description: Base settings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]

local M = {}

---Set the general configurations for neovim.
---@param opts ui
function M.general(opts)
	-------------------------------------- globals -----------------------------------------
	vim.cmd.colorscheme(opts.theme)
	vim.guifont = opts.font

	vim.g.toggle_theme_icon = opts.toggle_theme_icon
	vim.g.neon_transparent = opts.transparency
	vim.g.neon_style = opts.theme_toggle[1]
	vim.g.minipairs_disable = false

	-- add binaries installed by mason.nvim to path
	vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

	-- disable some builtin packages
	for _, plugin in pairs(opts.disabled_builtins) do
		vim.g["loaded_" .. plugin] = 1
	end

	vim.o.formatexpr = "v:lua.require('util.format').formatexpr()"
	-- Fix markdown indentation settings
	vim.g.markdown_recommended_style = 0

	vim.g.autoformat = true

	vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

	vim.g.lazygit_config = true

	vim.g.loaded_perl_provider = false
	vim.filetype = true
end

---Set the options for neovim.
---@param opts ui
function M.options(opts)
	local opt = vim.opt

	-------------------------------------- options ------------------------------------------
	opt.laststatus = 3  -- global statusline
	opt.showmode = true -- Dont show mode since we have a statusline
	opt.termguicolors = opts.termguicolors
	opt.colorcolumn = "120"

	-- General {{{
	opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
	opt.confirm = true   -- Confirm to save changes before exiting modified buffer
	opt.spelllang = { "en" }
	opt.timeoutlen = 500
	opt.undofile = true
	opt.undolevels = 10000

	opt.updatetime = 200 -- Save swap file and trigger CursorHold
	opt.winminwidth = 5  -- Minimum window width
	opt.fillchars = opts.icons.fillchars
	if vim.fn.has("nvim-0.10") == 1 then
		opt.smoothscroll = true
	end
	-- }}}

	-- Clipboard {{{
	if not vim.env.SSH_TTY then
		-- only set clipboard if not in ssh, to make sure the OSC 52
		-- integration works automatically. Requires Neovim >= 0.10.0
		opt.clipboard = "unnamedplus" -- Sync with system clipboard
	end
	opt.fixeol = false              -- Turn off appending new line in the end of a file
	opt.cursorline = true           -- Enable highlighting of the current line
	-- }}}

	-- Indenting {{{
	opt.expandtab = false  -- Use spaces instead of tabs
	opt.shiftwidth = 2     -- Size of an indent
	opt.shiftround = true  -- Round indent
	opt.smartindent = true -- Insert indents automatically
	opt.tabstop = 2        -- Number of spaces tabs count for
	opt.softtabstop = 2

	opt.ignorecase = true
	opt.mouse = "a"       -- Enable mouse mode
	opt.sidescrolloff = 8 -- Columns of context
	-- }}}

	-- Folding {{{
	opt.foldmethod = "indent"
	opt.foldlevelstart = 99
	opt.foldlevel = 99
	--
	if vim.fn.has("nvim-0.9.0") == 1 then
		opt.statuscolumn = [[%!v:lua.require('util.ui').statuscolumn()]]
		opt.foldtext = "v:lua.require('util.ui').foldtext()"
	end

	-- HACK: causes freezes on <= 0.9, so only enable on >= 0.10 for now
	if vim.fn.has("nvim-0.10") == 1 then
		opt.foldmethod = "expr"
		opt.foldexpr = "v:lua.require('util.ui').foldexpr()"
		opt.foldtext = ""
		-- opt.fillchars = "fold: "

		if vim.lsp.inlay_hint then
			vim.lsp.inlay_hint.enable(true, { 0 })
		end
	else
		opt.foldmethod = "indent"
	end
	-- }}}

	-- Numbers {{{
	opt.relativenumber = true -- Relative line numbers
	opt.number = true         -- Print line number
	opt.numberwidth = 4
	opt.ruler = true
	opt.scrolloff = 4 -- Lines of context
	opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
	-- }}}

	-- Search {{{
	opt.ignorecase = true      -- Ignore case if all characters in lower case
	opt.joinspaces = false     -- Join multiple spaces in search
	opt.smartcase = true       -- When there is a one capital letter search for exact match
	opt.showmatch = true       -- Highlight search instances
	opt.inccommand = "nosplit" -- preview incremental substitute
	-- }}}

	-- Window {{{
	opt.splitkeep = "screen"
	opt.splitbelow = true  -- Put new windows below current
	opt.splitright = true  -- Put new vertical splits to right
	opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
	opt.wrap = true        -- Disable line wrap

	-- go to previous/next line with h,l,left arrow and right arrow
	-- when cursor reaches end/beginning of line
	opt.whichwrap:append("<>[]hl")

	opt.autowrite = true      -- Enable auto write
	opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
	-- }}}

	-- Wild Menu {{{
	opt.wildmenu = true
	opt.wildmode = "longest:full,full" -- Command-line completion mode
	-- disable nvim default complete
	opt.completeopt = { "menu", "menuone", "noselect" }
	-- }}}

	-- Unknown {{{
	opt.formatoptions = "jcroqlnt" -- tcqj
	opt.grepformat = "%f:%l:%c:%m"
	opt.grepprg = "rg --vimgrep"
	opt.list = true    -- Show some invisible characters (tabs...
	opt.pumblend = 10  -- Popup blend
	opt.pumheight = 10 -- Maximum number of entries in a popup
	opt.shortmess:append({ W = true, I = true, c = true, C = true })
	-- }}}
end

---Set the mapleader; must be used before calling lazy.setup.
function M.leader()
	vim.g.mapleader = GogoUI.leader
	vim.g.maplocalleader = GogoUI.localleader
	vim.opt.termguicolors = GogoUI.termguicolors
end

function M.autocmds()
	require("config.autocmds")
end

return M
