--local utils = require('utils')

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', test.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', test.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', test.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', test.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', test.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', test.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', test.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', test.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', test.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>wa', test.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wr', test.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '<space>wl', function()
    print(vim.inspect(test.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '<space>D', test.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', test.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', test.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', test.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', test.lsp.buf.formatting, bufopts)
end
