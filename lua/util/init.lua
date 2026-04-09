-- This file is copycat from LazyVIM and other distro

local M = {
    lualine = require("util.lualine_extras"),
    root = require("util.root"),
}

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

function M.tableToString(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        result = result .. tostring(k) .. " = " .. tostring(v) .. ", "
    end
    result = result .. "}"
    return result
end

-- has Checks if pack is being installed.
function M.has(key)
    local active_packs = vim.iter(vim.pack.get())
        :filter(function(x) return x.active end)
        :filter(function(x) return x.spec.name == key end)
        :map(function(x) return x.spec.name end)
        :totable()

    -- vim.notify("Do we have "..key..": " .. M.tableToString(active_packs) )
    return # (active_packs) > 0
end

-- GH generates github url
function M.GH(repo_name)
    return "https://github.com/" .. repo_name
end

M.packs = {}

-- AddPack add the configuration of pack to be installed later when calling InstallPacks
function M.AddPack(pack)
    table.insert(M.packs, pack)
end

function M.InstallPacks()
    vim.pack.add(
        M.packs,
        {
            confirm = false,
            load = function(pack_data)
                vim.cmd.packadd({ vim.fn.escape(pack_data.spec.name, ' ') })

                local data = pack_data.spec.data

                if data == nil then
                    return
                end

                if data.skip_load then return end

                if data.config ~= nil then
                    data.config()
                    return
                end

                require(data.name or pack_data.spec.name).setup(data.opts or {})
            end
        })
end

---@return string
function M.norm(path)
    if path:sub(1, 1) == "~" then
        local home = vim.uv.os_homedir()
        if home:sub(-1) == "\\" or home:sub(-1) == "/" then
            home = home:sub(1, -2)
        end
        path = home .. path:sub(2)
    end
    path = path:gsub("\\", "/"):gsub("/+", "/")
    return path:sub(-1) == "/" and path:sub(1, -2) or path
end

return M
