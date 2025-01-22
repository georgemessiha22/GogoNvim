--[[
  File: mappings.lua
  Description: Base keybindings for neovim
  Info: Use <zo> and <zc> to open and close foldings
]]
-- Copying the mappings way of NvChad. using maps for definitions and later load them using `vim.schedule`

-- n, v, i, t = mode names
-- for plugin add M.pluginname = {}

-- TODO: rewrite this file to use wk.register instead
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
    ["<C-z>"] = { function()
      vim.notify("HI")
    end, "SayHI" },

    ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },

    -- switch between windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-l>"] = { "<C-w>l", "Window right" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },

    -- Copy all
    -- ["<C-c>"] = { "<cmd> %y+ <CR>", "Copy whole file" },

    -- Save file
    ["<C-s>"] = { "<ESC> <CMD> write <CR>", "Save file" },

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

M.lspconfig = {
  plugin = true,

  -- See `<cmd> :help vim.lsp.*` for documentation on any of the below functions

  n = {
    ["gD"] = {
      function()
        vim.lsp.buf.declaration()
      end,
      "LSP declaration",
    },

    ["gd"] = {
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

    ["gi"] = {
      function()
        vim.lsp.buf.implementation()
      end,
      "LSP implementation",
    },

    ["<leader>ls"] = {
      function()
        vim.lsp.buf.signature_help()
      end,
      "LSP signature help",
    },

    ["<leader>D"] = {
      function()
        vim.lsp.buf.type_definition()
      end,
      "LSP definition type",
    },

    ["<leader>ra"] = {
      function()
        vim.lsp.buf.rename()
      end,
      "LSP rename",
    },

    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },

    ["gr"] = {
      function()
        vim.lsp.buf.references()
      end,
      "LSP references",
    },

    ["<leader>d"] = {
      function()
        vim.diagnostic.open_float({ border = "rounded" })
      end,
      "Floating diagnostic",
    },

    ["[d"] = {
      function()
        vim.diagnostic.jump({ diagnostic = vim.diagnostic.get_prev({ float = { border = "rounded" } }) })
      end,
      "Goto prev",
    },

    ["]d"] = {
      function()
        vim.diagnostic.jump({ diagnostic = vim.diagnostic.get_next({ float = { border = "rounded" } }) })
      end,
      "Goto next",
    },

    ["<leader>ql"] = {
      function()
        vim.diagnostic.setloclist()
      end,
      "Diagnostic setloclist",
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
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end,
      "List workspace folders",
    },

    -- formatting
    ["<leader>fm"] = {
      function()
        require("conform").format({
          timeout_ms=500,
          async= true,
          lsp_format="prefer",
        })
        -- vim.lsp.buf.format({ async = true })
      end,
      "LSP formatting",
      opts = { buffer = true },
    },

    ["<leader>e"] = {
      "<cmd>lua vim.diagnostic.open_float()<CR>",
      "Open Diagnostics",
      opts = { remap = false, silent = true },
    },
  },
}

