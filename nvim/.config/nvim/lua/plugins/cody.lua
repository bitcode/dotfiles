return {
  "sourcegraph/sg.nvim",
  dependencies = { "nvim-lua/plenary.nvim", --[[ "nvim-telescope/telescope.nvim ]] },
  name = "sg.nvim",
  priority = 1000,
  config = function()
    require("sg").setup {
    enable_cody = true,
    accpet_tos = true,
    }
  end
}
