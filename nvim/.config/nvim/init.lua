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

-- Setup LuaRocks
local function setup_luarocks()
    local home = os.getenv("HOME")
    local luarocks_path = home .. '/.luarocks/share/lua/5.1/?.lua;' .. home .. '/.luarocks/share/lua/5.1/?/init.lua;'
    local luarocks_cpath = home .. '/.luarocks/lib/lua/5.1/?.so;'

    package.path = package.path .. ';' .. luarocks_path
    package.cpath = package.cpath .. ';' .. luarocks_cpath
end

-- Initialize LuaRocks paths
setup_luarocks()

-- Global leader settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Setup plugins and settings
require("lazy").setup("plugins")
require("settings")
require('lualine').setup()
