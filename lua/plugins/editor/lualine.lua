--[[
  File: lualine.lua
  Description: Lualine for status line
  See: https://github.com/nvim-lualine/lualine.nvim
--]]

return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "arkav/lualine-lsp-progress",
  },
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  config = function(_, opts)
    -- PERF: we don't need this lualine require madness 🤷
    local lualine_require = require("lualine_require")
    lualine_require.require = require

    local icons = GogoUI.icons

    vim.o.laststatus = vim.g.lualine_laststatus

    -- Color for highlights
    -- local colors = {
    -- 	yellow = "#ECBE7B",
    -- 	cyan = "#008080",
    -- 	darkblue = "#081633",
    -- 	green = "#98be65",
    -- 	orange = "#FF8800",
    -- 	violet = "#a9a1e1",
    -- 	magenta = "#c678dd",
    -- 	blue = "#51afef",
    -- 	red = "#ec5f67",
    -- }
    require("lualine").setup({
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
          },
          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
          },
          -- {
          --   "lsp_progress",
          --   colors = {
          --     percentage = colors.cyan,
          --     title = colors.cyan,
          --     message = colors.cyan,
          --     spinner = colors.cyan,
          --     lsp_client_name = colors.magenta,
          --     use = true,
          --   },
          --   separators = {
          --     component = " ",
          --     progress = " | ",
          --     percentage = { pre = "", post = "%%" },
          --     title = { pre = "", post = ":" },
          --     lsp_client_name = { pre = "[", post = "]" },
          --     spinner = { pre = "", post = "" },
          --     message = { pre = "(", post = ")", commenced = "In Progress", completed = "Completed" },
          --   },
          --   display_components = {
          --     "lsp_client_name",
          --     "spinner",
          --     {
          --       --[[ "title", ]]
          --       "percentage",
          --       --[[ "message" ]]
          --     },
          --   },
          --   -- timer = { progress_enddelay = 500, spinner = 1000, lsp_client_name_enddelay = 1000 },
          --   spinner_symbols = { "🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘" },
          -- },

          -- {
          --   "progress",
          --   separator = "|| ",
          --   padding = { left = 1, right = 0 },
          -- },
        },
        lualine_x = { "selectioncount", "searchcount" },
        lualine_y = {
          -- "progress",
          "branch",
          "diff",
        },
        lualine_z = {
          -- "encoding",
          -- "fileformat",
          "filetype",
          "location",
        },
      },
      -- tabline = {
      --   lualine_a = { "windows" },
      --   lualine_c = { "buffers" },
      --   -- lualine_x = { { "tabs" } },
      --   lualine_z = {
      --     "diff", --[[ "windows" ]]
      --   },
      -- },
      -- winbar = { lualine_a = { "windows" } },
      options = {
        theme = GogoUI.lualine.theme,
        globalstatus = GogoUI.lualine.globalstatus,
        disabled_filetypes = {
          "dashboard",
        },
        component_separators = { left = "", right = GogoUI.lualine.separator_style },
        section_separators = { left = "", right = "" },
      },
      extensions = {
        -- "aerial",
        -- "chadtree",
        -- "ctrlspace",
        -- "fern",
        -- "fugitive",
        "fzf",
        "lazy",
        -- "man",
        "mason",
        -- "mundo",
        "neo-tree",
        -- "nerdtree",
        "nvim-dap-ui",
        -- "nvim-tree",
        -- "oil",
        -- "overseer",
        "quickfix",
        "symbols-outline",
        -- "toggleterm",
        "trouble",
      },
    })
  end,
}
