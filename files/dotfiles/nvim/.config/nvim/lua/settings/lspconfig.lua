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
        "source.fixAll",
        "source.removeUnused",
        "source.addMissingImports",
        "source.removeUnusedImports",
        "source.sortImports",
      },
    },
  },
}

capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.symbol = {
  dynamicRegistration = true,
  symbolKind = {
    valueSet = {
      1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
    }
  },
  tagSupport = { valueSet = { 1 } },
  resolveSupport = { properties = { "location.range" } }
}

capabilities.textDocument.hover = {
  dynamicRegistration = true,
  contentFormat = { "markdown", "plaintext" }
}

capabilities.textDocument.signatureHelp = {
  dynamicRegistration = true,
  signatureInformation = {
    documentationFormat = { "markdown", "plaintext" },
    parameterInformation = { labelOffsetSupport = true },
    activeParameterSupport = true
  },
  contextSupport = true
}

local function on_attach(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set({ 'n', 'i' }, '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end,
    })
  end
end

-- Shared defaults for all servers
vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Server-specific configs (merged with bundled nvim-lspconfig defaults)
vim.lsp.config('nixd', {
  cmd = { "nixd" },
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

vim.lsp.config('ts_ls', {
  settings = {
    typescript = {
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
        indentSize = 2,
        convertTabsToSpaces = true,
        tabSize = 2,
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
        providePrefixAndSuffixTextForRename = true,
        allowRenameOfImportPath = true,
        includePackageJsonAutoImports = "auto",
        jsxAttributeCompletionStyle = "auto",
        allowTextChangesInNewFiles = true,
        lazyConfiguredProjectsFromExternalProject = false,
        closingLabels = true,
        disableSuggestions = false,
      },
      suggest = {
        autoImports = true,
        completeFunctionCalls = true,
        includeCompletionsForImportStatements = true,
        includeAutomaticOptionalChainCompletions = true,
      },
      updateImportsOnFileMove = { enable = true },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true, showOnAllFunctions = true },
      experimental = { enableProjectDiagnostics = true },
    },
    javascript = {
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
      format = { enable = true },
    },
  },
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  init_options = {
    hostInfo = "neovim",
    maxTsServerMemory = 8192,
    tsserver = {
      logVerbosity = "off",
      logFile = "",
      pluginProbeLocations = {},
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeCompletionsWithSnippetText = true,
        includeCompletionsWithInsertText = true,
        allowIncompleteCompletions = true,
        displayPartsForJSDoc = true,
        generateReturnInDocTemplate = true,
        providePrefixAndSuffixTextForRename = true,
        allowRenameOfImportPath = true,
        includePackageJsonAutoImports = "auto",
        jsxAttributeCompletionStyle = "auto",
        allowTextChangesInNewFiles = true,
        lazyConfiguredProjectsFromExternalProject = false,
        closingLabels = true,
        disableSuggestions = false,
      },
    },
  },
})

vim.lsp.config('lua_ls', {
  on_init = function(client)
    if client.workspace_folders then
      local path = client.workspace_folders[1].name
      if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
        return
      end
    end
    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file("", true),
      },
    })
  end,
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' } },
      telemetry = { enable = false },
      formatting = { enable = true },
    },
  },
})

vim.lsp.config('asm_lsp', {
  cmd = { "asm-lsp" },
  filetypes = { "asm", "s", "S" },
  settings = {
    version = "0.1",
    assemblers = { gas = true, go = false },
    instruction_sets = { x86 = false, x86_64 = true },
  },
  flags = { debounce_text_changes = 150 },
})

vim.lsp.config('clangd', {
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
  flags = { debounce_text_changes = 150 },
})

vim.lsp.config('pylsp', {
  settings = {
    pylsp = {
      plugins = {
        black = { enabled = true },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        pylint = { enabled = true, executable = "pylint" },
        pyflakes = { enabled = false },
        pycodestyle = { enabled = false },
        pylsp_mypy = { enabled = true },
        jedi_completion = { fuzzy = true },
        pyls_isort = { enabled = true },
      },
    },
  },
  flags = { debounce_text_changes = 200 },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
      },
      format = { enable = true },
    },
  },
})

vim.lsp.config('omnisharp', {
  cmd = {
    "dotnet",
    "C:\\Users\\bit\\AppData\\Local\\nvim-data\\mason\\packages\\omnisharp\\libexec\\OmniSharp.dll",
  },
  settings = {
    FormattingOptions = { EnableEditorConfigSupport = true, OrganizeImports = nil },
    MsBuild = { LoadProjectsOnDemand = nil },
    RoslynExtensionsOptions = {
      EnableAnalyzersSupport = nil,
      EnableImportCompletion = nil,
      AnalyzeOpenDocumentsOnly = nil,
    },
    Sdk = { IncludePrereleases = true },
  },
})

-- Enable all servers
vim.lsp.enable({
  'nixd',
  'ts_ls',
  'lua_ls',
  'cssmodules_ls',
  'bashls',
  'dockerls',
  'emmet_language_server',
  'html',
  'pylsp',
  'asm_lsp',
  'gopls',
  'htmx',
  'clangd',
  'rust_analyzer',
  'jsonls',
  'markdown_oxide',
  'taplo',
  'yamlls',
  'omnisharp',
})
