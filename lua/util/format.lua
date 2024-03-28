---@class util.format
local M = {}

function M.formatexpr()
  if GogoVIM.has("conform.nvim") then
    return require("conform").formatexpr()
  end
  return vim.lsp.formatexpr({ timeout_ms = 3000 })
end

return M
