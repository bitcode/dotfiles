return {
    "hrsh7th/nvim-cmp",
    name = "cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
        local cmp = require 'cmp'
        local lspkind = require('lspkind')

        -- Global cmp setup
        cmp.setup({
            formatting = {
                format = function(entry, vim_item)
                    -- Prevent error when no LSP client is attached
                    if entry.source.name == 'nvim_lsp_document_symbol' and not vim.lsp.get_clients() then
                        return nil -- Skip this source if no LSP clients are available
                    end
                    return lspkind.cmp_format({
                        fields = { 'menu', 'abbr', 'kind' },
                        mode = 'symbol',
                        ellipsis_char = '...',
                        show_labelDetails = true,
                        symbol_map = {
                            Copilot = "",
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
                    })(entry, vim_item)
                end,
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users
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
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = "copilot",  group_index = 2 },
                { name = 'nvim_lsp', keyword_length = 2 },
                {
                    name = 'nvim_lsp_document_symbol',
                    keyword_length = 2,
                    is_available = function()
                        return vim.tbl_isempty(vim.lsp.get_clients()) == false
                    end
                },
                { name = 'nvim-lsp-signature-help', keyword_length = 2 },
                { name = 'luasnip',                 keyword_length = 2 },
                { name = 'buffer',                  keyword_length = 2 },
                { name = 'path',                    keyword_length = 2 },
                { name = 'nvim-lua',                keyword_length = 2 },
                { name = 'git',                     keyword_length = 2 },
                { name = 'cmdline_history',         keyword_length = 4 },
            })
        })

        -- Cmdline setup for '/' and ':' commands
        cmp.setup.cmdline('/', {
            sources = cmp.config.sources({
                { name = 'nvim_lsp_document_symbol' },
                { name = 'nvim-lsp-signature-help' },
            }, {
                { name = 'buffer' }
            })
        })

        cmp.setup.cmdline(':', {
            sources = cmp.config.sources({
                { name = 'path' },
                { name = 'nvim-lsp-signature-help' },
                { name = 'cmdline' }
            })
        })
    end
}
