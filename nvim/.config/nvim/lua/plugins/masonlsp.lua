return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "neovim/nvim-lspconfig", "nvimtools/none-ls.nvim" },
  name = "mason-lspconfig.nvim",
  priority = 1000,
  config = function()
    require("mason-lspconfig").setup {
  ensure_installed = { 'lua_ls', 'cssmodules_ls', 'emmet_language_server', 'html', 'pylsp', 'tailwindcss', 'ts_ls', 'gopls', 'htmx', 'clangd' }
    }
end
}
