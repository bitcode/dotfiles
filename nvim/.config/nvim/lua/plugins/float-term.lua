return {
  'voldikss/vim-floaterm',
  name= "floaterm",
  priority = 1000,
  setup = function ()
    -- Set global configurations (optional)
    vim.g.floaterm_width = 0.9
    vim.g.floaterm_height = 0.9
    vim.g.floaterm_wintype = 'float'
    vim.g.floaterm_position = 'center'

end,
    -- Lazy loading: Automatically start floaterm when these commands are used
    --cmd = {'FloatermNew', 'FloatermToggle', 'FloatermPrev', 'FloatermNext'}
 }

