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
}
