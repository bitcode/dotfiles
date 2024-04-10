vim.cmd("set expandtab")
vim.cmd("set shiftwidth=2")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd([[colorscheme gruvbox]])
--vim.o.background = "dark" -- or "light" for light mode
vim.o.number = true -- Enable line numbers
vim.api.nvim_set_hl(0, 'Normal', { ctermbg = 'none' })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "String", { fg = "#b8bb26" })
vim.api.nvim_set_hl(0, "Comment", { fg = "Grey70", bg = "none" })
