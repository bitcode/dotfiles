vim.cmd("set expandtab")
vim.cmd("set shiftwidth=2")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd([[colorscheme gruvbox]])
vim.cmd [[
  " Dim the colors a bit and apply specific colors for added, modified, and removed lines
  highlight GitGutterAdd guifg=#689d6a guibg=None " dim green for added lines
  highlight GitGutterChange guifg=#a89984 guibg=None " use normal text color for modified lines
  highlight GitGutterDelete guifg=#cc241d guibg=None " dim red for removed lines
]]
vim.cmd [[
  highlight DiagnosticError guifg=#FF5555 ctermfg=203
  highlight DiagnosticWarn guifg=#FFB86C ctermfg=215
  highlight DiagnosticInfo guifg=#8BE9FD ctermfg=117
  highlight DiagnosticHint guifg=#50FA7B ctermfg=84
]]
--vim.o.background = "dark" -- or "light" for light mode
vim.api.nvim_set_keymap('n', '<leader>x', '<cmd>lclose<CR>', { noremap = true, silent = true })
vim.o.number = true -- Enable line numbers
vim.api.nvim_set_hl(0, 'Normal', { ctermbg = 'none' })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "none" })
vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "String", { fg = "#b8bb26" })
vim.api.nvim_set_hl(0, "Comment", { fg = "Grey70", bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.opt.winblend = 20
vim.api.nvim_set_hl(0, 'FloatBorder', {bg='#3B4252', fg='#5E81AC'})
vim.api.nvim_set_hl(0, 'NormalFloat', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeNormal', {bg='#3B4252'})
vim.api.nvim_set_hl(0, 'TelescopeBorder', {bg='#3B4252'})
-- Define a function to set keymaps easily
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
-- Keybindings to move between splits
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
