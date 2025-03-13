-- Setup language servers.
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.codeAction = {
    dynamicRegistration = false,
    codeActionLiteralSupport = {
        codeActionKind = {
            valueSet = {
                "",
                "quickfix",
                "refactor",
                "refactor.extract",
                "refactor.inline",
                "refactor.rewrite",
                "source",
                "source.organizeImports",
            },
        },
    },
}
-- Utility function to set up on_attach and keymaps for each LSP
local function lsp_keymaps(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local opts = { noremap = true, silent = true }

    -- Key mappings for LSP functions
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
end

local function on_attach(client, bufnr)
    lsp_keymaps(client, bufnr)
    -- Enable format on save if the LSP supports it
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end
end

local function setup_nixd()
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
                        expr =
                        '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options',
                    },
                },
            },
        },
    })
end

local function setup_pyright()
    lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_ts_ls()
    lspconfig.tsserver.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            typescript = {
                inlayHints = {
                    -- Show inlay hints for parameter names
                    includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all'
                    -- Show inlay hints for parameter names even when argument matches the parameter name
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    -- Show inlay hints for function return types
                    includeInlayFunctionParameterTypeHints = true,
                    -- Show inlay hints for variable types
                    includeInlayVariableTypeHints = true,
                    -- Show inlay hints for variable types even when variable name matches type name
                    includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                    -- Show inlay hints for property declarations
                    includeInlayPropertyDeclarationTypeHints = true,
                    -- Show inlay hints for function return types
                    includeInlayFunctionLikeReturnTypeHints = true,
                    -- Show inlay hints for enum member values
                    includeInlayEnumMemberValueHints = true,
                },
                format = {
                    enable = true,
                    indentSize = 2,
                    convertTabsToSpaces = true,
                    tabSize = 2,
                    -- Additional formatting options
                    insertSpaceAfterCommaDelimiter = true,
                    insertSpaceAfterSemicolonInForStatements = true,
                    insertSpaceBeforeAndAfterBinaryOperators = true,
                    insertSpaceAfterKeywordsInControlFlowStatements = true,
                    insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
                    insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
                    insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
                    insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
                    insertSpaceAfterTypeAssertion = false,
                    placeOpenBraceOnNewLineForFunctions = false,
                    placeOpenBraceOnNewLineForControlBlocks = false,
                },
                implementationsCodeLens = {
                    enabled = true,
                },
                referencesCodeLens = {
                    enabled = true,
                    showOnAllFunctions = true,
                },
                preferences = {
                    quotePreference = "single",
                    importModuleSpecifier = "relative",
                    importModuleSpecifierEnding = "minimal",
                    includeCompletionsForModuleExports = true,
                    includeCompletionsForImportStatements = true,
                    includeCompletionsWithSnippetText = true,
                    includeCompletionsWithInsertText = true,
                    includeAutomaticOptionalChainCompletions = true,
                    includeCompletionsWithClassMemberSnippets = true,
                    includeCompletionsWithObjectLiteralMethodSnippets = true,
                    useLabelDetailsInCompletionEntries = true,
                    allowIncompleteCompletions = true,
                    displayPartsForJSDoc = true,
                    generateReturnInDocTemplate = true,
                },
                suggest = {
                    autoImports = true,
                    completeFunctionCalls = true,
                    includeCompletionsForImportStatements = true,
                    includeAutomaticOptionalChainCompletions = true,
                },
                updateImportsOnFileMove = {
                    enable = true,
                },
                code = {
                    extractFunction = true,
                    extractConstant = true,
                },
                experimental = {
                    enableProjectDiagnostics = true,
                },
                diagnositcs = {
                    enable = true,
                    reportStyleChecksAsWarnings = true,
                    virtualText = true,
                    signs = true,
                    underline = true,
                },
            },
            javascript = {
                -- Same settings as typescript but for JavaScript files
                -- This ensures consistent behavior across JS/TS files
                inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayVariableTypeHintsWhenTypeMatchesName = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                },
                format = {
                    enable = true,
                    -- Same formatting options as typescript
                },
                -- ... other settings same as typescript
            },
        },
        commands = {
            -- Add custom commands if needed
            OrganizeImports = {
                function()
                    vim.lsp.buf.execute_command({
                        command = "_typescript.organizeImports",
                        arguments = { vim.api.nvim_buf_get_name(0) },
                    })
                end,
                description = "Organize Imports"
            },
        },
        flags = {
            debounce_text_changes = 150,
            allow_incremental_sync = true,
        }
    })
