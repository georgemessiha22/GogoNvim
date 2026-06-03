GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-neotest/nvim-nio"),
  name = "nvim-nio",
  data = {
    skip_load = true,
  },
})

local _dap_cmds = {
  "DapNew", "DapContinue", "DapToggleBreakpoint", "DapToggleRepl",
  "DapStepInto", "DapStepOver", "DapStepOut", "DapTerminate", "DapDisconnect",
  "DapShowLog", "DapRestartFrame",
  "GoBreakToggle", "GoDebug", "GoDbgStop",
}

local _dap_keys = {
  -- function-form mappings from keymaps.lua that don't exist until dap loads
  { "<leader>dc", mode = "n" },
  { "<leader>di", mode = "n" },
  { "<leader>do", mode = "n" },
  { "<leader>dl", mode = "n" },
  { "<leader>dq", mode = "n" },
  { "<leader>de", mode = "n" },
}

GogoVIM.AddPack({
  src = GogoVIM.GH("mfussenegger/nvim-dap"),
  name = "nvim-dap",
  data = {
    name = "dap",
    cmd = _dap_cmds,
    keys = _dap_keys,
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
    cmd = _dap_cmds,
    keys = _dap_keys,
    opts = {
      automatic_installation = true,
      handlers = {},
      ensure_installed = { "delve" },
    },
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("rcarriga/nvim-dap-ui"),
  name = "nvim-dap-ui",
  data = {
    name = "dapui",
    cmd = _dap_cmds,
    keys = _dap_keys,
    opts = {
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
    cmd = _dap_cmds,
    keys = _dap_keys,
    opts = {},
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("leoluz/nvim-dap-go"),
  name = "nvim-dap-go",
  data = {
    name = "dap-go",
    ft = "go",
    cmd = _dap_cmds,
    config = function()
      -- Force-load the rest of the DAP stack first; dap-go.setup() requires
      -- nvim-dap, nvim-dap-ui, etc. to already be on the runtimepath.
      vim.cmd.packadd("nvim-dap")
      vim.cmd.packadd("nvim-dap-ui")
      vim.cmd.packadd("nvim-dap-virtual-text")
      vim.cmd.packadd("mason-nvim-dap")
      require("dap-go").setup({})
    end,
  },
})
