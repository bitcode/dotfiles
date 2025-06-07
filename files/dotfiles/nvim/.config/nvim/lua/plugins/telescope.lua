return {
  "nvim-telescope/telescope.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  name = "telescope.nvim",
  priority = 1000,
  config = function()
    local builtin = require('telescope.builtin')
    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
      "node_modules/.*",
      "^node_modules/",
      "vendor/.*",
      "%.git/.*",
      "venv/"
      -- Add other patterns as needed
      },
      hidden = true,
      layout_strategy = "flex", -- Automatically switch between horizontal and vertical layouts
      layout_config = {
        height = function(_, max_lines)
          return math.floor(max_lines * 0.95) -- Set height to 95% of available space
        end,
        width = function(_, max_columns)
          return math.floor(max_columns * 0.95) -- Set width to 95% of available space
        end,
        horizontal = {
          prompt_position = "top", -- Place prompt at the top in horizontal layout
          preview_width = 0.6, -- Allocate 60% of width to preview window
        },
        vertical = {
          mirror = false, -- Place preview below results in vertical layout
        },
      },
      },
    }
    -- require('telescope').load_extension('manscope')
    -- Keep your existing builtin picker calls here
    -- For example: 
    -- builtin.find_files()
    -- builtin.live_grep()
    -- ...
  end
}
