return {
  { "hrsh7th/cmp-buffer",                      name = "buffer",                    lazy = true },
  { "hrsh7th/cmp-cmdline",                     name = "cmdline",                   lazy = true },
  { "hrsh7th/cmp-path",                        name = "path",                      lazy = true },
  { "hrsh7th/cmp-nvim-lua",                    name = "nvim-lua",                  lazy = true },
  { "hrsh7th/cmp-nvim-lsp",                    name = "nvim_lsp",                  lazy = true },
  { "petertriho/cmp-git",                      name = "git",                       lazy = true },
  { "Dynge/gitmoji.nvim",                      name = "gitmoji",                   lazy = true },
  { "dmitmel/cmp-cmdline-history",             name = "cmdline_history",           lazy = true },
  { "hrsh7th/cmp-nvim-lsp-document-symbol",    name = "nvim_lsp_document_symbol",  lazy = true },
  { "hrsh7th/cmp-nvim-lsp-signature-help",     name = "nvim-lsp-signature-help",   lazy = true },
  { "onsails/lspkind.nvim",                    name = "lspkind",                   lazy = true },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    lazy = true,
    config = function()
      require("copilot_cmp").setup()
    end
  }
}
