return {
  'neovim/nvim-lspconfig',  -- Repository for LSP configurations
  config = function()
    local lspconfig = require('lspconfig')
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- Enhanced capabilities for LSP
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

    -- Specific settings for asm_lsp
    local asm_settings = {
      asm = {
        -- Add specific settings for asm_lsp if there are any available from the documentation
        -- For example, assembler version or specific configurations
      },
    }

    -- Setup lspconfig for asm_lsp
    lspconfig.asm_lsp.setup({
      capabilities = capabilities,
      settings = asm_settings,
      on_attach = function(client, bufnr)
        -- Optional: Setup buffer keymaps, autocommands, etc.
        -- E.g., keymap to jump to definition, add hover support, etc.
      end
    })
  end
}
