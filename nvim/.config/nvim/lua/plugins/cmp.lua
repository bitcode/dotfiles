return {
  "hrsh7th/nvim-cmp",
  name = "cmp",
  priority = 1000,
  config = function()
    local cmp = require'cmp'
    local lspkind = require('lspkind')
    cmp.setup({
      formatting = {
        format = lspkind.cmp_format({
          fields = {'menu', 'abbr', 'kind'},
          mode = 'symbol',
          ellipsis_char = '...',
          show_labelDetails = true,
    lspkind.init({
    symbol_map = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "",
    },
    })
        })
      }
    })
    cmp.setup({
      snippet = {
       -- REQUIRED - you must specify a snippet engine
       expand = function(args)
         require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
         -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
         -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
       end,
      },
     window = {
       completion = cmp.config.window.bordered(),
       documentation = cmp.config.window.bordered(),
     },
     experimental = {
       ghost_text = true,
       native_menu = false,
     },
     mapping = cmp.mapping.preset.insert({
       ['<C-b>'] = cmp.mapping.scroll_docs(-4),
       ['<C-f>'] = cmp.mapping.scroll_docs(4),
       ['<C-Space>'] = cmp.mapping.complete(),
       ['<C-e>'] = cmp.mapping.abort(),
       ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
     }),
     sources = cmp.config.sources({
       { name = 'nvim_lsp', keyword_length = 2 },
       { name = 'nvim_lsp_document_symbol', keyword_length = 2 },
       { name = 'nvim-lsp-signature-help', keyword_length = 2 },
       { name = 'luasnip', keyword_length = 2 },
       { name = 'buffer', keyword_length = 2 },
       --{ name = 'cmdline' },
       { name = 'path', keyword_length = 2 },
       { name = 'nvim-lua', keyword_length = 2 },
       { name = 'lspkind', keyword_length = 2 },
       { name = 'git', keyword_length = 2 },
       { name = 'cmdline_history', keyword_length = 4 },
      })
    })
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.hoverProvider = true
      capabilities.definitionProvider = true
      capabilities.referencesProvider = true
      capabilities.documentHighlightProvider = true
      capabilities.documentSymbolProvider = true
      capabilities.workspaceSymbolProvider = true
      capabilities.codeActionProvider = true
      capabilities.renameProvider = true
      capabilities.signatureHelpProvider = true
    require('lspconfig')['lua_ls'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['cssmodules_ls'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['bashls'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['emmet_language_server'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['html'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['pylsp'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['tailwindcss'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['tsserver'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['gopls'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['htmx'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['clangd'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['asm_lsp'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['dockerls'].setup {
      capabilities = capabilities
    }
  end
}
