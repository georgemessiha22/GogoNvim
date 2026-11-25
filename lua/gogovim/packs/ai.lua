-- Markdown preview for notes outside the vault used to be render-markdown.nvim.
-- obsidian.nvim only renders markdown inside the configured workspace, and only
-- after setup(). Do not filetype-lazy this pack: the :Obsidian command is
-- created by the plugin file before setup, and its UI hooks BufEnter, which
-- has already fired if the pack loads on FileType.
GogoVIM.AddPack({
  src = GogoVIM.GH("MeanderingProgrammer/render-markdown.nvim"),
  data = {
    ft = { "markdown", "Avante", "codecompanion" },
    config = function()
      require("render-markdown").setup({
        file_types = { "markdown", "Avante", "codecompanion" },
        completions = { lsp = { enabled = true } },
      })
    end,
  },
})

-- GogoVIM.AddPack({
--   src = GogoVIM.GH("OXY2DEV/markview.nvim"),
--   name = "markview",
--   data = {
--     ft = { "markdown", "Avante", "codecompanion" },
--     config = function()
--       ---@module "markview"
--       ---@type markview.config
--       local opts = {
--         markdown = {
--           enable = true,
--           headings = {
--             heading_1 = { icon_hl = "@markup.link", icon = "[%d] " },
--             heading_2 = { icon_hl = "@markup.link", icon = "[%d.%d] " },
--             heading_3 = { icon_hl = "@markup.link", icon = "[%d.%d.%d] " },
--             heading_4 = { icon_hl = "@markup.link", icon = "[%d.%d.%d.%d] " },
--             heading_5 = { icon_hl = "@markup.link", icon = "[%d.%d.%d.%d.%d] " },
--           },
--           tables = {
--             enable = true,
--             strict = true,
--             wrap = false,
--
--             block_decorator = true,
--             use_virt_lines = true,
--
--             parts = {
--               top = { "╭", "─", "╮", "┬" },
--               header = { "│", "│", "│" },
--               separator = { "├", "─", "┤", "┼" },
--               row = { "│", "│", "│" },
--               bottom = { "╰", "─", "╯", "┴" },
--
--               overlap = { "┝", "━", "┥", "┿" },
--
--               align_left = "╼",
--               align_right = "╾",
--               align_center = { "╴", "╶" },
--             },
--
--             hl = {
--               top = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
--               header = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
--               separator = { "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader", "MarkviewTableHeader" },
--               row = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
--               bottom = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
--
--               overlap = { "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder", "MarkviewTableBorder" },
--
--               align_left = "MarkviewTableAlignLeft",
--               align_right = "MarkviewTableAlignRight",
--               align_center = { "MarkviewTableAlignCenter", "MarkviewTableAlignCenter" },
--             },
--           },
--         },
--         markdown_inline = {
--           enable = true,
--         },
--         preview = {
--           enable = true,
--         },
--       }
--       require("markview").setup(opts)
--     end,
--   },
-- })

GogoVIM.AddPack({
  src = GogoVIM.GH("obsidian-nvim/obsidian.nvim"),
  name = "obsidian.nvim",
  data = {
    config = function()
      ---@module "obsidian"
      ---@type obsidian.config
      local opt = {
        picker = { name = "fzf-lua" },
        legacy_commands = false,
        workspaces = {
          {
            name = "work",
            path = "~/HungerWorkStation/self",
          },
        },
        link = {
          auto_update = true,
        },
        -- manual: do not probe the Obsidian CLI on startup. :Obsidian sync runs the wizard.
        sync = {
          enabled = true,
        },

        daily_notes = {
          enabled = true,
          folder = "daily",
          date_format = "YYYY-MM-DD",
          default_tags = { "journal", "daily" },
        },
        ui = {
          enable = false,
        },
      }

      require("obsidian").setup(opt)
    end,
  },
})
