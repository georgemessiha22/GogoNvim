-------------------------------------- autocmds ------------------------------------------
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
    return vim.api.nvim_create_augroup("GogoVIM_" .. name, { clear = true })
end

-- resize splits if window got resized
autocmd("VimResized", {
    group = augroup("resize_splits"),
    callback = function()
        GogoVIM.on_very_lazy(function()
            local current_tab = vim.fn.tabpagenr()
            vim.cmd("tabdo wincmd =")
            vim.cmd("tabnext " .. current_tab)
        end)
    end,
})

-- close some filetypes with <q>
autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "help",
        "lspinfo",
        "notify",
        "qf",
        "query",
        "startuptime",
        "checkhealth",
    },
    callback = function(event)
        GogoVIM.on_very_lazy(function()
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
        end)
    end,
})

-- Fix conceallevel for json files
autocmd("FileType", {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function()
        GogoVIM.on_very_lazy(function()
            vim.opt_local.conceallevel = 0
        end)
    end,
})

-- Fix tabexpand for yaml files
-- autocmd("FileType", {
--     group = augroup("yaml"),
--     pattern = { "yaml", "yml" },
--     callback = function(_)
--         GogoVIM.on_very_lazy(function()
--             vim.opt_local.tabstop = 2
--             vim.opt_local.softtabstop = 2
--             vim.opt_local.shiftwidth = 2
--             vim.opt_local.expandtab = true
--         end)
--     end,
-- })

-- Auto create dir when saving a file, in case some intermediate directory does not exist
autocmd({ "BufWritePre" }, {
    group = augroup("auto_create_dir"),
    callback = function(event)
        GogoVIM.on_very_lazy(function()
            if event.match:match("^%w%w+:[\\/][\\/]") then
                return
            end
            local file = vim.uv.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
        end)
    end,
})


if GogoVIM.has("folke/snacks.nvim") then
    local progress = vim.defaulttable()
    ---@type table<number, {token:lsp.ProgressToken, msg:string, done:boolean}[]>
    autocmd("LspProgress", {
        ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
        callback = function(ev)
            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            local value = ev.data.params
                .value --[[@as {percentage?: number, title?: string, message?: string, kind: "begin" | "report" | "end"}]]
            if not client or type(value) ~= "table" then
                return
            end
            local p = progress[client.id]

            for i = 1, #p + 1 do
                if i == #p + 1 or p[i].token == ev.data.params.token then
                    p[i] = {
                        token = ev.data.params.token,
                        msg = ("[%3d%%] %s%s"):format(
                            value.kind == "end" and 100 or value.percentage or 100,
                            value.title or "",
                            value.message and (" **%s**"):format(value.message) or ""
                        ),
                        done = value.kind == "end",
                    }
                    break
                end
            end

            local msg = {} ---@type string[]
            progress[client.id] = vim.tbl_filter(function(v)
                return table.insert(msg, v.msg) or not v.done
            end, p)

            local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
            vim.notify(table.concat(msg, "\n"), "info", {
                id = "lsp_progress",
                title = client.name,
                opts = function(notif)
                    notif.icon = #progress[client.id] == 0 and " "
                        or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                end,
            })
        end,
    })
end
