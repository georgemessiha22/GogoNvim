local solargraphLocation = os.getenv("HOME") .. "/.rbenv/shims/solargraph"
local file = io.open(solargraphLocation, "r")

if file ~= nil then
    io.close(file)
    return {
        cmd = { solargraphLocation, "stdio" },
        settings = {
            solargraph = {
                autoformat = false,
                formatting = false,
                completion = true,
                diagnostic = true,
                folding = true,
                references = true,
                rename = true,
                symbols = true,
            },
        },
        init_options = { formatting = true },
    }
end

return {}
