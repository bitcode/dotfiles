-- my understanding of this file is to config cmp but most of the config is
-- to make Luasnip work with cmp
local cmp = require('cmp')
local luasnip = require('luasnip')
local lspkind = require('lspkind')

cmp.setup {
  completion = {
      completeopt = 'menu,menuone,noinsert',
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
	["<C-n>"] = cmp.mapping.select_next_item(),
	["<A-o>"] = cmp.mapping.select_prev_item(),
	["<A-i>"] = cmp.mapping.select_next_item(),
	["<A-u>"] = cmp.mapping.confirm({ select = true }, { behavior = 'cmp.CofirmBehavior.Replace' }), -- added behavior to test
    --['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    --['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    --['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  },
  formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			preset = "codicons",
			maxwidth = 50,
			menu = {
				buffer = "[BUF]",
				nvim_lsp = "[LSP]",
				nvim_lua = "[API]",
				path = "[PATH]",
				luasnip = "[SNIP]",
			},
            symbol_map = {
      Text = "",
      Method = "",
      Function = "",
      Constructor = "",
      Field = "ﰠ",
      Variable = "",
      Class = "ﴯ",
      Interface = "",
      Module = "",
      Property = "ﰠ",
      Unit = "塞",
      Value = "",
      Enum = "",
      Keyword = "",
      Snippet = "",
      Color = "",
      File = "",
      Reference = "",
      Folder = "",
      EnumMember = "",
      Constant = "",
      Struct = "פּ",
      Event = "",
      Operator = "",
      TypeParameter = ""
  },
		}),
	},
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'cmdline' },
    { name = 'calc' },
    { name = 'spell' },
    { name = 'emoji' },
    { name = 'friendly-snippets' },
  },
    confirm_opts = {
    --behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
    -- experimental
    window = {
        completion = {
            border = 'rounded',
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
        },
        documentation = {
            border = 'rounded',
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
        },
    },
  -- Setup lspconfig.
--local capabilities = vim.lsp.protocol.make_client_capabilities()
--capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

  require('lspconfig')['emmet_ls'].setup {
    capabilities = capabilities
  },
  require('lspconfig')['tsserver'].setup {
    capabilities = capabilities
  },
  require('lspconfig')['sumneko_lua'].setup {
    capabilities = capabilities
  },
}
