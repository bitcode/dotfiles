return {
  'theprimeagen/harpoon',
  name = "harpoon",
  priority = 1000,
  config = function()
    require('harpoon').setup()
    local mark = require('harpoon.mark').add_mark
    local ui = require('harpoon.ui')

    -- toggle menus
    vim.keymap.set('n', '<leader>ui', function() ui.toggle_quick_menu() end, {silent = true})
    vim.keymap.set('n', '<leader>m', function() mark() end, {silent = true})

    -- Harpoon next and previous
    vim.keymap.set('n', '<leader>jn', function() require('harpoon.ui').next_buffer() end, {silent = true})
    vim.keymap.set('n', '<leader>jp', function() require('harpoon.ui').prev_buffer() end, {silent = true})

    -- Harpoon add and remove
    vim.keymap.set('n', '<leader>ha', function() require('harpoon.ui').add_file() end, {silent = true})
    vim.keymap.set('n', '<leader>hr', function() require('harpoon.ui').remove_file() end, {silent = true})

    -- Harpoon commands to terminal
    vim.keymap.set('n', '<leader>hc', function() require('harpoon.term').sendCommand(1, "ls -La") end, {silent = true})

    -- Harpoon tmux commands
  end,
}
