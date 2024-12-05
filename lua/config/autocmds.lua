-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup("GogoVIM_" .. name, { clear = true })
end

-- resize splits if window got resized
autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    GogoVIM.on_very_lazy(function()
      local current_tab = vim.fn.tabpagenr()
      vim.cmd("tabdo wincmd =")
      vim.cmd("tabnext " .. current_tab)
    end)
  end,
})

-- close some filetypes with <q>
autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "lspinfo",
    "notify",
    "qf",
    "query",
    "startuptime",
    "checkhealth",
  },
  callback = function(event)
    GogoVIM.on_very_lazy(function()
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end)
  end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    GogoVIM.on_very_lazy(function()
      vim.opt_local.conceallevel = 0
    end)
  end,
})

-- Fix tabexpand for yaml files
autocmd("FileType", {
  group = augroup("yaml"),
  pattern = { "yaml", "yml" },
  callback = function(_)
    GogoVIM.on_very_lazy(function()
      vim.opt_local.expandtab = true
    end)
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    GogoVIM.on_very_lazy(function()
      if event.match:match("^%w%w+:[\\/][\\/]") then
        return
      end
      local file = vim.uv.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end)
  end,
})
