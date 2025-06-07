return {
  'airblade/vim-gitgutter',
  name = 'vim-gitgutter',
  priority = 1000,
  config = function()
    -- Set options using the vim global object
    vim.o.updatetime = 100  -- Reduce the updatetime for more responsive gutter updates
    vim.o.signcolumn = "yes"  -- Ensure the signcolumn is always on

    -- Setting vim-gitgutter plugin variables using the vim global object
    vim.g.gitgutter_max_signs = 1000  -- Configure maximum signs to display to prevent slowdown
    vim.g.gitgutter_sign_added = '+'  -- Set custom sign symbols for added lines
    vim.g.gitgutter_sign_modified = '~'  -- Set custom sign symbols for modified lines
    vim.g.gitgutter_sign_removed = '-'  -- Set custom sign symbols for removed lines
  end
}
