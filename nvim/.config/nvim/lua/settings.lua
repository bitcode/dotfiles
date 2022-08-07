-- The utils module is required or imported at the top of the file

local utils = require('utils')

local cmd = vim.cmd -- vim.cmd is used to run Vim commands
local indent = 4


utils.opt('b', 'expandtab', true)
utils.opt('b', 'shiftwidth', indent)
utils.opt('b', 'smartindent', true)
utils.opt('b', 'tabstop', indent)
utils.opt('o', 'hidden', true)
utils.opt('o', 'ignorecase', true)
utils.opt('o', 'scrolloff', 4 )
utils.opt('o', 'shiftround', true)
utils.opt('o', 'smartcase', true)
utils.opt('o', 'splitbelow', true)
utils.opt('o', 'splitright', true)
utils.opt('o', 'wildmode', 'list:longest')
utils.opt('w', 'number', true)
utils.opt('w', 'relativenumber', true)
utils.opt('o', 'clipboard','unnamed,unnamedplus')

vim.cmd [[set mouse=a]]
vim.cmd [[set showmatch mat=2]]
vim.cmd [[set encoding=utf8]]
vim.cmd [[set backspace=indent,eol,start]]
vim.cmd [[set cursorline]]
vim.cmd [[set wildignore=*.o,*~,*/.git*,*/target/*]]

-- Highlight on yank
vim.cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- utils.opt helper function is used to set various Vim options at global, buffer, and window scopes.

vim.keymap.set('n', '<Leader>F5', ':silent update<Bar>silent !/usr/bin/chromium %:p &<CR>')
vim.keymap.set('n', '<Leader>F3', ':set hlsearch!<CR>')
