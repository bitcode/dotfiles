-- Keybinds

-- NvimDevDocs
require('nvim-devdocs')
vim.api.nvim_set_keymap('n', '<leader>fz', ':DevdocsOpenCurrentFloat<CR>', { silent = true })
