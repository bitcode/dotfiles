return {
  "wincent/terminus",
  name = "terminus",
  priority = 1000,
  config = function()
    -- Configure the cursor shapes before plugin initialization
    vim.g.TerminusCursorShape = 1 -- Enable cursor shape changes
    vim.g.TerminusInsertCursorShape = 1 -- Set cursor to 'bar' shape in insert mode
    vim.g.TerminusNormalCursorShape = 0 -- Set cursor to 'block' shape in normal mode
  end,
}
