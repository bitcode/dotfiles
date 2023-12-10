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
-- Load the plugins.lua file
require("lazy").setup(require("plugins"))
-- Load gruvbox
require("gruvbox").setup({
	transparent_mode = true,
})
vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])
-- Load Mason Config
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
-- Load Gen
require('gen').setup({})
-- Load Telescope
require('telescope').setup{
  defaults = {
    -- ...
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    }
  },
  extensions = {
    -- ...
  }
}
-- Load lspkind
require("lspkind").setup()
-- Load Mason LSPconfig
require("mason-lspconfig").setup()
-- Load CMPs
require('cmp').setup({
  sources = {
    { name = 'buffer' },
    { name = 'path' },
    { name = 'nvim-lua' },
    { name = 'nvim-lsp' },
    { name = 'luaSnip' },
    { name = 'cmp_luasnip' },
  },
})
require("lualine").setup()
-- Settings
vim.o.number = true  -- Enable line numbers
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- Telescope Settings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
