-- Load cmp and cmp-nvim-lsp
local cmp = require('cmp')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Setup cmp with nvim_lsp as a source
cmp.setup({
  sources = {
    { name = 'nvim_lsp' }
  }
})

-- Advertise capabilities to LSP servers
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Setup specific LSP servers, for example, clangd
require('mason-lspconfig').lua-language-server.setup({
  capabilities = capabilities,
})

-- Optionally, you can override keyword_pattern for specific language servers
cmp.setup({
  sources = {
    {
      name = 'nvim_lsp',
      option = {
        php = {
          keyword_pattern = [=[[\%(\$\k*\)\|\k\+]]=]
        }
      }
    }
  }
})
