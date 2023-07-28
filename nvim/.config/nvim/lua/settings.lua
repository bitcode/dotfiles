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

-- matchpairs configuration

vim.g.vim_matchtag_enable_by_default = true

-- utils.opt helper function is used to set various Vim options at global, buffer, and window scopes.

-- navigate panes
local function move_window(direction)
  local winnr = vim.api.nvim_win_get_number(vim.api.nvim_get_current_win())
  local winlist = vim.api.nvim_list_wins()
  local new_winnr = winnr
  if direction == "left" then
    new_winnr = winnr - 1
  elseif direction == "down" then
    new_winnr = winnr + 1
  elseif direction == "up" then
    new_winnr = winnr - winlist[1] + 1
  elseif direction == "right" then
    new_winnr = winnr + winlist[1] - 1
  end
  if new_winnr >= 1 and new_winnr <= #winlist then
    vim.api.nvim_set_current_win(winlist[new_winnr])
  end
end

vim.keymap.set("n", "<C-h>", function() move_window("left") end)
vim.keymap.set("n", "<C-j>", function() move_window("down") end)
vim.keymap.set("n", "<C-k>", function() move_window("up") end)
vim.keymap.set("n", "<C-l>", function() move_window("right") end)
