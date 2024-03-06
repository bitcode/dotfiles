return {
      "nvimtools/none-ls.nvim",
    dependencies = { 'jose-elias-alvarez/null-ls.nvim' },
    priority = 1000,
    config = function()
      local null_ls = require("null-ls")
      local methods = null_ls.methods
      local sources = null_ls.builtins


      null_ls.setup({
          sources = {
              null_ls.builtins.formatting.stylua.with({
                filetypes = {"lua"}
                    }),
              null_ls.builtins.code_actions.gitsigns,
              null_ls.builtins.code_actions.refactoring,
              sources.formatting.prettier.with({
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }, -- Filetypes
      method = methods.FORMATTING, -- Trigger on LSP's format request
    })
          },
      })
    end
}

