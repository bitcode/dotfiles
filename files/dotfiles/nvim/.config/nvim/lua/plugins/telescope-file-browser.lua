return {
  "nvim-telescope/telescope-file-browser.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>fB", ":Telescope file_browser<CR>", desc = "File browser" },
  },
  config = function()
    require("telescope").load_extension("file_browser")
  end,
}
