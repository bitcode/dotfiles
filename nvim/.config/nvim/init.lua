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

require("lazy").setup("plugins", {
    debug = false,  -- ensure this is disabled
    log_level = "warn",  -- log only warnings and errors
})

require("settings")
require("settings")require('lualine').setup()
require("settings")-- Load LSP configuration
require("settings")require("settings.lspconfig")
require("settings")
require("settings")vim.api.nvim_create_autocmd("BufRead", {
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                local ft = vim.bo[bufnr].filetype
                if _G.filetype_to_lsp[ft] then
                    _G.filetype_to_lsp[ft]()
                end
            end
        end, 100)
    end
})

vim.api.nvim_create_user_command('LspInfo', function()
    local clients = vim.lsp.get_active_clients()
    if #clients == 0 then
        vim.notify("No LSP clients running.", vim.log.levels.WARN)
        return
    end

    for _, client in ipairs(clients) do
        local msg = string.format(
            "Client: %s\nID: %d\nRoot dir: %s\nFiletypes: %s",
            client.name,
            client.id,
            client.root_dir or "[No root dir]",
            table.concat(client.config.filetypes or {}, ", ")
        )
        vim.notify(msg, vim.log.levels.INFO)
    end
end, {})

vim.api.nvim_create_user_command('CheckLspInstall', function()
    local mason_registry = require("mason-registry")
    local packages = {
        "lua-language-server",
        "clangd",
        "omnisharp",
        "pyright",
        "typescript-language-server",
        "css-lsp",
        "bash-language-server",
        "dockerfile-language-server",
        "html-lsp",
        "asm-lsp",
        "gopls",
        "typescript-language-server",
        "rust-analyzer",
        "json-lsp",
        "marksman",
        "taplo",
        "yaml-language-server",
    }

    for _, name in ipairs(packages) do
        local package = mason_registry.get_package(name)
        if package then
            local is_installed = package:is_installed()
            vim.notify(string.format(
                "LSP %s is %s",
                name,
                is_installed and "installed" or "not installed"
            ), is_installed and vim.log.levels.INFO or vim.log.levels.WARN)
        else
            vim.notify(string.format(
                "Package %s not found in Mason registry",
                name
            ), vim.log.levels.ERROR)
        end
    end
end, {})

vim.api.nvim_create_user_command('CheckCurrentLsp', function()
    local ft = vim.bo.filetype
    if ft == '' then
        vim.notify("No filetype detected for current buffer", vim.log.levels.WARN)
        return
    end

    local available_servers = vim.lsp.get_active_clients({ bufnr = 0 })
    if #available_servers == 0 then
        vim.notify("No LSP servers attached to current buffer", vim.log.levels.WARN)
    else
        for _, server in ipairs(available_servers) do
            vim.notify(string.format(
                "LSP server '%s' is attached to current buffer",
                server.name
            ), vim.log.levels.INFO)
        end
    end

    -- Check if filetype has a configured LSP
    if _G.filetype_to_lsp and _G.filetype_to_lsp[ft] then
        vim.notify(string.format(
            "Filetype '%s' has LSP configuration available",
            ft
        ), vim.log.levels.INFO)
    else
        vim.notify(string.format(
            "No LSP configuration found for filetype '%s'",
            ft
        ), vim.log.levels.WARN)
    end
end, {})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})

-- Add diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local function safe_setup(server_name, setup_fn)
    local ok, err = pcall(setup_fn)
    if not ok then
        vim.notify(
            string.format("Error setting up LSP %s: %s", server_name, err),
            vim.log.levels.ERROR
        )
    end
end





