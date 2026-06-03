vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nvim.undotree")

-- Mini.nvim (file explorer, surround select, indentation)
GogoVIM.AddPack({
  src = GogoVIM.GH("echasnovski/mini.nvim"),
  name = "mini.nvim",
  version = "main",
  data = {
    config = function()
      require("mini.surround").setup()
      require("mini.ai").setup()
      require("mini.basics").setup()
      require("mini.files").setup({
        options = { use_as_default_explorer = true },
        windows = { preview = true, width_preview = 80 },
      })
      GogoVIM.load_mapping("minifiles")
      require("mini.icons").setup()
    end,
  },
})

-- Flash (jump fast)
GogoVIM.AddPack({
  src = GogoVIM.GH("folke/flash.nvim"),
  name = "falsh.nvim",
  data = {
    name = "flash",
    keys = {
      { "S",  mode = { "n", "x", "o" } },
      { "ts", mode = { "n", "x", "o" } },
      { "R",  mode = { "x", "o" } },
      { "r",  mode = "o" },
    },
    config = function()
      require("flash").setup()
      GogoVIM.load_mapping("flash")
    end,
  },
})

-- NUI UX library (Needed for Avante)
GogoVIM.AddPack({
  src = GogoVIM.GH("MunifTanjim/nui.nvim"),
  name = "nui.nvim",
  data = {
    name = "nui",
    skip_load = true,
  },
})

-- Trouble (showing lists as quickfixes)
GogoVIM.AddPack({
  src = GogoVIM.GH("folke/trouble.nvim"),
  name = "trouble.nvim",
  data = {
    cmd = { "Trouble", "TroubleToggle", "TroubleClose", "TroubleRefresh" },
    config = function()
      require("trouble").setup({ use_diagnostic_signs = true })
      GogoVIM.load_mapping("trouble")
    end,
  },
})

-- LuaLine (StatusLine)
GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-lualine/lualine.nvim"),
  name = "lualine.nvim",
  data = {
    name = "lualine",
    config = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end

      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          theme = "auto",
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "Avante", "AvanteSelectedFiles", "AvanteTodos" },
          },
          ignore_focus = {
            "dapui_watches",
            "dapui_breakpoints",
            "dapui_scopes",
            "dapui_console",
            "dapui_stacks",
            "dap-repl",
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },

          lualine_c = {
            {
              "diagnostics",
            },
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = { left = 1, right = 0 },
            },
            { GogoVIM.lualine.pretty_path() },
          },
          lualine_x = {
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function()
                return package.loaded["dap"] and require("dap").status() ~= ""
              end,
            },
            { "diff" },
          },
          lualine_y = {
            {
              function()
                return vim.ui.progress_status()
              end,
            },
            { "lsp_progress" },
            { "searchcount" },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = { "fzf" },
      }

      -- do not add trouble symbols if aerial is enabled
      -- And allow it to be overriden for some buffer types (see autocmds)
      if vim.g.trouble_lualine and GogoVIM.has("trouble.nvim") then
        local trouble = require("trouble")
        local symbols = trouble.statusline({
          mode = "symbols",
          groups = {},
          title = false,
          filter = { range = true },
          format = "{kind_icon}{symbol.name:Normal}",
          hl_group = "lualine_c_normal",
        })
        table.insert(opts.sections.lualine_c, {
          symbols and symbols.get,
          cond = function()
            return vim.b.trouble_lualine ~= false and symbols.has()
          end,
        })
      end

      require("lualine").setup(opts)
    end,
  },
})

-- FZF-lua
GogoVIM.AddPack({
  src = GogoVIM.GH("ibhagwan/fzf-lua"),
  name = "fzf-lua",
  data = {
    cmd = { "FzfLua", "TodoFzfLua" },
    config = function()
      -- require("fzf-lua").setup({"fzf-native"})
      -- require("fzf-lua").setup({"telescope", winopts={preview={default="bat"}}})
      require("fzf-lua").setup({
        { "telescope", "fzf-native", "hide" },
        -- { "telescope", "fzf-native" },
        winopts = { preview = { default = "bat" } },
        fzf_opts = { ["--cycle"] = true },
        files = {
          input_prompt = "Search files > ",
          fd_opts = [[--color=always --type f --type l --exclude .git --exclude .jj --exclude node_modules --exclude vendor]],
          rg_opts = [[--hidden --files --column --line-number --no-heading --sort-files --color=always --smart-case -g '!{.git,node_modules,vendor,.jj}/*']],
        },
        grep = {
          input_prompt = "RipGrep",
          rg_opts = [[--hidden --column --line-number --no-heading --sort-files --max-columns=4096 --color=always --smart-case -g '!{.git,node_modules,vendor,.jj}/*']],
          actions = {
            ["ctrl-g"] = false,
            ["ctrl-v"] = { require("fzf-lua").actions.grep_lgrep }, -- changing conflict with alacritty
          },
        },
        tags = {
          actions = {
            ["ctrl-g"] = false,
            ["ctrl-v"] = { require("fzf-lua").actions.grep_lgrep }, -- changing conflict with alacritty
          },
        },
        btags = {
          actions = {
            ["ctrl-g"] = false,
            ["ctrl-v"] = { require("fzf-lua").actions.grep_lgrep }, -- changing conflict with alacritty
          },
        },
        diagnostics = {
          signs = {
            -- enable fuzzy find with appended keywords
            ["Error"] = { text = GogoVIM.UI.icons.diagnostics.BoldError .. " [Error]", texthl = "DiagnosticError" },
            -- ["Warn"] = { text = GogoVIM.UI.icons.diagnostics.BoldWarning, texthl = "DiagnosticWarn" },
            -- ["Info"] = { text = GogoVIM.UI.icons.diagnostics.BoldHint, texthl = "DiagnosticInfo" },
            -- ["Hint"] = { text = GogoVIM.UI.icons.diagnostics.BoldHint, texthl = "DiagnosticHint" },
          },
        },
      }, true)

      -- require("fzf-lua").setup({"fzf-vim"})
      -- require("fzf-lua").setup({"telescope"})
      GogoVIM.load_mapping("fzflua")
      require("fzf-lua.providers.ui_select").register()
    end,
  },
})
