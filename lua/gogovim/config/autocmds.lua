-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd

vim.api.nvim_create_autocmd("LspProgress", {
  group = GogoVIM.augroup("lsp"),
  callback = function(ev)
    local value = ev.data.params.value
    vim.api.nvim_echo({ { value.message or "done" } }, false, {
      id = "lsp." .. ev.data.params.token,
      kind = "progress",
      source = "vim.lsp",
      title = value.title,
      status = value.kind ~= "end" and "running" or "success",
      percent = value.percentage,
    })
  end,
})

-- Start treesitter
autocmd({ "FileType" }, {
  pattern = { "go", "lua", "yaml", "yml", "python", "py", "gomod", "gosum", "gowork", "json", "json5", "jsonc", "kdl" },
  group = GogoVIM.augroup("lsp"),
  callback = function(ev)
    if vim.treesitter.highlighter.active[ev.buf] ~= nil then
      vim.notify_once("HighLight Activated")
    end
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = GogoVIM.augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last edit position
local exclude_ft = { gitcommit = true, gitrebase = true, help = true }
autocmd("BufReadPost", {
  group = GogoVIM.augroup("restore_cursor"),
  callback = function(event)
    if exclude_ft[vim.bo[event.buf].filetype] then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(event.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = GogoVIM.augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Close certain filetypes with q
-- Note: 'man' is excluded because Neovim has built-in q handling for man pages
autocmd("FileType", {
  group = GogoVIM.augroup("close_with_q"),
  pattern = {
    "checkhealth",
    "git",
    "gitsigns-blame",
    "help",
    "lspinfo",
    "notify",
    "qf",
    "startuptime",
    "confirm",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", function()
      local ok = pcall(vim.cmd.bdelete, { bang = true })
      if not ok then
        vim.cmd.quit()
      end
    end, { buffer = event.buf, silent = true, desc = "Close buffer" })
  end,
})

autocmd("LspAttach", {
  group = GogoVIM.augroup("lsp"),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

    -- Add keybindings
    GogoVIM.load_mapping("lspkeys")

    if client:supports_method("textDocument/implementation") then
      -- Create a keymap for vim.lsp.buf.implementation ...
      vim.keymap.set("i", "<C-i>", vim.lsp.buf.implementation, { desc = "trigger implementation" })
    end
    -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
    -- if client:supports_method('textDocument/completion') then
    --   -- Optional: trigger autocompletion on EVERY keypress. May be slow!
    --   -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
    --   -- client.server_capabilities.completionProvider.triggerCharacters = chars
    --   vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
    -- end
    -- Auto-format ("lint") on save.
    -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
    if
      not client:supports_method("textDocument/willSaveWaitUntil")
      and client:supports_method("textDocument/formatting")
    then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("GogoVIM.lsp", { clear = false }),
        buffer = ev.buf,
        callback = function()
          if GogoVIM.has("conform.nvim") then
            require("conform").format({ lsp_format = "first" })
            return
          end
          vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
        end,
      })
    end
  end,
})
