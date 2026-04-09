-- vim-matchup globals must be set before the plugin loads
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_treesitter_stopline = 500
vim.g.matchup_treesitter_include_match_words = false
vim.g.matchup_treesitter_enable_quotes = true

-- Build hooks (must be registered before vim.pack.add)
vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('pack_changed', { clear = true }),
    callback = function(ev)
        if ev.data.kind == 'delete' then
            return
        end

        local name = ev.data.spec.name
        if name == 'nvim-treesitter' then
            vim.notify("Updating TreeSitter")
            pcall(function()
                vim.cmd('TSUpdate')
            end)
        elseif name == 'mason.nvim' then
            vim.notify("Updating Mason")
            pcall(function()
                vim.cmd('MasonUpdate')
            end)
        elseif name == 'go.nvim' then
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
    end
})

require("packs.editor")
require("packs.code")
require("packs.lsp")
require("packs.ai")

GogoVIM.InstallPacks()
