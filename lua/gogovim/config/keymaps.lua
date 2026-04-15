--[[
  File: keymaps.lua
  Description: Base keybindings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]
-- Copying the mappings way of NvChad. using maps for definitions and later load them using `vim.schedule`
-- the idea behind this file is to disable keymaps distrbution in multi file and not knowing who repeating this keymap.

-- n, v, i, t = mode names
-- for plugin add M.pluginname = {}

local M = {}

M.general = {
  i = {
    -- go to  beginning and end
    ["<C-b>"] = { "<ESC>^i", "Beginning of line" },
    ["<C-e>"] = { "<End>", "End of line" },

    -- navigate within insert mode
    ["<C-h>"] = { "<Left>", "Move left" },
    ["<C-l>"] = { "<Right>", "Move right" },
    ["<C-j>"] = { "<Down>", "Move down" },
    ["<C-k>"] = { "<Up>", "Move up" },

    -- Save file
    -- ["<C-s>"] = { "<ESC> <CMD> write <CR>", "Save file" },
  },

  n = {
    ["<C-z>"] = {
      function()
        vim.notify("HI")
      end,
      "SayHI",
    },

    ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },

    -- Copy all
    -- ["<C-c>"] = { "<cmd> %y+ <CR>", "Copy whole file" },

    -- Save file
    -- ["<C-s>"] = { "<ESC> <CMD> write <CR>", "Save file" },

    -- line numbers
    ["<Leader>ln"] = { "<cmd> set nu! <CR>", "Toggle line number" },
    ["<Leader>rn"] = { "<cmd> set rnu! <CR>", "Toggle relative number" },

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- empty mode is same as using <cmd> :map
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
    ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },

    -- new buffer
    ["<Leader>bn"] = { "<cmd> enew <CR>", "New buffer" },
    ["<Leader>bc"] = { "<cmd>bd<CR>", "Close buffer" },

    -- split screen
    ["<Leader>sv"] = { "<cmd>vsplit<CR>", "Split screen vertically" },
    ["<Leader>sh"] = { "<CMD>split h<CR>", "Split screen horizontally" },

    -- tab movements
    ["<leader>tn"] = { "<cmd>bNext<CR>", "Move to next tab" },
    ["<leader>tp"] = { "<cmd>bprevious<CR>", "Move to previous tab" },
  },

  t = {
    ["<C-x>"] = { vim.api.nvim_replace_termcodes("<C-\\><C-N>", true, true, true), "Escape terminal mode" },
  },
}

M.lspkeys = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "LSP declaration",
    },
    ["grd"] = {
      function()
        vim.lsp.buf.definition()
      end,
      "LSP definition",
    },
    ["K"] = {
      function()
        vim.lsp.buf.hover()
      end,
      "LSP hover",
    },
    ["<leader>wa"] = {
      function()
        vim.lsp.buf.add_workspace_folder()
      end,
      "Add workspace folder",
    },
    ["<leader>wr"] = {
      function()
        vim.lsp.buf.remove_workspace_folder()
      end,
      "Remove workspace folder",
    },
    ["<leader>wl"] = {
      function()
        vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "List workspace folders",
    },
    ["<leader>e"] = {
      function()
        vim.diagnostic.open_float({ border = "rounded" })
      end,
      "Open Diagnostics",
      opts = { remap = false, silent = true },
    },
  },
}

M.conform = {
  plugin = true,
  n = {
    -- formatting
    ["<leader>lwf"] = {
      function()
        require("conform").format({
          timeout_ms = 500,
          async = true,
          lsp_format = "first",
        })
        -- vim.lsp.buf.format({ async = true })
      end,
      "LSP formatting",
      opts = { buffer = true },
    },
  },
}

