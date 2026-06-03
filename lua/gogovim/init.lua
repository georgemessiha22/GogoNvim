-- GogoVIM is some help functions i created or copied for my custom Neovim configs.

local M = {
  did_init = false,
  lualine = require("gogovim.lualine_extras"),
  root = require("gogovim.root"),
  UI = require("gogovim.ui.init"),
  mappings = require("gogovim.config.keymaps"),
}

_G.GogoVIM = M

function M.setup()
  if M.did_init then
    return
  end

  -- Load leader keys {{{
  vim.g.mapleader = " "
  vim.g.maplocalleader = GogoVIM.UI.localleader
  -- }}}

  M.InstallPacks()

  -- Load colorscheme
  -- vim.cmd.colorscheme(GogoVIM.UI.theme)

  GogoVIM.load_mapping()

  require("gogovim.config.options")
  require("gogovim.config.lsp")
  require("gogovim.config.autocmds")
  M.did_init = true
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
          local opts = vim.tbl_deep_extend("force", { desc = mapping_info[2], remap = false }, mapping_info.opts or {})
          vim.keymap.set(mode, keybind, mapping_info[1], opts)
        end
      end
    end

    local partially_mappings = M.mappings

    if type(section) == "string" then -- if section declared only load this section
      partially_mappings[section]["plugin"] = nil
      partially_mappings = { partially_mappings[section] }
    end

    for _, sec in pairs(partially_mappings) do
      set_section_map(sec)
    end
  end)
end

--- has Checks if pack is being installed.
function M.has(key)
  local active_packs = vim
    .iter(vim.pack.get())
    :filter(function(x)
      return x.active
    end)
    :filter(function(x)
      return x.spec.name == key
    end)
    :map(function(x)
      return x.spec.name
    end)
    :totable()

  return #active_packs > 0
end

--- GH generates github url
function M.GH(repo_name)
  return "https://github.com/" .. repo_name
end

--- @class GogoVIM.packs.pack.data
--- @field name? string
--- @field confirm? boolean
--- @field skip_load? boolean
--- @field build? table{string}
--- @field config? function()
--- @field opts? any
--- @field cmd? string|string[]   -- lazy: load on first invocation of any of these user commands
--- @field event? string|string[] -- lazy: load on first occurrence of any of these autocmd events
--- @field ft? string|string[]    -- lazy: load on FileType matching any of these
--- @field keys? table            -- lazy: load on first press; entries: { lhs, mode = "n"|table }
---
--- @class GogoVIM.packs.pack
--- @field src string
--- @field name? string
--- @field version? string|vim.VersionRange
--- @field data GogoVIM.packs.pack.data

--- @alias GogoVIM.packs.pack_data {spec: GogoVIM.packs.pack}
---
M.packs = {}

-- Lazy-load infrastructure ----------------------------------------------------
-- Shared cmd/event/ft/key triggers can fire loaders for multiple packs.
local _cmd_loaders = {}   -- cmd  -> { loader, ... }
local _ft_loaders = {}    -- ft   -> { loader, ... }
local _key_loaders = {}   -- key  -> { mode -> { loader, ... } }

local function _as_list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

local function _do_load(pack_name, data)
  -- Idempotent loader: packadd + run config/setup once.
  if data._loaded then return end
  data._loaded = true

  vim.cmd.packadd({ vim.fn.escape(pack_name, " ") })

  if data.skip_load then return end

  if data.config ~= nil then
    data.config()
    return
  end

  local modname = data.name or pack_name
  if modname ~= nil then
    require(modname).setup(data.opts or {})
  end
end

local function _register_cmd(cmd_name, loader)
  if _cmd_loaders[cmd_name] == nil then
    _cmd_loaders[cmd_name] = {}
    vim.api.nvim_create_user_command(cmd_name, function(opts)
      local loaders = _cmd_loaders[cmd_name] or {}
      _cmd_loaders[cmd_name] = nil
      pcall(vim.api.nvim_del_user_command, cmd_name)
      for _, l in ipairs(loaders) do
        local ok, err = pcall(l)
        if not ok then
          vim.notify("lazy load failed for " .. cmd_name .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
      local args = opts.args or ""
      local bang = opts.bang and "!" or ""
      local range = ""
      if opts.range == 1 then
        range = tostring(opts.line1)
      elseif opts.range == 2 then
        range = opts.line1 .. "," .. opts.line2
      end
      vim.cmd(string.format("%s%s%s %s", range, cmd_name, bang, args))
    end, { nargs = "*", bang = true, range = true, complete = "file" })
  end
  table.insert(_cmd_loaders[cmd_name], loader)
end

local function _register_event(events, loader)
  vim.api.nvim_create_autocmd(events, {
    group = M.augroup("lazy_event"),
    once = true,
    callback = function()
      local ok, err = pcall(loader)
      if not ok then
        vim.notify("lazy load (event) failed: " .. tostring(err), vim.log.levels.ERROR)
      end
    end,
  })
end

local function _register_ft(fts, loader)
  for _, ft in ipairs(fts) do
    if _ft_loaders[ft] == nil then
      _ft_loaders[ft] = {}
      vim.api.nvim_create_autocmd("FileType", {
        group = M.augroup("lazy_ft"),
        pattern = ft,
        once = true,
        callback = function()
          local loaders = _ft_loaders[ft] or {}
          _ft_loaders[ft] = nil
          for _, l in ipairs(loaders) do
            local ok, err = pcall(l)
            if not ok then
              vim.notify("lazy load (ft) failed: " .. tostring(err), vim.log.levels.ERROR)
            end
          end
        end,
      })
    end
    table.insert(_ft_loaders[ft], loader)
  end
end

local function _register_keys(keys, loader, pack_name)
  for _, key in ipairs(keys) do
    local lhs = key[1] or key.lhs
    local modes = _as_list(key.mode or "n")
    for _, mode in ipairs(modes) do
      local registry_key = mode .. ":" .. lhs
      if _key_loaders[registry_key] == nil then
        _key_loaders[registry_key] = {}
        vim.keymap.set(mode, lhs, function()
          local loaders = _key_loaders[registry_key] or {}
          _key_loaders[registry_key] = nil
          pcall(vim.keymap.del, mode, lhs)
          for _, l in ipairs(loaders) do
            local ok, err = pcall(l)
            if not ok then
              vim.notify("lazy load (key) failed: " .. tostring(err), vim.log.levels.ERROR)
            end
          end
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, true, true), "m", false)
        end, { desc = "lazy load " .. pack_name })
      end
      table.insert(_key_loaders[registry_key], loader)
    end
  end
