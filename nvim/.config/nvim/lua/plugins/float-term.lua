return {
  'voldikss/vim-floaterm',
  name= "floaterm",
  priority = 1000,
  setup = function ()
    -- Set global configurations (optional)
    vim.g.floaterm_width = 1.0
    vim.g.floaterm_height = 1.0
    vim.g.floaterm_wintype = 'float'
    vim.g.floaterm_position = 'center'

    -- Autoresponsive
    vim.api.nvim_exec([[
      autocmd VimResized * FloatermUpdate --height=0.9 --width=0.9
    ]], false)

end,
    -- Lazy loading: Automatically start floaterm when these commands are used
    --cmd = {'FloatermNew', 'FloatermToggle', 'FloatermPrev', 'FloatermNext'}
 }

