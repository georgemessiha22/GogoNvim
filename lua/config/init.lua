_G.GogoVIM = require("util")
_G.GogoUI = require("ui")

local M = {}

M.settings_loader = require("config.loader")
M.did_init = false

function M.echo(msg)
  vim.cmd("redraw")
  vim.api.nvim_echo({ { msg, "Bold" } }, true, {})
end

function M.colorscheme()
  local lazy = require("lazy.core.util")
  lazy.track("colorscheme")
  vim.cmd.colorscheme(GogoUI.theme)
  lazy.track()
end

function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  M.Lazy()
  M.Plugins()
  M.Setup()
end

function M.Setup()
  local group = vim.api.nvim_create_augroup("GogoVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = M.Reload,
  })
  --}}}
  M.colorscheme()
end

function M.Reload()
  M.settings_loader.autocmds()

  vim.api.nvim_create_user_command("LazyHealth", function()
    vim.cmd([[Lazy! load all]])
    vim.cmd([[checkhealth]])
  end, { desc = "Load all plugins and run :checkhealth" })
  M.settings_loader.options(GogoUI)
  M.load_mapping()
end

function M.Lazy()
  -- Setup Lazy {{{
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

  if not vim.loop.fs_stat(lazypath) then
    M.echo("  Installing lazy.nvim")
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end

  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
  -- }}}
end

function M.Plugins()
  -- Load Plugins {{{
  M.settings_loader.leader()
  GogoVIM.lazy_file()
  require("lazy").setup(require("plugins"), {
    defaults = {
      lazy = false,
      -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
      -- have outdated releases, which may break your Neovim install.
      version = false, -- always use the latest git commit
      -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    checker = { enabled = false }, -- automatically check for plugin updates
    performance = {
      rtp = {
        -- disable some rtp plugins
        disabled_plugins = GogoUI.disabled_builtins,
      },
    },
  })
  -- }}}
end

---Load Mapping for special plugin name or general mappings, better call it after plugin config to with plugin name to load it's mapper.
---@param section any
function M.load_mapping(section)
  vim.schedule(function()
    local function set_section_map(values)
      if values.plugin then -- bypass plugins section
        return
      end
      values.plugin = nil -- this to garauntee all values are pair

      for mode, mode_values in pairs(values) do -- first layer is modes i, v, t, x
        for keybind, mapping_info in pairs(mode_values) do -- second layer is key = {command, description}
          local opts = vim.tbl_deep_extend("force", { desc = mapping_info[2], noremap = true }, mapping_info.opts or {})
          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local mappings = require("config.keymaps")

    if type(section) == "string" then -- if section declared only load this section
      mappings[section]["plugin"] = nil
      mappings = { mappings[section] }
    end

    for _, sec in pairs(mappings) do
      set_section_map(sec)
    end
  end)
end

return M
