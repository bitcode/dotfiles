return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  lazy = true,
  config = function()
    -- Custom action: copy the full filepath of the selected entry to clipboard
    local copy_path = function(prompt_bufnr)
      local entry = require("telescope.actions.state").get_selected_entry()
      if entry == nil then return end
      -- telescope-file-browser entries expose the absolute path on entry.path
      local path = entry.path or entry.filename
      if path == nil then return end
      vim.fn.setreg("+", path)  -- system clipboard
      vim.fn.setreg('"', path)  -- unnamed register (p to paste inside nvim)
      vim.notify("Copied: " .. path, vim.log.levels.INFO)
    end

    require("telescope").setup {
      extensions = {
        file_browser = {
          hidden = true,
          mappings = {
            -- <Alt-p> in insert mode, p in normal mode
            ["i"] = {
              ["<A-p>"] = copy_path,
            },
            ["n"] = {
              ["p"] = copy_path,
            },
          },
        },
      },
    }
    require("telescope").load_extension("file_browser")

    vim.api.nvim_set_keymap(
      "n",
      "<space>fb",
      ":Telescope file_browser<CR>",
      { noremap = true }
    )
  end,
}
