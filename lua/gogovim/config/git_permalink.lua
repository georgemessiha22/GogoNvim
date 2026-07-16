--[[
  File: git_permalink.lua
  Description: Build a GitHub/GitLab web permalink to the current line(s) on the
               current branch and copy it to the clipboard.
]]

local M = {}

--- Run a git command in `dir` and return trimmed stdout, or nil on failure.
---@param dir string
---@param args string[]
---@return string|nil
local function git(dir, args)
  local cmd = { "git", "-C", dir }
  vim.list_extend(cmd, args)

  local result = vim.system(cmd, { text = true }):wait()
  if result.code ~= 0 then
    return nil
  end

  local out = vim.trim(result.stdout or "")
  if out == "" then
    return nil
  end

  return out
end

--- Normalize a git remote URL into an `https://host/owner/repo` web base.
--- Handles SSH (`git@host:owner/repo.git`), `ssh://…`, and HTTPS forms and
--- strips a trailing `.git`.
---@param remote string
---@return string|nil base  e.g. "https://github.com/owner/repo"
---@return string|nil host  e.g. "github.com"
local function parse_remote(remote)
  remote = remote:gsub("%.git$", "")

  local host, path

  -- scp-like syntax: git@host:owner/repo
  host, path = remote:match("^[%w%-%._]+@([^:/]+):(.+)$")
  if not host then
    -- URL syntax: scheme://[user@]host/owner/repo
    local rest = remote:match("^%w+://(.+)$")
    if rest then
      rest = rest:gsub("^[^@/]+@", "") -- drop optional userinfo
      host, path = rest:match("^([^/]+)/(.+)$")
    end
  end

  if not host or not path then
    return nil, nil
  end

  return string.format("https://%s/%s", host, path), host
end

--- Determine the 1-based start/end line numbers for the current context.
--- Normal mode returns the cursor line twice. Visual mode returns the
--- selection bounds (read while the selection is still active).
---@return integer start_line
---@return integer end_line
local function line_range()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then -- \22 == <C-v>
    local a = vim.fn.getpos("v")[2]
    local b = vim.fn.getpos(".")[2]
    if a > b then
      a, b = b, a
    end
    return a, b
  end

  local cur = vim.api.nvim_win_get_cursor(0)[1]
  return cur, cur
end

--- Build the `#L…` fragment for the given host style and line range.
---@param is_gitlab boolean
---@param s integer
---@param e integer
---@return string
local function line_fragment(is_gitlab, s, e)
  if s == e then
    return string.format("#L%d", s)
  end
  if is_gitlab then
    return string.format("#L%d-%d", s, e)
  end
  return string.format("#L%d-L%d", s, e)
end

--- Build a permalink to the current line(s) on the current branch and copy it
--- to the `+` and `"` registers.
function M.copy_permalink()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Git permalink: buffer has no file", vim.log.levels.WARN)
    return
  end

  local dir = vim.fs.dirname(file)

  local branch = git(dir, { "rev-parse", "--abbrev-ref", "HEAD" })
  if not branch or branch == "HEAD" then
    vim.notify("Git permalink: could not resolve current branch (detached HEAD?)", vim.log.levels.WARN)
    return
  end

  local remote = git(dir, { "config", "--get", "remote.origin.url" })
  if not remote then
    vim.notify("Git permalink: no 'origin' remote found", vim.log.levels.WARN)
    return
  end

  local rel_path = git(dir, { "ls-files", "--full-name", "--", file })
  if not rel_path then
    vim.notify("Git permalink: file is not tracked by git", vim.log.levels.WARN)
    return
  end

  local base, host = parse_remote(remote)
  if not base then
    vim.notify("Git permalink: could not parse remote URL: " .. remote, vim.log.levels.WARN)
    return
  end

  local is_gitlab = host:lower():find("gitlab", 1, true) ~= nil
  local blob = is_gitlab and "/-/blob/" or "/blob/"

  local s, e = line_range()
  local url = base .. blob .. branch .. "/" .. rel_path .. line_fragment(is_gitlab, s, e)

  vim.fn.setreg("+", url)
  vim.fn.setreg('"', url)
  vim.notify("Copied: " .. url)
end

return M
