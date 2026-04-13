local opt = vim.opt

-------------------------------------- options ------------------------------------------
opt.laststatus = 3  -- global statusline
opt.showmode = true -- Don't show mode since we have a statusline
opt.termguicolors = GogoVIM.UI.termguicolors
opt.colorcolumn = "120"

-- General {{{
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true   -- Confirm to save changes before exiting modified buffer
opt.spell = true
opt.spelllang = { "en" }
opt.spelloptions = "camel,noplainbuffer"
opt.timeoutlen = 500
opt.undofile = true
opt.undolevels = 10000

opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.winminwidth = 5  -- Minimum window width
opt.winborder = "rounded"
opt.fillchars = GogoVIM.UI.icons.fillchars
opt.smoothscroll = true
-- }}}

-- Clipboard {{{
opt.clipboard = "unnamed" -- Sync with system clipboard
if not vim.env.SSH_TTY then
    -- only set clipboard if not in ssh, to make sure the OSC 52
    -- integration works automatically. Requires Neovim >= 0.10.0
    opt.clipboard = "unnamedplus" -- Sync with system clipboard
end
opt.fixeol = true                 -- Turn off appending new line in the end of a file
opt.cursorline = true             -- Enable highlighting of the current line
-- }}}

-- Indenting {{{
opt.expandtab = true   -- Use spaces instead of tabs
opt.shiftwidth = 4     -- Size of an indent
opt.shiftround = true  -- Round indent
opt.smartindent = true -- Insert indents automatically
opt.tabstop = 4        -- Number of spaces tabs count for
opt.softtabstop = 4

opt.mouse = "a"       -- Enable mouse mode
opt.sidescrolloff = 8 -- Columns of context
-- }}}

-- Folding {{{
opt.foldlevelstart = 99
opt.foldlevel = 99

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--

if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 1 })
end
-- }}}

-- Numbers {{{
opt.relativenumber = false -- Relative line numbers
opt.number = true          -- Print line number
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
opt.splitbelow = true       -- Put new windows below current
opt.splitright = true       -- Put new vertical splits to right
vim.o.signcolumn = "auto:1" -- Always show the signColumn, otherwise it would shift the text each time
opt.wrap = true

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
-- opt.completeopt = { "menu", "menuone", "noselect", "popup" }
-- }}}

-- un-Grouped {{{
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.list = true    -- Show some invisible characters (tabs...
opt.listchars = GogoVIM.UI.icons.listchars
opt.pumblend = 10  -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.shortmess:append("w")
-- }}}

-- ftplugin {{{
vim.cmd("filetype plugin indent on")
vim.cmd("syntax on")
-- }}}
--
vim.g.trouble_lualine = true

-- Experimental UI2: floating cmdline and messages
vim.o.cmdheight = 0

-- UI2 messages position to top right
require("vim._core.ui2").enable({
    enable = true,
    msg = {
        targets = {
            [''] = 'msg',
            empty = 'cmd',
            bufwrite = 'cmd',
            confirm = 'cmd',
            emsg = 'pager',
            echo = 'msg',
            echomsg = 'msg',
            echoerr = 'pager',
            completion = 'cmd',
            list_cmd = 'pager',
            lua_error = 'pager',
            lua_print = 'msg',
            progress = 'msg',
            rpc_error = 'pager',
            quickfix = 'msg',
            search_cmd = 'cmd',
            search_count = 'cmd',
            shell_cmd = 'pager',
            shell_err = 'pager',
            shell_out = 'pager',
            shell_ret = 'msg',
            undo = 'msg',
            verbose = 'pager',
            wildlist = 'cmd',
            wmsg = 'msg',
            typed_cmd = 'msg',
        },
        cmd = {
            height = 0.5,
            relative = "editor",
        },
        dialog = {
            height = 0.5,
            relative = "editor",
        },
        msg = {
            height = 0.3,
            timeout = 1000,

        },
        pager = {
            height = 0.5,
        },
    },
})

-- Change Notification highlights colors
vim.api.nvim_create_autocmd("FileType", {
    pattern = "msg",
    callback = function()
        local ui2 = require("vim._core.ui2")
        local win = ui2.wins and ui2.wins.msg
        if win and vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_set_option_value(
                "winhighlight",
                "Normal:NormalFloat,FloatBorder:FloatBorder",
                { scope = "local", win = win }
            )
        end
    end,
})

-- if you want to change the Notification position
-- local ui2 = require("vim._core.ui2")
-- local msgs = require("vim._core.ui2.messages")
-- local orig_set_pos = msgs.set_pos
-- msgs.set_pos = function(tgt)
--     orig_set_pos(tgt)
--     if (tgt == "msg" or tgt == nil) and vim.api.nvim_win_is_valid(ui2.wins.msg) then
--         pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
--             relative = "editor",
--             anchor = "NW",
--             row = 1,
--             col = vim.o.columns - 5,
--             style = "minimal",
--             border = "rounded",
--         })
--     end
-- end
