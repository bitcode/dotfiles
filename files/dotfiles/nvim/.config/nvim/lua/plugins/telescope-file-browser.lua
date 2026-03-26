return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  lazy = true,
  config = function()
    require('telescope').setup {
      extensions = {
        file_browser = {
          hidden = true,
        },
      },
    }
    require('telescope').load_extension('file_browser')
    vim.api.nvim_set_keymap(
      "n",
      "<space>fb",
      ":Telescope file_browser<CR>",
      { noremap = true }
    )
  end
}
