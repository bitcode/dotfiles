-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use { 'sainnhe/gruvbox-material' }
  use {
      'nvim-telescope/telescope.nvim',
      requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use {'iamcco/markdown-preview.nvim', run = 'cd app && yarn install', cmd = 'MarkdownPreview'}
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'neovim/nvim-lspconfig' }
  use { 'nvim-lua/completion-nvim' }
  use { 'tjdevries/nlua.nvim' }
  use "folke/lua-dev.nvim" -- fix Sumneko 
end)

