return {
  'nvimdev/lspsaga.nvim',
  name = "lspsaga",
  priority = 1000,
  dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
  },
  config = function()
      require('lspsaga').setup({
      symbol_in_winbar = {
      enable = true,
      separator = ' › ',
      show_file = true,
      color_mode == true
  },
  diagnostic = {
      show_code_action = true,
      jump_num_shortcut = true,
      max_width = 0.8,
      max_height = 0.6,
      border_follow = true,
      diagnostic_only_current = false  -- Show diagnostics for all lines, not just the current line
  },
  code_action = {
      num_shortcut = true,
      show_server_name = true
  },
  finder = {
      max_height = 0.6,
      max_width = 0.8,
      default = 'ref+imp',  -- Default to show references and implementations
      methods = {
          tyd = 'textDocument/typeDefinition'  -- Add type definitions to the search
      }
  },
  hover = {
      max_width = 0.8,
      max_height = 0.8,
      open_link = 'gx',  -- Set to 'gx' or another shortcut for opening links
  },
  rename = {
      in_select = true,
      auto_save = false  -- Set to true if you want automatic saving after renaming
  }
    })
  end,
}