M.fzflua = {
  plugin = true,

  n = {
    -- LSP
    ["<leader>ldw"] = { "<cmd> FzfLua lsp_live_workspace_symbols <CR>", "Search for dynamic symbols" },
    ["<leader>tld"] = { "<cmd> FzfLua lsp_definitions <CR>", "List defentions" },
    ["<leader>li"] = { "<cmd> FzfLua lsp_implementations <CR>", "Lsp implementations" },
    ["<leader>lwd"] = { "<cmd> FzfLua lsp_workspace_diagnostics <CR>", "Show Workspace Diagnostics" },
    -- ["<leader>lts"] = { "<cmd> FzfLua treesitter <CR>", "Show treesitter" },
    ["<leader>qf"] = { "<cmd> FzfLua quickfix <CR>", "Show quickfixes" },
    ["<leader>lca"] = { "<cmd> FzfLua lsp_code_actions <CR>", "Show code actions" },
    ["<leader>lci"] = { "<cmd> FzfLua lsp_outgoing_calls <CR>", "Show LSP outgoing calls" },
    ["<leader>lco"] = { "<cmd> FzfLua lsp_incoming_calls <CR>", "Show LSP incoming calls" },
    ["<leader>ltd"] = { "<cmd> FzfLua lsp_typedefs <CR>", "Show LSP type definition" },
    ["<leader>lr"] = { "<cmd> FzfLua lsp_references <CR>", "Show LSP references" },
    ["<leader>lf"] = { "<cmd> FzfLua lsp_finder <CR>", "All LSP locations, combined view" },

    -- find
    ["<leader>F"] = { "<cmd> FzfLua files <CR>", "Find files", opts = { noremap = true } },
    ["<leader>fa"] = { "<cmd> FzfLua files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    ["<leader>fw"] = { "<cmd> FzfLua live_grep <CR>", "Live grep" },
    -- ["<leader>fs"] = { "<cmd> FzfLua grep_string <CR>", "Search keyword" },
    ["<leader>fb"] = { "<cmd> FzfLua buffers <CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> FzfLua help_tags <CR>", "Help page" },
    ["<leader>fo"] = { "<cmd> FzfLua oldfiles <CR>", "Find oldfiles" },
    ["<leader>fz"] = { "<cmd> FzfLua grep <CR>", "Find in current buffer" },

    -- git
    ["<leader>gcm"] = { "<cmd> FzfLua git_commits <CR>", "Git commits" },
    ["<leader>gs"] = { "<cmd> FzfLua git_status <CR>", "Git status" },
    ["<leader>gba"] = { "<cmd> FzfLua git_branches <CR>", "Show git branches" },
    ["<leader>gbc"] = { "<cmd> FzfLua git_bcommits <CR>", "Show Blame commits" },
    ["<leader>gf"] = { "<cmd> FzfLua git_files <CR>", "Search for a file in project" },

    -- pick a hidden term
    -- ["<leader>pt"]  = { "<cmd> FzfLua terms <CR>", "Pick hidden term" },

    -- theme switcher
    ["<leader>th"] = { "<cmd> FzfLua colorschemes <CR>", "Themes" },

    ["<leader>i"] = { "<cmd> FzfLua jumps <CR>", "Show jumplist (previous locations)" },

    ["<leader>ta"] = { "<cmd> FzfLua <CR>", "Show all commands" },
    ["<leader>tc"] = { "<cmd>FzfLua command_history<cr>", "Command History" },
    ["<leader>sa"] = { "<cmd>FzfLua autocmds<cr>", "Auto Commands" },
    ["<leader>sk"] = { "<cmd>FzfLua keymaps<cr>", "Key Maps" },
    ["<leader>sr"] = { "<cmd>FzfLua resume<cr>", "Resume" },
  },
}

M.trouble = {
  plugin = true,
  n = {
    ["<leader>xx"] = { "<CMD>Trouble toggle<CR>", "Show Trouble" },
    ["<leader>xw"] = { "<CMD>Trouble diagnostics toggle<CR>", "Show trouble diagnostics" },
    ["<leader>xd"] = { "<CMD>Trouble diagnostics toggle filter.buf=0<CR>", "Show trouble document_diagnostics" },
    ["<leader>xq"] = { "<CMD>Trouble quickfix<CR>", "Show trouble quickfixes" },
    ["<leader>xt"] = { "<CMD>Trouble todo<CR>", "Show trouble todo list" },
    ["<leader>xs"] = { "<CMD>Trouble  symbols toggle focus=true<CR>", "show trouble symbol" },
    ["<leader>xl"] = {
      "<CMD>Trouble lsp toggle focus=false win.position=right<CR>",
      "show trouble LSP Definitions / references / ...",
    },
    ["[q"] = {
      function()
        if require("trouble").is_open() then
          require("trouble").previous({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      "Previous trouble/quickfix item",
    },
    ["]q"] = {
      function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      "Next trouble/quickfix item",
    },
  },
}

M.comment = {
  plugin = true,

  -- toggle comment in both modes
  n = {
    ["<C-_>"] = {
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      "Toggle comment line wise",
    },
  },

  v = {
    ["<C-_>"] = {
      function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), "nx", true)

        require("Comment.api").locked("toggle.blockwise")(vim.fn.visualmode())
      end,
      "Toggle comment blockwise",
    },
  },
}

M.whichkey = {
  plugin = true,

  n = {
    ["<leader>wK"] = {
      function()
        vim.cmd("WhichKey")
      end,
      "Which-key all keymaps",
    },
    ["<leader>wk"] = {
      function()
        local input = vim.fn.input("WhichKey: ")
        vim.cmd("WhichKey " .. input)
      end,
      "Which-key query lookup",
    },
  },
}

M.todo = {
  plugin = true,

    -- stylua: ignore
    n = {
        ["]t"] = { function() require("todo-comments").jump_next() end, "Next todo comment" },
        ["[t"] = { function() require("todo-comments").jump_prev() end, "Previous todo comment" },
        ["<leader>tt"] = { "<cmd>TodoTrouble<cr>", "Todo (Trouble)" },
        -- ["<leader>ttd"] = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme (Trouble)" },
        -- ["<leader>td"] = { "<cmd>TodoTelescope<cr>", "Todo (Telescope)" },
        ["<leader>tf"] = { "<cmd>TodoFzfLua<cr>", "Todo (FzfLua)" }
        -- ["<leader>tdf"] = { "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme" },
    },
}

M.flash = {
  plugin = true,
  x = {
    ["S"] = { '<cmd>lua require("flash").jump()<CR>', "Flash" },
    ["ts"] = { '<cmd>lua require("flash").treesitter()<CR>', "Flash Treesitter" },
    ["R"] = { '<Cmd>lua require("flash").treesitter_search()<CR>', "Remote flash" },
  },
  o = {
    ["S"] = { '<cmd>lua require("flash").jump()<CR>', "Flash" },
    ["ts"] = { '<cmd>lua require("flash").treesitter()<CR>', "Flash Treesitter" },
    ["r"] = { '<Cmd>lua require("flash").remote()<CR>', "Remote flash" },
    ["R"] = { '<Cmd>lua require("flash").treesitter_search()<CR>', "Remote flash" },
  },
  n = {
    ["S"] = { '<cmd>lua require("flash").jump()<CR>', "Flash" },
    ["ts"] = { '<cmd>lua require("flash").treesitter()<CR>', "Flash Treesitter" },
  },
  c = {
    ["<c-s>"] = { '<cmd> lua require("flash").toggle()<CR>', "Toggle Flash Search" },
  },
}

M.minifiles = {
  plugin = true,
  n = {
    ["<leader>nf"] = {
      "<cmd> lua MiniFiles.open(vim.api.nvim_buf_get_name(0), true) <CR>",
      "Open/Close explorer float",
    },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>dn"] = { "<cmd> DapNew <CR>", "Toggle Breakpoint" },
    ["<leader>dt"] = { "<cmd> DapToggleBreakpoint <CR>", "Toggle Breakpoint" },
    ["<leader>dg"] = { "<cmd> GoBreakToggle <CR>", "Toggle Golang Breakpoint" },

    ["<leader>dc"] = { '<cmd> lua require("dap").continue() <CR>', "Debugger continue" },

    ["<leader>di"] = { '<cmd> lua require("dap").step_into() <CR>', "DBG step into" },

    ["<leader>do"] = { '<cmd> lua require("dap").step_over() <CR>', "DBG step over" },
    ["<leader>dr"] = { "<cmd> DapToggleRepl <CR>", "Repl open" },
    ["<leader>dl"] = { '<cmd> lua require("dap").run_last() <CR>', "Run last" },
    ["<leader>dq"] = {
      function()
        require("dap").terminate()
        require("dapui").close()
        require("nvim-dap-virtual-text").toggle()
      end,
      "DBG quite",
    },
    ["<leader>db"] = { "<cmd> FzfLua dap_breakpoints <CR>", "DBG list breakpoints" },

    ["<leader>de"] = {
      '<cmd> lua require("dap").set_exception_breakpoints({ "all" }) <CR>',
      "Set Exception Breakpoints",
    },
  },
}

return M
