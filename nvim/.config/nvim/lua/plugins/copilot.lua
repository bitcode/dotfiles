return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = { "InsertEnter", "LspAttach"},
  fix_pairs = true,
  config = function()
    require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })
  end,
}
