return  { 
  {
  "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...
  },
  {
    "williamboman/mason.nvim"
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
-- or                              , branch = '0.1.x',
      dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    'David-Kunz/gen.nvim',
    opts = {
	model = "orca2",
  }, 
  },
  {
    'hrsh7th/nvim-cmp'
  },
  {
    "williamboman/mason-lspconfig.nvim"
  },
  {
    "neovim/nvim-lspconfig"
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", opts = true }
  },
  {
    "hrsh7th/cmp-buffer"
  },
  {
    "hrsh7th/cmp-path"
  },
  {
    "hrsh7th/cmp-nvim-lua"
  },
  {
    "hrsh7th/cmp-nvim-lsp"
  },
  {
    "L3MON4D3/LuaSnip"
  },
  {
    "onsails/lspkind.nvim"
  },
  {
    "saadparwaiz1/cmp_luasnip"
  },
  {
    "onsails/lspkind.nvim"
  }
}
