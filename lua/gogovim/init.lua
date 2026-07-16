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

-- Forward declarations: these locals are defined in the lazy-load section below,
-- but the mapping helpers (defined here) reference them.
local _pack_index   -- pack name -> GogoVIM.packs.pack.data
local _do_load      -- function(pack_name, data)
local _ensure_loaded -- function(pack_name) -> boolean

-- Keys in a mapping section that are metadata, not Vim modes.
local _section_meta = { plugin = true, pack = true }

--- Apply every mapping in one section directly (no lazy wrapper).
--- Does not mutate the section table.
--- @param values table The section, e.g. M.mappings.general.
local function _apply_section_direct(values)
  for mode, mode_values in pairs(values) do
    if not _section_meta[mode] and type(mode_values) == "table" then
      for keybind, mapping_info in pairs(mode_values) do
        local opts = vim.tbl_deep_extend("force", { desc = mapping_info[2], remap = false }, mapping_info.opts or {})
        local ok, err = pcall(vim.keymap.set, mode, keybind, mapping_info[1], opts)
        if not ok then
          vim.notify("keymap set failed for " .. mode .. " " .. keybind .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end
  end
end

--- Apply a section whose plugin (`pack`) may not be loaded yet.
--- Each key is bound to a stub that, on first press, loads the pack, swaps in the
--- real mappings, then replays the keypress so the real action runs.
--- @param values table The section table (must contain a `pack` field).
local function _apply_section_lazy(values)
  local pack = values.pack

  for mode, mode_values in pairs(values) do
    if not _section_meta[mode] and type(mode_values) == "table" then
      for keybind, mapping_info in pairs(mode_values) do
        local lhs = keybind
        local stub = function()
          -- Load the pack (its config typically re-applies these mappings via
          -- load_mapping). Then ensure the real mappings exist and replay.
          _ensure_loaded(pack)
          _apply_section_direct(values)
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(lhs, true, true, true), "m", false)
        end
        local opts = vim.tbl_deep_extend(
          "force",
          { desc = mapping_info[2], remap = false },
          mapping_info.opts or {},
          { remap = false }
        )
        local ok, err = pcall(vim.keymap.set, mode, lhs, stub, opts)
        if not ok then
          vim.notify("keymap stub set failed for " .. mode .. " " .. lhs .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end
  end
end

--- Apply a single section, choosing eager or lazy strategy.
--- @param values table
local function _set_section_map(values)
  if values.pack ~= nil and not (_pack_index[values.pack] and _pack_index[values.pack]._loaded) then
    _apply_section_lazy(values)
  else
    _apply_section_direct(values)
  end
end

--- Load mappings. With no argument, every section is applied (including plugin
--- sections, so plugin keymaps work even before their pack is loaded). With a
--- section name, only that section is (re)applied — typically called from a
--- plugin's config after it loads, to swap stubs for the real mappings.
--- @param section? string Section name in M.mappings (e.g. "flash"). nil = all.
function M.load_mapping(section)
  vim.schedule(function()
    local mappings = M.mappings

    if type(section) == "string" then
      local sec = mappings[section]
      if sec == nil then
        vim.notify("load_mapping: unknown section '" .. section .. "'", vim.log.levels.WARN)
        return
      end
      -- Explicit per-section load means the pack is (being) loaded: apply directly.
      _apply_section_direct(sec)
      return
    end

    for _, sec in pairs(mappings) do
      _set_section_map(sec)
    end
  end)
end

--- Checks whether a pack is installed and active.
--- @param key string Pack name (top-level name passed to vim.pack.add).
--- @return boolean
function M.has(key)
  for _, x in ipairs(vim.pack.get()) do
    if x.active and x.spec.name == key then
      return true
    end
  end
  return false
end

--- GH generates a GitHub https URL for a "owner/repo" string.
--- @param repo_name string e.g. "folke/trouble.nvim".
--- @return string
function M.GH(repo_name)
  return "https://github.com/" .. repo_name
end

--- @class GogoVIM.packs.pack.data
--- @field name? string           -- module name to `require(...).setup()` (defaults to the pack name)
--- @field confirm? boolean
--- @field skip_load? boolean
--- @field build? string[]        -- command + args run via vim.system on PackChanged
--- @field config? function
--- @field opts? any
--- @field cmd? string|string[]   -- lazy: load on first invocation of any of these user commands
--- @field event? string|string[] -- lazy: load on first occurrence of any of these autocmd events
--- @field ft? string|string[]    -- lazy: load on FileType matching any of these
--- @field keys? table            -- lazy: load on first press; entries: { lhs, mode = "n"|table }
--- @field mapping? string         -- keymap section in M.mappings applied after this pack loads
--- @field _loaded? boolean       -- internal: set by _do_load to make loading idempotent
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
_pack_index = {}          -- pack name -> GogoVIM.packs.pack.data (built in InstallPacks)

local function _as_list(v)
  if v == nil then return {} end
  if type(v) == "table" then return v end
  return { v }
end

_do_load = function(pack_name, data)
  -- Idempotent loader: packadd + run config/setup once.
  if data._loaded then return end
  data._loaded = true

  vim.cmd.packadd({ vim.fn.escape(pack_name, " ") })

  if not data.skip_load then
    if data.config ~= nil then
      data.config()
    else
      local modname = data.name or pack_name
      if modname ~= nil then
        require(modname).setup(data.opts or {})
      end
    end
  end

  -- Apply this pack's keymap section (swaps any lazy stubs for real mappings).
  if data.mapping ~= nil then
    M.load_mapping(data.mapping)
  end
end

--- Ensure a registered pack is loaded on demand (idempotent).
--- Used by keymap wrappers so a plugin's keys work before the pack is loaded.
--- @param pack_name string Top-level pack name (as passed to vim.pack.add / packadd).
--- @return boolean # true if the pack was found in the index (or already loaded).
_ensure_loaded = function(pack_name)
  if pack_name == nil then
    return false
  end

  local data = _pack_index[pack_name]
  if data ~= nil then
    if data._loaded then
      return true
    end
    local ok, err = pcall(_do_load, pack_name, data)
    if not ok then
      vim.notify("ensure_loaded failed for " .. pack_name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end
    return true
  end

  -- Unknown pack (added without data, or not registered): best-effort packadd.
  local ok = pcall(vim.cmd.packadd, { vim.fn.escape(pack_name, " ") })
  return ok
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
M._ensure_loaded = _ensure_loaded
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

  -- Build the name -> data index so keymap stubs can load packs on demand,
  -- regardless of whether the pack has been (lazily) loaded yet.
  for _, pack in ipairs(M.packs) do
    if pack.name ~= nil and pack.data ~= nil then
      _pack_index[pack.name] = pack.data
    end
  end

  vim.pack.add(M.packs, {
    confirm = false,
    --- @param pack_data GogoVIM.packs.pack_data
    load = function(pack_data)
      local data = pack_data.spec.data
      local name = pack_data.spec.name

      if data ~= nil and _register_lazy(name, data) then
        return
      end

      -- Non-lazy path: single source of truth in _do_load.
      if data == nil then
        vim.cmd.packadd({ vim.fn.escape(name, " ") })
        return
      end

      _do_load(name, data)
    end,
  })
end

--- Normalize a path: expand a leading "~", convert "\\" to "/", collapse
--- repeated slashes, and drop any trailing slash.
--- @param path string
--- @return string
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
