return {
    "nvimtools/none-ls.nvim",
    dependencies = { 'jose-elias-alvarez/null-ls.nvim' },
    priority = 1000,
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
          sources = {
              null_ls.builtins.formatting.stylua,
          },
      })
    end
}

