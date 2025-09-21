return {
	-- Mason: manages external tools like LSP servers
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-LSPConfig: bridges Mason with nvim-lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "pyright", "rust_analyzer", "lua_ls", "clangd", "gopls", "ts_ls" },
				automatic_installation = true,
				automatic_enable = false,
			})
		end,
	},

	-- LSP Config
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = false,
				signs = false,
				underline = true,
				update_in_insert = false,
			})

			-- on_attach function runs when LSP attaches to a buffer
			local on_attach = function(client, bufnr)
				-- Enable inlay hints if supported
				if
					client.server_capabilities.inlayHintProvider
					and not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
				then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end

				-- Rust: format asynchronously on save
				if client.name == "rust_analyzer" and client.server_capabilities.documentFormattingProvider then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = true })
						end,
					})
				end
				if client.name == "gopls" and client.server_capabilities.documentFormattingProvider then
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
						buffer = bufnr,
						callback = function()
							-- Organize imports
							local params = vim.lsp.util.make_range_params(0, "utf-16")
							params.context = { only = { "source.organizeImports" } }
							local results = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 3000)
							for _, res in pairs(results or {}) do
								for _, r in pairs(res.result or {}) do
									if r.edit then
										vim.lsp.util.apply_workspace_edit(r.edit, "utf-16")
									end
								end
							end
							-- Format buffer
							vim.lsp.buf.format({ async = false })
						end,
					})
				end
			end

			-- Configure language servers using vim.lsp.config()
			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = {
					"pyproject.toml",
					"setup.py",
					"setup.cfg",
					"requirements.txt",
					"Pipfile",
					"pyrightconfig.json",
					".git",
				},
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					"stylua.toml",
					"selene.toml",
					"selene.yml",
					".git",
				},
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
							path = vim.split(package.path, ";"),
						},
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})
			vim.lsp.config("rust_analyzer", {
				cmd = { "rust-analyzer" },
				filetypes = { "rust" },
				root_markers = { "Cargo.toml", "rust-project.json", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
				settings = {
					["rust-analyzer"] = {
						inlayHints = {
							typeHints = true,
						},
					},
				},
			})
			vim.lsp.config("clangd", {
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				root_markers = {
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					"configure.ac",
					".git",
				},
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.config("gopls", {
				cmd = { "gopls" },
				filetypes = { "go", "gomod", "gowork", "gotmpl" },
				root_markers = { "go.work", "go.mod", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.config("html", {
				cmd = { "vscode-html-language-server", "--stdio" },
				filetypes = { "html" },
				root_markers = { "package.json", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.config("ts_ls", {
				cmd = { "typescript-language-server", "--stdio" },
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				root_markers = { "tsconfig.json", "package.json", "jsconfig.json", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			vim.lsp.config("cssls", {
				cmd = { "vscode-css-language-server", "--stdio" },
				filetypes = { "css", "scss", "less" },
				root_markers = { "package.json", ".git" },
				capabilities = capabilities,
				on_attach = on_attach,
			})
			-- Enable all configured language servers
			vim.lsp.enable({ "pyright", "lua_ls", "rust_analyzer", "clangd", "gopls", "html", "ts_ls", "cssls" })
		end,
	},
	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},

	-- Trouble: diagnostics UI
	{
		"folke/trouble.nvim",
		cmd = "Trouble",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics<cr>", desc = "Toggle Trouble" },
			{ "<leader>xb", "<cmd>Trouble close<cr>", desc = "close Trouble" },
			{ "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>xd", "<cmd>Trouble document_diagnostics<cr>", desc = "Document Diagnostics" },
			{ "<leader>xq", "<cmd>Trouble quickfix<cr>", desc = "Quickfix List" },
			{ "<leader>xl", "<cmd>Trouble loclist<cr>", desc = "Location List" },
			{ "gR", "<cmd>Trouble lsp_references<cr>", desc = "LSP References" },
		},
	},

	-- Crates.nvim for Cargo.toml
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local crates = require("crates")
			crates.setup()
			crates.setup({
				completion = {
					cmp = {
						enabled = true,
					},
				},
			})

			local cmp = require("cmp")
			cmp.setup.filetype("toml", {
				sources = cmp.config.sources({
					{ name = "crates" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
}
