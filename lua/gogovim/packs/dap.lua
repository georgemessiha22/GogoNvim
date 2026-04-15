GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-neotest/nvim-nio"),
  name = "nvim-nio",
  data = {
    skip_load = true,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("mfussenegger/nvim-dap"),
  name = "nvim-dap",
  data = {
    name = "dap",
    config = function()
      vim.schedule_wrap(function()
        if GogoVIM.has("nvim-dap-ui") then
          local dap = require("dap")
          local dapui = require("nvim-dap-ui")

          dap.listeners.after.event_initialized["dapui_config"] = dapui.open
          dap.listeners.before.event_terminated["dapui_config"] = dapui.close
          dap.listeners.before.event_exited["dapui_config"] = dapui.close
        end
      end)

      -- Change breakpoint icons
      vim.api.nvim_set_hl(0, "DapBreak", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapStop", { fg = "#ffcc00" })
      local breakpoint_icons = {
        Breakpoint = "●",
        BreakpointCondition = "⊜",
        BreakpointRejected = "⊘",
        LogPoint = "◆",
        Stopped = "⭔",
      }
      for type, icon in pairs(breakpoint_icons) do
        local tp = "Dap" .. type
        local hl = (type == "Stopped") and "DapStop" or "DapBreak"
        vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
      end

      GogoVIM.load_mapping("dap")
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("jay-babu/mason-nvim-dap.nvim"),
  name = "mason-nvim-dap",
  data = {
    opts = {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        "delve",
      },
    },
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("rcarriga/nvim-dap-ui"),
  name = "nvim-dap-ui",
  data = {
    name = "dapui",
    opts = {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    },
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("theHamsta/nvim-dap-virtual-text"),
  name = "nvim-dap-virtual-text",
  data = {
    opts = {},
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("leoluz/nvim-dap-go"),
  name = "nvim-dap-go",
  data = {
    name = "dap-go",
    opts = {},
  },
})
