require('lspconfig')['tsserver'].setup{
  capabilities = capabilities,
}

vim.api.nvim_set_keymap('n', '<leader>t', '<cmd>lua vim.lsp.buf.type_definition()<CR>',
