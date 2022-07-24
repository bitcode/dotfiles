-- Map leader to space
vim.g.mapleader = ' '

local fn = vim.fn
local execute = vim.api.nvim_command

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
end)
require('settings')
require('config')
require('config.colorscheme')  -- color scheme
require('config.completion')   -- completion
require('config.fugitive')     -- fugitive
require('plugins')
require('keymappings')
require('lsp_lua')
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

