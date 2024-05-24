return {
  'bitcode/manscope',
  name = 'manscope',
  dependencies = { 
  "nvim-telescope/telescope.nvim",
  "nvim-lua/plenary.nvim",
  },
  priority = 1000,
  config = function()
    require('manscope').setup({
      -- You can uncomment and set the database path or leave it to default
      database_path = '~/.local/share/nvim/lazy/manscope/lua/manscope/manscope.db',
      language = 'en',  -- Language setting for the man pages
      search_sensitivity = 'medium',  -- Adjust how sensitive the search is to variations
    })
    -- Set up the keybind for Manscope after the plugin is loaded
    vim.api.nvim_set_keymap('n', '<leader>fm', ':Telescope manscope<CR>', { noremap = true, silent = true })
  end
}
