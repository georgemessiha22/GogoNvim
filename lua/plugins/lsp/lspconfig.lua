return {
	"neovim/nvim-lspconfig",
	event = { "LazyFile" },
	dependencies = {
		{
			"folke/neodev.nvim",
			opts = {
				library = {
					enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
					-- these settings will be used for your Neovim config directory
					runtime = true, -- runtime path
					types = true,   -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
					plugins = true, -- installed opt or start plugins in packpath
					-- you can also specify the list of plugins to make available as a workspace library
					-- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
				},
				setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
				-- for your Neovim config directory, the config.library settings will be used as is
				-- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
				-- for any other directory, config.library.enabled will be set to false
				-- override = function(root_dir, options) end,
				-- With lspconfig, Neodev will automatically setup your lua-language-server
				-- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
				-- in your lsp start options
				lspconfig = true,
				-- much faster, but needs a recent built of lua-language-server
				-- needs lua-language-server >= 3.6.0
				pathStrict = true,
			},
		},
		{
			"VonHeikemen/lsp-zero.nvim",
			branch = "v3.x",
		},
		"williamboman/mason-lspconfig.nvim",
		"j-hui/fidget.nvim",
		"SmiteshP/nvim-navic",
	},
	config = function(_)
		local lsp_zero = require("lsp-zero")
		local on_attach = function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr })
			if client.server_capabilities.documentSymbolProvider then
				require("nvim-navic").attach(client, bufnr)
			end
		end
		lsp_zero.on_attach(on_attach)
		lsp_zero.extend_lspconfig()
		local mason_lspconfig = require("mason-lspconfig")
		local lspconfig = require("lspconfig")

		mason_lspconfig.setup({
			ensure_installed = {
				"bashls",                          -- LSP for bash shell
				"lua_ls",                          -- LSP for Lua language
				"tsserver",                        -- LSP for Typescript and Javascript
				"emmet_ls",                        -- LSP for Emmet (Vue, HTML, CSS)
				"cssls",                           -- LSP for CSS
				"ruff_lsp",                        -- LSP for Python
				"gopls",                           -- LSP for Go
				"svelte",                          -- LSP for Svelte
				"tailwindcss",                     -- LSP for TailWindCss
				"marksman",                        -- LSP for Markdown
				"dockerls",                        -- LSP for Dockerfile
				"docker_compose_language_service", -- LSP for Docker-compose
				-- "denols", -- LSP for deno
				"yamlls",                          -- LSP yaml
				"rust_analyzer",                   -- LSP Rust rust_analyzer
				"jsonls",                          -- LSP json
				"html",                            -- LSP html
				"eslint",                          -- LSP eslint

				"texlab",
				"taplo", -- LSP TOML
			},
			handlers = {
				function(server_name)
					local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
					if server_name == "gopls" then
						-- NOTE: configured on plugins/lsp/lang/go
						--
						-- lspconfig.gopls.setup({
						-- 	on_attach = on_attach,
						-- 	capabilities = lsp_zero.get_capabilities(),
						-- 	filetypes = { "go", "gomod", "go.work" },
						-- 	fillstruct = "gopls",
						-- 	settings = {
						-- 		gopls = {
						-- 			analyses = {
						-- 				unusedparams = true,
						-- 				unusedwrite=true,
						-- 				shadow = true,
						-- 				unusedvariable = true,
						-- 				useany = true,
						-- 			},
						-- 			staticcheck = true,
						-- 			gofumpt = true,
						-- 			buildFlags = { "-tags=functional,integration,unit" },
						-- 			hints = {
						-- 				assignVariableTypes = true,
						-- 				compositeLiteralFields = true,
						-- 				compositeLiteralTypes = true,
						-- 				constantValues = true,
						-- 				functionTypeParameters = true,
						-- 				parameterNames = true,
						-- 				rangeVariableTypes = true,
						-- 			},
						-- 		},
						-- 	},
						-- })
					elseif server_name == "lua_ls" and GogoVIM.has("cmp_nvim_lsp") then
						lspconfig.lua_ls.setup({
							on_attach = on_attach,
							capabilities = capabilities,
							settings = {
								Lua = {
									completion = {
										callSnippet = "Replace",
									},
								},
							},
						})
					else
						-- lspconfig[server_name].setup({})
						lsp_zero.default_setup(server_name)
					end
				end,
			},
		})

		-- Check if solargraph is installed and run the configurations.
		local solargraphLocation = os.getenv("HOME") .. "/.rbenv/shims/solargraph"
		local file = io.open(solargraphLocation, "r")
		if file ~= nil then
			io.close(file)
			lspconfig.solargraph.setup({
				cmd = { solargraphLocation, "stdio" },
				capabilities = lsp_zero.get_capabilities(),
				root_dir = lspconfig.util.root_pattern("Gemfile", ".git", "."),
				handlers = {
					["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
						virtual_text = true,
					}),
				},
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
				filetypes = { "ruby" },
			})
		end

		require("config").load_mapping("lspconfig")
	end,
}
