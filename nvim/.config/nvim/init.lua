require('utils')
require('toggleterm-config')
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
require('telescope')
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
    { name = 'nvim_lsp_signature_help' },
    { name = 'spell'   },
    { name = 'calc'   },
    { name = 'emoji'   },
    { name = 'cmp_tabnine' },
    { name = 'nvim-lua' }
  }
}
require('cmp-config')
require('sumneko-config')
require('mason').setup()
require('mason-lspconfig').setup()
require("null-ls").setup({
    sources = {
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.formatting.prettier,
    },
})
require('null-ls-config')
require('cmp_nvim_lsp')
require("toggleterm").setup()
require'cmp'.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' },
    { name = 'nvim_lsp_document_symbol' }
  }
})
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
},
}
require('matchparen').setup({
    on_startup = true, -- Should it be enabled by default
    hl_group = 'MatchParen', -- highlight group for matched characters
    augroup_name = 'matchparen',  -- almost no reason to touch this unless there is already augroup with such name
})
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- 
require'lspconfig'.tsserver.setup {
  capabilities = capabilities,
}

-- The following example advertise capabilities to `clangd`.
require'lspconfig'.emmet_ls.setup {
  capabilities = capabilities,
}

-- The following example advertise capabilities to `clangd`.
require'lspconfig'.marksman.setup {
  capabilities = capabilities,
}
