-- - lua_ls (id: 2)
-- - Version: 3.18.0
-- - Root directory: ~/.config/nvim
-- - Command: { "lua-language-server" }
-- - Settings: {
--     Lua = {
--       codeLens = {
--         enable = true
--       },
--       hint = {
--         enable = true,
--         semicolon = "Disable"
--       },
--       runtime = {
--         path = { "./?.lua", "/opt/homebrew/share/luajit-2.1/?.lua", "/usr/local/share/lua/5.1/?.lua", "/usr/local/share/lua/5.1/?/init.lua", "/opt/homebrew/share/lua/5.1/?.lua", "/opt/homebrew/share/lua/5.1/?/init.lua" },
--         version = "LuaJIT"
--       },
--       workspace = {
--         ignoreSubmodules = true,
--         library = { "/opt/homebrew/Cellar/neovim/0.12.1/share/nvim/runtime", "/Users/george/.config/nvim/gogovim" }
--       }
--     },
--     root_markers = { "stylua.lua" }
--   }
-- - Attached buffers: 1, 18, 6
--
return {
  -- LuaLS Structure of these settings comes from LuaLS, not Neovim
  settings = {
    root_markers = { "stylua.lua" },
    Lua = {
      codeLens = {
        enable = true,
      },
      hint = {
        enable = true,
      },
      -- Define runtime properties. Use 'LuaJIT', as it is built into Neovim.
      runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
      workspace = {
        -- Don't analyze code from submodules
        ignoreSubmodules = false,
        -- Add Neovim's methods for easier code writing
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}
