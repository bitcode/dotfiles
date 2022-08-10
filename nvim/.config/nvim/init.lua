require('utils')
require('lsp_lua')
require('lspkind')
require('plugins')
require('lua-dev')
require('config')
require('config.colorscheme')
require('config.completion')
require('config.fugitive')
require('lualine-config')
require('settings')
require('lualine').setup()
require('whichkey-config')
require('telescope-config')
require('telescope-file-browser-config')
require'lspconfig'.tsserver.setup{}
require'cmp'.setup {
  sources = {
    { name = 'nvim-lsp' },
    { name = 'buffer'   },
    { name = 'path'   },
    { name = 'cmdline'   },
    { name = 'nvim_lsp_document_symbol' },
    { name = 'spell'   },
    { name = 'calc'   },
    { name = 'emoji'   },
    { name = 'nvim-lua' }
  }
}
require('cmp-config')
require('sumneko-config')
require('mason').setup()
require('mason-lspconfig').setup()
require("null-ls").setup()
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

