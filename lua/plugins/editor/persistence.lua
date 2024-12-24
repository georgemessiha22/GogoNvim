-- {{
-- plugin = folke/persistence.nvim
-- keeping the current or last session
-- link = https://github.com/folke/persistence.nvim
-- }}
--
return {
  "folke/persistence.nvim",
  event = "BufReadPre",                             -- this will only start session saving when an actual file was opened
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",  -- directory where session files are saved
    -- minimum number of file buffers that need to be open to save
    -- Set to 0 to always save
    need = 0,
    branch = true, -- use git branch to save session
  }
}