M.telescope = {
  plugin = true,

  n = {
    -- LSP
    ["<leader>ldw"] = { "<cmd> Telescope lsp_dynamic_workspace_symbols<CR>", "Search for dynamic symbols" },
    ["<leader>tld"] = { "<cmd> Telescope lsp_definitions <CR>", "TeleScope defentions" },
    ["<leader>li"] = { "<cmd> Telescope lsp_implementations <CR>", "Lsp implementations" },
    ["<leader>lwd"] = { "<cmd> Telescope diagnostics <CR>", "Show Workspace Diagnostics" },
    ["<leader>lts"] = { "<cmd> Telescope treesitter <CR>", "Show treesitter" },
    ["<leader>qf"] = { "<cmd> Telescope quickfix <CR>", "Show quickfixes" },
    ["<leader>lci"] = { "<cmd> Telescope lsp_outgoing_calls <CR>", "Show LSP outgoing calls" },
    ["<leader>lco"] = { "<cmd> Telescope lsp_incoming_calls <CR>", "Show LSP incoming calls" },
    ["<leader>ltd"] = { "<cmd> Telescope lsp_type_defentions <CR>", "Show LSP type definition" },
    ["<leader>lr"] = { "<cmd> Telescope lsp_references <CR>", "Show LSP references" },

    -- find
    ["<leader>F"] = { "<cmd> Telescope find_files <CR>", "Find files", opts = { noremap = true } },
    ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
    ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
    ["<leader>fs"] = { "<cmd> Telescope grep_string <CR>", "Search keyword" },
    ["<leader>fb"] = { "<cmd> Telescope buffers sort_mru=true sort_lastused=true<CR>", "Find buffers" },
    ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
    ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
    ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },

    -- git
    ["<leader>gcm"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
    ["<leader>gt"] = { "<cmd> Telescope git_status <CR>", "Git status" },
    ["<leader>gba"] = { "<cmd> Telescope git_branches <CR>", "Show git branches" },
    ["<leader>gbc"] = { "<cmd> Telescope git_bcommits <CR>", "Show Blame commits" },
    ["<leader>gf"] = { "<cmd> Telescope git_files <CR>", "Search for a file in project" },

    -- pick a hidden term
    -- ["<leader>pt"]  = { "<cmd> Telescope terms <CR>", "Pick hidden term" },

    -- theme switcher
    ["<leader>th"] = { "<cmd> Telescope colorscheme <CR>", "Themes" },

    ["<leader>i"] = { "<cmd> Telescope jumplist <CR>", "Show jumplist (previous locations)" },
    ["<leader>ma"] = { "<cmd> Telescope marks <CR>", "telescope bookmarks" },

    ["<leader>ta"] = { "<cmd> Telescope <CR>", "Show all commands" },
    ["<leader>tc"] = { "<cmd>Telescope command_history<cr>", "Command History" },
    ["<leader>sa"] = { "<cmd>Telescope autocommands<cr>", "Auto Commands" },
    ["<leader>sk"] = { "<cmd>Telescope keymaps<cr>", "Key Maps" },
    ["<leader>sr"] = { "<cmd>Telescope resume<cr>", "Resume" },
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

M.neotree = {
  plugin = true,
  n = {
    ["<leader>nf"] = { "<cmd> Neotree toggle float <CR>", "Open/Close explroer float" },
    ["<leader>nl"] = { "<cmd> Neotree toggle left <CR>", "Open/Cloase explroer on left" },
    ["<leader>nr"] = { "<cmd> Neotree toggle right <CR>", "Open/Close explorer on right" },
    ["<leader>ng"] = { "<cmd> Neotree git_status <CR>", "Open Git Files menu" },
    ["<leader>nb"] = { "<cmd> Neotree git_status <CR>", "Open Buffers menu" },
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

M.cmp = {
  plugin = true,
  --	cmp keymaps are configured in `plugins/installer/cmp.lua`
}

M.iconpicker = {
  plugin = true,
  n = {
    ["<Leader><Leader>i"] = { "<CMD> IconPickerInsert<CR>", "Icon Picker" },
    ["<Leader><Leader>y"] = { "<CMD> IconPickerYank <CR>", "Icon Picker yank" },
  },

  -- i = {
  -- 	["<C-i>"] = { "<CMD> IconPickerInsert<CR>", "Icon Picker"},
  -- },
}

M.todo = {
  plugin = true,

  -- stylua: ignore
  n = {
    ["]t"] = { function() require("todo-comments").jump_next() end, "Next todo comment" },
    ["[t"] = { function() require("todo-comments").jump_prev() end, "Previous todo comment" },
    ["<leader>tt"] = { "<cmd>TodoTrouble<cr>", "Todo (Trouble)" },
    -- ["<leader>ttd"] = { "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme (Trouble)" },
    ["<leader>td"] = { "<cmd>TodoTelescope<cr>", "Todo" },
    -- ["<leader>tdf"] = { "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", "Todo/Fix/Fixme" },
  },
}

M.bufferline = {
  plugin = true,
  n = {
    ["<leader>bp"] = { "<Cmd>BufferLineTogglePin<CR>", "Toggle pin" },
    ["<leader>bP"] = { "<Cmd>BufferLineGroupClose ungrouped<CR>", "Delete non-pinned buffers" },
    ["<leader>bo"] = { "<Cmd>BufferLineCloseOthers<CR>", "Delete other buffers" },
    ["<leader>br"] = { "<Cmd>BufferLineCloseRight<CR>", "Delete buffers to the right" },
    ["<leader>bl"] = { "<Cmd>BufferLineCloseLeft<CR>", "Delete buffers to the left" },
    ["<S-h>"] = { "<cmd>BufferLineCyclePrev<cr>", "Prev buffer" },
    ["<S-l>"] = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
    ["[b"] = { "<cmd>BufferLineCyclePrev<cr>", "Prev buffer" },
    ["]b"] = { "<cmd>BufferLineCycleNext<cr>", "Next buffer" },
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

M.minisurround = {
  plugin = true,
  -- configured only in plugins.installer.minisurround
}

M.minifiles = {
  plugin = true,
  n = {
    ["<leader>nf"] = { "<cmd> lua MiniFiles.open() <CR>", "Open/Close explorer float" },
  },
}

return M
