require('utils')
require('lsp_lua')
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
require'lspconfig'.sumneko_lua.setup{
settings = {
        Lua = {
        runtime = {
            -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            -- Setup your lua path
            path = '/usr/bin/lua',
        },
        diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'},
        },
        workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
            enable = false,
        },
        },
    },
}
