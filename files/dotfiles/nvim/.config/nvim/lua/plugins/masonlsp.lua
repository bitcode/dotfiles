return {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    name = "mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
        require("mason-lspconfig").setup {
            ensure_installed = {
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
                'asm_lsp',
                'bashls',
                'dockerls',
                'jsonls',
                'rust_analyzer',
                'taplo',
                'yamlls',
                'markdown_oxide',
            }
        }
    end
}
