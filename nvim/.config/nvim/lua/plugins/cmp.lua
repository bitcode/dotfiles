return {
  "hrsh7th/nvim-cmp",
  name = "nvim-cmp",
  priority = 1000,
  config = function()
    local cmp = require'cmp'

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
        --native_menu = false,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      }),
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'cody', keyword_length = 2 },
        { name = 'nvim-lsp' },
        { name = 'buffer' },
        { name = 'cmdline' },
        { name = 'path' },
        { name = 'nvim-lua' },
        { name = 'lspkind' },
        { name = 'git' },
        { name = 'nvim_lsp' },
        { name = 'cmdline_history' },
        { name = 'nvim_lsp_document_symbol' },
        { name = 'nvim-lsp-signature-help' },
      })
    })
    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' }
      }
    })
    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' }
      }, {
        { name = 'cmdline' }
      })
    }) 
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    require('lspconfig')['lua_ls'].setup {
      capabilities = capabilities
    }
    require('lspconfig')['cssmodules_ls'].setup {
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
  end
}