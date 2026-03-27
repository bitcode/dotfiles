return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    name = "mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
        local servers = {
            'lua_ls',
            'omnisharp',
            'cssmodules_ls',
            'emmet_language_server',
            'html',
            'pylsp',
            'tailwindcss',
            'ts_ls',
            'gopls',
            'htmx',
            'clangd',
            'bashls',
            'dockerls',
            'jsonls',
            'rust_analyzer',
            'taplo',
            'yamlls',
            'markdown_oxide',
        }
        if vim.fn.has("win32") ~= 1 then
            table.insert(servers, 'asm_lsp')
        end
        require("mason-lspconfig").setup {
            ensure_installed = servers,
        }
    end
}
