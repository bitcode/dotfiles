return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local which_key = require('which-key')
    local map_opts = { noremap = true, silent = true }
    which_key.setup {}

    -- DevDocs Keybindings directly
vim.api.nvim_set_keymap('n', '<leader>fz', ':DevdocsOpenCurrentFloat<CR>', map_opts)

-- Oil.nvim Keybindings directly
vim.api.nvim_set_keymap('n', '<leader>of', ':lua require("oil").open_float()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>ot', ':lua require("oil").toggle_float()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>oc', ':lua require("oil").close()<CR>', map_opts)

-- Floaterm Keybindings directly
vim.api.nvim_set_keymap('n', '<leader>fn', ':FloatermNew<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>fp', ':FloatermPrev<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>ft', ':FloatermToggle<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>fx', ':FloatermKill<CR>', map_opts)

-- Telescope Keybindings
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>fb', ':Telescope buffers<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>fh', ':Telescope help_tags<CR>', map_opts)

-- Harpoon Keybindings
vim.api.nvim_set_keymap('n', '<leader>ui', ':lua require("harpoon.ui").toggle_quick_menu()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>m', ':lua require("harpoon.mark").add_mark()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>jn', ':lua require("harpoon.ui").next_buffer()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>jp', ':lua require("harpoon.ui").prev_buffer()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>ha', ':lua require("harpoon.ui").add_file()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>hr', ':lua require("harpoon.ui").remove_file()<CR>', map_opts)
vim.api.nvim_set_keymap('n', '<leader>hc', ':lua require("harpoon.term").sendCommand(1, "ls -La")<CR>', map_opts)

-- which-key registration
which_key.register({
  f = {
    name = "File & Floaterm",
    fz = "Devdocs Open Current Float",
    fn = "New Floaterm",
    fp = "Previous Floaterm",
    ft = "Toggle Floaterm",
    fx = "Close Floaterm",
    ff = "Find Files",  -- Telescope
    fg = "Live Grep",  -- Telescope
    fb = "Buffers",  -- Telescope
    fh = "Help Tags",  -- Telescope
  },
  o = {
    name = "Oil",
    of = "Open Oil Float",
    ot = "Toggle Oil Float",
    oc = "Close Oil Window",
    od = "Delete with Oil",  -- Ensure the function exists or remove this line if it does not
  },
  h = {
    name = "Harpoon",
    ui = "Toggle Quick Menu",
    m = "Add Mark",
    jn = "Next Buffer",
    jp = "Previous Buffer",
    ha = "Add File",
    hr = "Remove File",
    hc = "Send Command"
      }
    }, { prefix = "<leader>" })
  end
}
