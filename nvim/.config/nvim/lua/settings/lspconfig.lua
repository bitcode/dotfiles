-- Setup language servers.
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Utility function to set up on_attach and keymaps for each LSP
local function on_attach(client, bufnr)
	require("completion").on_attach(client, bufnr)
	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local opts = { noremap = true, silent = true }

	-- Key mappings for LSP functions
	--  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	--  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	--  buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	--  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	--  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
end

-- Server configurations
-- nixd configuration
lspconfig.nixd.setup({
   cmd = { "nixd" },
   capabilities = capabilities,
   on_attach = on_attach,
   settings = {
      nixd = {
         nixpkgs = {
            expr = "import <nixpkgs> { }",
         },
         formatting = {
            command = { "nixfmt" },
         },
         options = {
            nixos = {
               expr = '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options',
            },
            home_manager = {
               expr = '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
            },
         },
      },
   },
})

lspconfig.pyright.setup({})

lspconfig.ts_ls.setup({
	capabilities = capabilities,
	settings = {
		typescript = {
			format = {
				enable = true,
			},
		},
	},
})

lspconfig.lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Specify the Lua version you are using (most likely LuaJIT for Neovim)
                version = 'LuaJIT',
                -- Setup your Lua path
                path = vim.split(package.path, ';'),
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {'vim'},
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                -- Check for third-party libraries in your workspace
                checkThirdParty = false,
            },
            telemetry = {
                -- Do not send telemetry data containing a randomized but unique identifier
                enable = false,
            },
        },
    },
})

lspconfig.cssmodules_ls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.bashls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.dockerls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.emmet_language_server.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.html.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.pylsp.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        pylsp = {
            plugins = {
                -- Formatter options
                black = { enabled = true },
                autopep8 = { enabled = false },
                yapf = { enabled = false },

                -- Linter options
                pylint = { enabled = true, executable = "pylint" },
                pyflakes = { enabled = false },
                pycodestyle = { enabled = false },

                -- Type checker
                pylsp_mypy = { enabled = true },

                -- Auto-completion options
                jedi_completion = { fuzzy = true },

                -- Import sorting
                pyls_isort = { enabled = true },
            },
        },
    },
    flags = {
        debounce_text_changes = 200,
    },
})

lspconfig.asm_lsp.setup({
	cmd = { "asm-lsp" },
	filetypes = { "asm", "s", "S" },
	root_dir = lspconfig.util.root_pattern(".git", ".asm-lsp.toml"),
	settings = {
		version = "0.1",
		assemblers = {
			gas = true,
			go = false,
		},
		instruction_sets = {
			x86 = false,
			x86_64 = true,
		},
	},
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
		debounce_text_changes = 150,
	},
})

lspconfig.tailwindcss.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.gopls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.htmx.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.clangd.setup({
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--function-arg-placeholders",
		"-j4",
		"--fallback-style=llvm",
		"--all-scopes-completion",
		"--suggest-missing-includes",
		"--log=info",
	},
	root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git", "Makefile"),
	capabilities = capabilities,
	on_attach = on_attach,
	flags = {
		debounce_text_changes = 150,
	},
})

lspconfig.rust_analyzer.setup({
	settings = {
		["rust-analyzer"] = {},
	},
	capabilities = capabilities,
	on_attach = on_attach,
})

-- New LSP configurations to be added:
lspconfig.jsonls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.markdown_oxide.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.taplo.setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig.yamlls.setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		yaml = {
			schemas = {
				["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
				["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
				["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
			},
			format = {
				enable = true,
			},
		},
	},
})

-- Additional yaml LSPs like yamlfmt, yamllint and yamlfix are generally external formatters and linters
-- that are often integrated via null-ls or other external tools. If you wish to integrate these with LSP,
-- you might use null-ls.nvim to add these as code actions, formatters, etc.