end


local function setup_lua_ls()
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
                    globals = { 'vim' },
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
                formatting = {
                    -- Enable LSP-based formatting
                    enable = true,
                },
            },
        },
    })
end

local function setup_cssmodules_ls()
    lspconfig.cssmodules_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_bashls()
    lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_dockerls()
    lspconfig.dockerls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_emmet_language_server()
    lspconfig.emmet_language_server.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_html()
    lspconfig.html.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_pylsp()
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
end

local function setup_asm_lsp()
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
end

local function setup_tailwindcss()
    lspconfig.tailwindcss.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_gopls()
    lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_htmx()
    lspconfig.htmx.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_clangd()
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
end

local function setup_rust_analyzer()
    lspconfig.rust_analyzer.setup({
        settings = {
            ["rust-analyzer"] = {},
        },
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_jsonls()
    lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_markdown_oxide()
    lspconfig.markdown_oxide.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_taplo()
    lspconfig.taplo.setup({
        capabilities = capabilities,
        on_attach = on_attach,
    })
end

local function setup_yamlls()
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
end

local function setup_omnisharp()
    local omnisharp_path =
    "C:\\Users\\bit\\AppData\\Local\\nvim-data\\mason\\packages\\omnisharp\\libexec\\OmniSharp.dll"

    lspconfig.omnisharp.setup({
        cmd = { "dotnet", omnisharp_path },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            FormattingOptions = {
                EnableEditorConfigSupport = true,
                OrganizeImports = nil,
            },
            MsBuild = {
                LoadProjectsOnDemand = nil,
            },
            RoslynExtensionsOptions = {
                EnableAnalyzersSupport = nil,
                EnableImportCompletion = nil,
                AnalyzeOpenDocumentsOnly = nil,
            },
            Sdk = {
                IncludePrereleases = true,
            },
        }
    })
end

-- A table mapping filetypes to setup functions
_G.filetype_to_lsp = {
    ["c"] = setup_clangd,
    ["cpp"] = setup_clangd,
    ["h"] = setup_clangd,
    ["hpp"] = setup_clangd,
    ["nix"] = setup_nixd,
    ["python"] = setup_pylsp,
    ["typescript"] = setup_ts_ls,
    ["tsx"] = setup_ts_ls,
    ["ts"] = setup_ts_ls,
    ["js"] = setup_ts_ls,
    ["jsx"] = setup_ts_ls,
    ["typescriptreact"] = setup_ts_ls,
    ["javascript"] = setup_ts_ls,
    ["javascriptreact"] = setup_ts_ls,
    ["lua"] = setup_lua_ls,
    ["css"] = setup_cssmodules_ls,
    ["scss"] = setup_cssmodules_ls,
    ["bash"] = setup_bashls,
    ["sh"] = setup_bashls,
    ["dockerfile"] = setup_dockerls,
    ["html"] = setup_html,
    ["asm"] = setup_asm_lsp,
    ["s"] = setup_asm_lsp,
    ["S"] = setup_asm_lsp,
    ["go"] = setup_gopls,
    ["rust"] = setup_rust_analyzer,
    ["json"] = setup_jsonls,
    ["markdown"] = setup_markdown_oxide,
    ["toml"] = setup_taplo,
    ["yaml"] = setup_yamlls,
    ["yml"] = setup_yamlls,
    ["htmx"] = setup_htmx,
    ["csharp"] = setup_omnisharp,
    ["cs"] = setup_omnisharp,
}

local function setup_server(server_name, setup_fn)
    vim.notify("Setting up LSP server: " .. server_name, vim.log.levels.INFO)
    setup_fn()
end

-- Then modify your filetype_to_lsp table usage:
vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lsp_setup = _G.filetype_to_lsp[ft]
        if lsp_setup then
            vim.notify("Detected filetype: " .. ft, vim.log.levels.INFO)
            setup_server(ft, lsp_setup)
        else
            vim.notify("No LSP configuration for filetype: " .. ft, vim.log.levels.WARN)
        end
    end,
})
