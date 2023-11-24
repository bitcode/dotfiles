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
--require("lazy").setup(plugins, opts)
--require("lazy").setup(require("plugins"))

vim.o.number = true  -- Enable line numbers

