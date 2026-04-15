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
  vim.cmd.colorscheme(GogoVIM.UI.theme)

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
---
--- @class GogoVIM.packs.pack
--- @field src string
--- @field name? string
--- @field version? string|vim.VersionRange
--- @field data GogoVIM.packs.pack.data

--- @alias GogoVIM.packs.pack_data {spec: GogoVIM.packs.pack}
---
M.packs = {}

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
      vim.cmd.packadd({ vim.fn.escape(pack_data.spec.name, " ") })

      local data = pack_data.spec.data

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

      local modname = data.name or pack_data.spec.name
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
