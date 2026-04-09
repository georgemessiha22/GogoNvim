return {
    cmd = { 'ruff', 'server' },
    filetypes = { 'python' },
    init_options = {
        settings = {
            interpreter = { './venv/bin/python' },
        }
    },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
}
