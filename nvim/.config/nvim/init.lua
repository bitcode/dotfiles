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
require('plugin.telescope')
require('lua.keymappings')
require('lsp_lua')
local luadev = require("lua-dev").setup({
  -- add any options here, or leave empty to use the default settings
  -- lspconfig = {
  --   cmd = {"lua-language-server"}
  -- },
})
pcall(require, "custom")
local lspconfig = require('lspconfig')
lspconfig.sumneko_lua.setup(luadev)
--vim.cmd [[packadd packer.nvim]]
--vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua

