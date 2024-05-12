-- File: lua/settings/lua-ls-lspconfig.lua
return {
  'neovim/nvim-lspconfig',  -- This is the repository of the LSPconfig plugin
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Add enhanced capabilities here
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
    capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
    capabilities.textDocument.completion.completionItem.deprecatedSupport = true
    capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
    capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        'documentation',
        'detail',
        'additionalTextEdits',
      },
    }

    -- Lua-specific settings
    local lua_settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        diagnostics = {
          globals = {'vim'},
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    }

    -- Setup lspconfig for lua_ls
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      settings = lua_settings,
      on_attach = function(client, bufnr)
        -- Optional: Setup buffer keymaps, autocommands, etc.
      end
    })
  end
}
