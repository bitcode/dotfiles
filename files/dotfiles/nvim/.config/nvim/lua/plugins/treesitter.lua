return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Install parsers for commonly used languages
            local install = require("nvim-treesitter.install")
            local parsers = { "lua", "javascript", "asm", "c", "html", "go", "rust", "c_sharp" }
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.tbl_filter(function(p)
                return not vim.tbl_contains(installed, p)
            end, parsers)
            if #to_install > 0 then
                install.install(to_install)
            end
        end,
    }
}
