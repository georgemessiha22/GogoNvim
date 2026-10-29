GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-neotest/nvim-nio"),
  name = "nvim-nio",
  data = {
    skip_load = true,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-lua/plenary.nvim"),
  name = "plenary.nvim",
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
  { "<leader>dm", mode = "n" },
}

local bind_dapui

local go_build_flags =
  "-tags=functional,integration,unit,functional_1,functional_2,functional_3,functional_4,functional_5,functional_6,functional_http,functional_grpc"

local test_lens_ns = vim.api.nvim_create_namespace("gogo_test_lens")

local function refresh_test_lens(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end
  local ft = vim.bo[buf].filetype
  if ft ~= "go" and ft ~= "python" then
    return
  end
  vim.api.nvim_buf_clear_namespace(buf, test_lens_ns, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    local is_test = (ft == "go" and line:match("^func Test[%w_]+%(") and line:find("testing.T", 1, true))
      or (ft == "python" and line:match("^%s*def%s+test_[%w_]+%("))
    if is_test then
      vim.api.nvim_buf_set_extmark(buf, test_lens_ns, i - 1, 0, {
        virt_text = { { "▶ Run", "DiagnosticInfo" } },
        virt_text_pos = "eol",
      })
    end
  end
end

vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
  group = GogoVIM.augroup("test_lens"),
  pattern = { "go", "python", "*.go", "*.py" },
  callback = function(ev)
    refresh_test_lens(ev.buf)
  end,
})

local function go_root(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  local start = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
  return vim.fs.root(start, { "go.mod", ".git" })
end

local function go_func_name()
  local node = vim.treesitter.get_node()
  while node do
    if node:type() == "function_declaration" or node:type() == "method_declaration" then
      local name = node:field("name")[1]
      if name then
        return vim.treesitter.get_node_text(name, 0)
      end
    end
    node = node:parent()
  end
end

local function go_test_for_func(dir, func)
  local paths = vim.fn.glob(dir .. "/*_test.go", false, true)
  local fallback
  for _, path in ipairs(paths) do
    for _, line in ipairs(vim.fn.readfile(path)) do
      local test = line:match("^func (Test[%w_]+)%(")
      if test then
        fallback = fallback or test
        if func and test:find(func, 1, true) then
          return test
        end
      end
    end
  end
  return fallback
end

local function debug_go_test()
  GogoVIM._ensure_loaded("nvim-dap-go")
  local dap = require("dap")
  local buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fn.fnamemodify(file, ":h")
  local root = go_root(buf)
  local dap_go = require("dap-go")
  if file:match("_test%.go$") and dap_go.debug_test({ cwd = root, buildFlags = go_build_flags }) then
    return
  end

  local test = go_test_for_func(dir, go_func_name())
  if not test then
    vim.notify("No Go test found for " .. file, vim.log.levels.WARN)
    return
  end
  dap.run({
    type = "go",
    request = "launch",
    mode = "test",
    name = test,
    program = dir,
    cwd = root,
    args = { "-test.run", "^" .. test .. "$" },
    buildFlags = go_build_flags,
    outputMode = "remote",
  })
end

local function python_project_root(buf)
  local name = vim.api.nvim_buf_get_name(buf or 0)
  local start = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
  return vim.fs.root(start, { "pyproject.toml", ".git" })
end

local function venv_python(root)
  if not root then
    return nil
  end
  local candidate = root .. "/.venv/bin/python"
  if vim.fn.executable(candidate) == 1 then
    return candidate
  end
end

local function python_test_opts()
  local root = python_project_root(0)
  local opts = {
    console = "internalConsole",
    config = function(config)
      local py = venv_python(root)
      if py then
        config.pythonPath = py
      end
      if root then
        config.cwd = root
      end
      config.console = "internalConsole"
      return config
    end,
  }
  if root and vim.fn.executable(root .. "/.venv/bin/pytest") == 1 then
    opts.test_runner = "pytest"
  end
  return opts
end

function GogoVIM.debug_nearest_test()
  bind_dapui()
  local ft = vim.bo.filetype
  if ft == "python" then
    GogoVIM._ensure_loaded("nvim-dap-python")
    require("dap-python").test_method(python_test_opts())
  elseif ft == "go" then
    debug_go_test()
  else
    vim.notify("No test debug runner for filetype " .. ft, vim.log.levels.WARN)
  end
end

local function project_of(buf)
  local root = GogoVIM.root.get({ buf = buf })
  if not root or root == "" then
    root = vim.fn.getcwd()
  end
  return GogoVIM.norm(root)
end

local function breakpoint_store(root)
  local dir = vim.fn.stdpath("data") .. "/dap-breakpoints"
  vim.fn.mkdir(dir, "p")
  return dir .. "/" .. vim.fn.sha256(root) .. ".json"
end

local function read_breakpoint_store(root)
  local f = io.open(breakpoint_store(root), "r")
  if not f then
    return {}
  end
  local raw = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok or type(decoded) ~= "table" or type(decoded.files) ~= "table" or decoded.files[1] then
    return {}
  end
  return decoded.files
end

local function write_breakpoint_store(root, files)
  local f = io.open(breakpoint_store(root), "w")
  if not f then
    return
  end
  f:write(vim.json.encode({ root = root, files = files }))
  f:close()
end

local function save_project_breakpoints(root)
  local stored = read_breakpoint_store(root)
  local bp = require("dap.breakpoints")
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and project_of(bufnr) == root then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" and vim.bo[bufnr].buftype == "" then
        local current = bp.get(bufnr)[bufnr] or {}
        if #current == 0 then
          stored[name] = nil
        else
          stored[name] = vim.tbl_map(function(item)
            return {
              line = item.line,
              condition = item.condition,
              hitCondition = item.hitCondition,
              logMessage = item.logMessage,
            }
          end, current)
        end
      end
    end
  end
  write_breakpoint_store(root, stored)
end

local function save_open_breakpoints()
  local seen = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_name(bufnr) ~= "" then
      local root = project_of(bufnr)
      if not seen[root] then
        seen[root] = true
        save_project_breakpoints(root)
      end
    end
  end
end

local function load_buffer_breakpoints(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or vim.bo[bufnr].buftype ~= "" then
    return
  end
  local saved = read_breakpoint_store(project_of(bufnr))[name]
  if type(saved) ~= "table" then
    return
  end
  local bp = require("dap.breakpoints")
  local have = {}
  for _, item in ipairs(bp.get(bufnr)[bufnr] or {}) do
    have[item.line] = true
  end
  local last = vim.api.nvim_buf_line_count(bufnr)
  for _, item in ipairs(saved) do
    if type(item.line) == "number" and item.line >= 1 and item.line <= last and not have[item.line] then
      bp.set({
        condition = item.condition,
        hit_condition = item.hitCondition,
        log_message = item.logMessage,
      }, bufnr, item.line)
    end
  end
end

local function persist_breakpoints()
  local bp = require("dap.breakpoints")
  if bp._gogo_persist then
    return
  end
  bp._gogo_persist = true

  local queued = false
  local function save_soon()
    if queued then
      return
    end
    queued = true
    vim.schedule(function()
      queued = false
      save_open_breakpoints()
    end)
  end

  for _, name in ipairs({ "toggle", "set", "clear" }) do
    local original = bp[name]
    bp[name] = function(...)
      local result = original(...)
      save_soon()
      return result
    end
  end

  local group = GogoVIM.augroup("dap_breakpoints")
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    group = group,
    callback = function(ev)
      load_buffer_breakpoints(ev.buf)
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = save_open_breakpoints,
  })

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      load_buffer_breakpoints(bufnr)
    end
  end
