---@class util: LazyUtilCore
---@field inject util.inject

local M = {}

---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

-- Properly load file based plugins without blocking the UI
-- COPIED FROM LazyVIM
function M.lazy_file()
  M.use_lazy_file = M.use_lazy_file and vim.fn.argc(-1) > 0

  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")

  if M.use_lazy_file then
    -- We'll handle delayed execution of events ourselves
    Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
  else
    -- Don't delay execution of LazyFile events, but let lazy know about the mapping
    Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile

    return
  end

  local events = {} ---@type {event: string, buf: number, data?: any}[]

  local done = false
  local function load()
    if #events == 0 or done then
      return
    end
    done = true
    vim.api.nvim_del_augroup_by_name("lazy_file")

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
    for _, event in ipairs(events) do
      if vim.api.nvim_buf_is_valid(event.buf) then
        Event.trigger({
          event = event.event,
          exclude = skips[event.event],
          data = event.data,
          buf = event.buf,
        })
        if vim.bo[event.buf].filetype then
          Event.trigger({
            event = "FileType",
            buf = event.buf,
          })
        end
      end
    end
    vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  vim.api.nvim_create_autocmd(M.lazy_file_events, {
    group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
    callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

---Load Mapping for special plugin name or general mappings, better call it after plugin config to with plugin name to load it's mapper.
---@param section any
function M.load_mapping(section)
    vim.schedule(function()
        local function set_section_map(values)
            if values.plugin then -- bypass plugins section
                return
            end
            values.plugin = nil                                    -- this to garauntee all values are pair

            for mode, mode_values in pairs(values) do              -- first layer is modes i, v, t, x
                for keybind, mapping_info in pairs(mode_values) do -- second layer is key = {command, description}
                    local opts = vim.tbl_deep_extend("force", { desc = mapping_info[2], remap = false },
                        mapping_info.opts or {})
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
