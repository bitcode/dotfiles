return {
  "williamboman/mason.nvim",
  name = "mason.nvim",
  priority = 1000,
  config = function()
    require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
  end
}