end

--- Register lazy triggers for a pack. Returns true if any lazy trigger was set.
local function _register_lazy(pack_name, data)
  local has_lazy = data.cmd or data.event or data.ft or data.keys
  if not has_lazy then return false end

  local loader = function() _do_load(pack_name, data) end

  for _, c in ipairs(_as_list(data.cmd)) do _register_cmd(c, loader) end
  if data.event then _register_event(_as_list(data.event), loader) end
  if data.ft then _register_ft(_as_list(data.ft), loader) end
  if data.keys then _register_keys(data.keys, loader, pack_name) end

  return true
end

M._do_load = _do_load
M._register_lazy = _register_lazy
-- End lazy-load infrastructure -----------------------------------------------

--- AddPack add the configuration of pack to be installed later when calling InstallPacks
--- @param pack GogoVIM.packs.pack
function M.AddPack(pack)
  table.insert(M.packs, pack)
end

--- Appending `GogoVIM` to group names
--- @param name string Group name
--- @param opts? vim.api.keyset.create_augroup Optional parameters:
--- - clear (`boolean?`, default: false) Clear existing commands in the group `autocmd-groups`.
--- @return integer # Group id.
function M.augroup(name, opts)
  name = "GogoVIM." .. name
  return vim.api.nvim_create_augroup(name, opts or { clear = false })
end

--- Install all configured packs in gogovim.packs
function M.InstallPacks()
  -- vim-matchup globals must be set before the plugin loads
  vim.g.matchup_matchparen_offscreen = { method = "popup" }
  vim.g.matchup_matchparen_deferred = 1
  vim.g.matchup_treesitter_stopline = 500
  vim.g.matchup_treesitter_include_match_words = false
  vim.g.matchup_treesitter_enable_quotes = true

  -- Build hooks (must be registered before vim.pack.add)
  vim.api.nvim_create_autocmd("PackChanged", {
    group = M.augroup("pack_changed"),
    callback = function(ev)
      if ev.data.kind == "delete" then
        return
      end

      local name = ev.data.spec.name
      if name == "nvim-treesitter" then
        vim.notify("Updating TreeSitter")
        pcall(function()
          vim.cmd("TSUpdate")
        end)
      elseif name == "mason.nvim" then
        vim.notify("Updating Mason")
        pcall(function()
          vim.cmd("MasonUpdate")
        end)
      elseif name == "go.nvim" then
        vim.notify("Updating go binaries")
        pcall(function()
          require("go.install").update_all_sync()
        end)
      end

      local data = ev.data.spec.data

      if data == nil then
        return
      end

      if data.build ~= nil then
        if type(data.build) == "table" then
          vim.notify("Building " .. name .. " Started", vim.log.levels.INFO)

          local obj = vim.system(data.build, { cwd = ev.data.path }):wait()
          if obj.code == 0 then
            vim.notify("Building " .. name .. " done", vim.log.levels.INFO)
          else
            vim.notify("Building " .. name .. " failed", vim.log.levels.ERROR)
          end
        end
      end
    end,
  })

  -- Register packs to be installed
  require("gogovim.packs.editor")
  require("gogovim.packs.code")
  require("gogovim.packs.lsp")
  require("gogovim.packs.dap")
  require("gogovim.packs.ai")

  vim.pack.add(M.packs, {
    confirm = false,
    --- @param pack_data GogoVIM.packs.pack_data
    load = function(pack_data)
      local data = pack_data.spec.data
      local name = pack_data.spec.name

      if data ~= nil and _register_lazy(name, data) then
        return
      end

      vim.cmd.packadd({ vim.fn.escape(name, " ") })

      if data == nil then
        return
      end

      if data.skip_load then
        return
      end

      if data.config ~= nil then
        data.config()
        return
      end

      local modname = data.name or name
      if modname ~= nil then
        require(modname).setup(data.opts or {})
      end
    end,
  })
end

---@return string
function M.norm(path)
  if path:sub(1, 1) == "~" then
    local home = vim.uv.os_homedir()
    if home == nil then
      return ""
    end

    if home:sub(-1) == "\\" or home:sub(-1) == "/" then
      home = home:sub(1, -2)
    end
    path = home .. path:sub(2)
  end
  path = path:gsub("\\", "/"):gsub("/+", "/")
  return path:sub(-1) == "/" and path:sub(1, -2) or path
end

return M
