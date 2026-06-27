return {
  "nvim-telescope/telescope.nvim",
  dependencies = { 'nvim-lua/plenary.nvim' },
  name = "telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = "Find files" },
    { "<leader>fg", function() require('telescope.builtin').live_grep() end,  desc = "Live grep" },
    { "<leader>fb", function() require('telescope.builtin').buffers() end,    desc = "Buffers" },
    { "<leader>fh", function() require('telescope.builtin').help_tags() end,  desc = "Help tags" },
  },
  config = function()
    local copy_full_path = function(prompt_bufnr)
      local entry = require("telescope.actions.state").get_selected_entry()
      if not entry then
        vim.notify("No entry selected", vim.log.levels.WARN)
        return
      end
      local path = entry.value or entry.path or entry[1]
      if not path then
        vim.notify("No path on entry: " .. vim.inspect(vim.tbl_keys(entry)), vim.log.levels.WARN)
        return
      end
      vim.fn.system({ "win32yank.exe", "-i", "--crlf" }, path)
      vim.notify("Copied: " .. path, vim.log.levels.INFO)
    end

    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
          "node_modules/.*",
          "^node_modules/",
          "vendor/.*",
          "%.git/.*",
          "venv/",
        },
        hidden = true,
        layout_strategy = "flex",
        layout_config = {
          height = function(_, max_lines)
            return math.floor(max_lines * 0.95)
          end,
          width = function(_, max_columns)
            return math.floor(max_columns * 0.95)
          end,
          horizontal = {
            prompt_position = "top",
            preview_width = 0.6,
          },
          vertical = {
            mirror = false,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        },
      },
      extensions = {
        file_browser = {
          hidden = true,
          mappings = {
            ["i"] = {
              ["<A-p>"] = copy_full_path,
            },
            ["n"] = {
              ["<A-p>"] = copy_full_path,
            },
          },
        },
      },
    }
  end
}
