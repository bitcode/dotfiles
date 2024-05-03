return {
  "luckasRanarison/nvim-devdocs",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    wrap = true,
    float_win = {
      relative = "editor",
      -- Dynamically calculate height and width based on available space
      height = 50,
      width = 100,
      border = "rounded",
    },
  }
}
