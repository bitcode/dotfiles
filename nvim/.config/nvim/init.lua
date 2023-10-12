-- Set up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Load the plugins.lua file
require("lazy").(plugins, opts)  -- Use the load_plugins function here
--local plugins = require("plugins").load_plugins  -- This gets the load_plugins function

-- Set up lazy.nvim with your plugins
--local opts = {}  -- This could be a table of options if needed

colorscheme = { "themer_ayu_dark" }
vim.o.number = true  -- Enable line numbers
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })

