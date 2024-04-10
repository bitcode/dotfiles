-- Keybinds

-- NvimDevDocs
require('nvim-devdocs')
vim.api.nvim_set_keymap('n', '<leader>fz', ':DevdocsOpenCurrentFloat<CR>', { silent = true })

-- Oil.nvim
require("oil")
-- Open oil.nvim in a floating window
vim.api.nvim_set_keymap('n', '<leader>of', ':lua require("oil").open_float()<CR>', { silent = true, noremap = true })

-- Toggle oil.nvim floating window
vim.api.nvim_set_keymap('n', '<leader>ot', ':lua require("oil").toggle_float()<CR>', { silent = true, noremap = true })

-- Close oil.nvim window
vim.api.nvim_set_keymap('n', '<leader>oc', ':lua require("oil").close()<CR>', { silent = true, noremap = true })

-- Additional keybinds for create, rename, delete, and move could be more complex and might involve custom functions
-- Example for delete (assuming 'actions.delete' exists):
-- vim.api.nvim_set_keymap('n', '<leader>od', ':lua require("oil.actions").delete()<CR>', { silent = true, noremap = true })