end

function bind_dapui()
  -- Pack name is nvim-dap-ui; the Lua module is dapui. nio must be packadded
  -- first because dapui.setup() requires it and that pack is skip_load.
  GogoVIM._ensure_loaded("nvim-nio")
  GogoVIM._ensure_loaded("nvim-dap-ui")
  local dap = require("dap")
  local dapui = require("dapui")
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

GogoVIM.AddPack({
  src = GogoVIM.GH("mfussenegger/nvim-dap"),
  name = "nvim-dap",
  data = {
    name = "dap",
    cmd = _dap_cmds,
    keys = _dap_keys,
    config = function()
      bind_dapui()
      persist_breakpoints()

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
  src = GogoVIM.GH("jay-babu/mason-nvim-dap.nvim"),
  name = "mason-nvim-dap",
  data = {
    cmd = _dap_cmds,
    keys = _dap_keys,
    opts = {
      automatic_installation = true,
      -- Mason's default Python config freezes pythonPath at load time and
      -- only offers "Launch file". nvim-dap-python owns the adapter and configs.
      handlers = {
        python = function() end,
      },
      ensure_installed = { "delve", "python" },
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
      GogoVIM._ensure_loaded("mason.nvim")
      GogoVIM._ensure_loaded("nvim-dap")
      GogoVIM._ensure_loaded("nvim-dap-ui")
      GogoVIM._ensure_loaded("nvim-dap-virtual-text")
      GogoVIM._ensure_loaded("mason-nvim-dap")
      require("dap-go").setup({
        delve = {
          path = vim.fn.stdpath("data") .. "/mason/bin/dlv",
          build_flags = go_build_flags,
        },
      })
      local dap = require("dap")
      local go_adapter = dap.adapters.go
      dap.adapters.go = function(callback, client_config)
        local function finish(adapter)
          adapter.executable = vim.tbl_extend("force", adapter.executable or {}, {
            cwd = go_root(0) or vim.fn.getcwd(),
          })
          callback(adapter)
        end
        if type(go_adapter) == "function" then
          go_adapter(finish, client_config)
        else
          finish(vim.deepcopy(go_adapter))
        end
      end
      for _, config in ipairs(dap.configurations.go or {}) do
        config.buildFlags = go_build_flags
        config.cwd = function()
          return go_root(0) or vim.fn.getcwd()
        end
      end
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("mfussenegger/nvim-dap-python"),
  name = "nvim-dap-python",
  data = {
    name = "dap-python",
    ft = "python",
    cmd = _dap_cmds,
    config = function()
      -- Run each pack's setup, not only packadd. packadd(nvim-dap) defines the
      -- Dap* commands and would skip mason-nvim-dap's ensure_installed.
      GogoVIM._ensure_loaded("mason.nvim")
      GogoVIM._ensure_loaded("nvim-dap")
      GogoVIM._ensure_loaded("nvim-dap-ui")
      GogoVIM._ensure_loaded("nvim-dap-virtual-text")
      GogoVIM._ensure_loaded("mason-nvim-dap")
      local python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      local dap_python = require("dap-python")
      dap_python.setup(python, { console = "internalConsole" })

      -- Mason's debugpy stays the adapter. The debuggee must be the project
      -- uv venv, not VIRTUAL_ENV or whatever cwd Neovim was started in.
      for _, config in ipairs(require("dap").configurations.python or {}) do
        config.console = "internalConsole"
        config.cwd = function()
          return python_project_root(0) or vim.fn.getcwd()
        end
        config.pythonPath = function()
          return venv_python(python_project_root(0))
        end
      end

      local function python_keys(buf)
        if vim.bo[buf].filetype ~= "python" then
          return
        end
        vim.keymap.set("n", "<leader>dC", function()
          bind_dapui()
          require("dap-python").test_class(python_test_opts())
        end, { buffer = buf, desc = "Debug Python class" })
        vim.keymap.set("v", "<leader>ds", function()
          bind_dapui()
          require("dap-python").debug_selection(python_test_opts())
        end, { buffer = buf, desc = "Debug Python selection" })
      end

      python_keys(vim.api.nvim_get_current_buf())
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function(ev)
          python_keys(ev.buf)
        end,
      })
    end,
  },
})

local _neotest_keys = {
  { "<leader>ns", mode = "n" },
  { "<leader>no", mode = "n" },
}

function GogoVIM.run_nearest_test()
  GogoVIM._ensure_loaded("nvim-dap")
  GogoVIM._ensure_loaded("nvim-dap-ui")
  GogoVIM._ensure_loaded("nvim-dap-go")
  GogoVIM._ensure_loaded("nvim-dap-python")
  bind_dapui()
  GogoVIM._ensure_loaded("neotest")
  require("neotest").run.run({ strategy = "dap" })
end

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-neotest/neotest"),
  name = "neotest",
  data = {
    ft = { "go", "python" },
    keys = _neotest_keys,
    config = function()
      GogoVIM._ensure_loaded("nvim-nio")
      GogoVIM._ensure_loaded("plenary.nvim")
      GogoVIM._ensure_loaded("neotest-python")
      GogoVIM._ensure_loaded("neotest-golang")
      local root = function()
        local name = vim.api.nvim_buf_get_name(0)
        local start = name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
        return vim.fs.root(start, { "pyproject.toml", "go.mod", ".git" }) or vim.fn.getcwd()
      end
      require("neotest").setup({
        output = { open_on_run = "short" },
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            python = function()
              local candidate = root() .. "/.venv/bin/python"
              if vim.fn.executable(candidate) == 1 then
                return candidate
              end
              return "python3"
            end,
          }),
          require("neotest-golang")({
            go_test_args = {
              "-v",
              "-count=1",
              go_build_flags,
            },
            go_list_args = { go_build_flags },
            dap_go_opts = {
              delve = {
                path = vim.fn.stdpath("data") .. "/mason/bin/dlv",
                build_flags = go_build_flags,
              },
            },
          }),
        },
      })
      GogoVIM.load_mapping("neotest")
    end,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("nvim-neotest/neotest-python"),
  name = "neotest-python",
  data = {
    skip_load = true,
  },
})

GogoVIM.AddPack({
  src = GogoVIM.GH("fredrikaverpil/neotest-golang"),
  name = "neotest-golang",
  data = {
    skip_load = true,
  },
})
