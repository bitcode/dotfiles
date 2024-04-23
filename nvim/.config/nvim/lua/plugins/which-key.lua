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

    -- convert window management prefix from <C-w> to <C-p>
vim.api.nvim_set_keymap('n', '<C-p>w', '<C-w>w', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>h', '<C-w>h', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>j', '<C-w>j', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>k', '<C-w>k', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>l', '<C-w>l', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>v', '<C-w>v', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>s', '<C-w>s', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>q', '<C-w>q', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>c', '<C-w>c', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>+', '<C-w>+', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>-', '<C-w>-', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>>', '<C-w>>', map_opts)
vim.api.nvim_set_keymap('n', '<C-p><', '<C-w><', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>=', '<C-w>=', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>T', '<C-w>T', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>o', '<C-w>o', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>r', '<C-w>r', map_opts)
vim.api.nvim_set_keymap('n', '<C-p>_', '<C-w>_', map_opts)

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
vim.api.nvim_set_keymap('n', '<leader>fc', ':FloatermNew bash -c \'gcc % && ./a.out; echo Press ENTER to close; read\'<CR>', map_opts)

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


    -- Window management mappings changed from <C-w> to <C-p>
    -- Define the new window management key mappings with descriptions
    local window_mappings = {
      ["w"] = { "<C-w>w", "Other window" },
      ["h"] = { "<C-w>h", "Left window" },
      ["j"] = { "<C-w>j", "Below window" },
      ["k"] = { "<C-w>k", "Above window" },
      ["l"] = { "<C-w>l", "Right window" },
      ["v"] = { "<C-w>v", "Split vertically" },
      ["s"] = { "<C-w>s", "Split horizontally" },
      ["q"] = { "<C-w>q", "Close window" },
      ["c"] = { "<C-w>c", "Close other windows" },
      ["+"] = { "<C-w>+", "Increase height" },
      ["-"] = { "<C-w>-", "Decrease height" },
      [">"] = { "<C-w>>", "Increase width" },
      ["<"] = { "<C-w><", "Decrease width" },
      ["="] = { "<C-w>=", "Equalize window sizes" },
      ["T"] = { "<C-w>T", "Break out into tab" },
      ["o"] = { "<C-w>o", "Close other windows" },
      ["r"] = { "<C-w>r", "Rotate windows downwards/rightwards" },
      ["_"] = { "<C-w>_", "Maximize height" },
    }

    -- Register window management keys with which-key
    which_key.register(window_mappings, { prefix = "<C-p>" })

 -- Keybindings for Telescope with actions to open in splits
    local telescope_mappings = {
      ["ff"] = { "<cmd>Telescope find_files<cr>", "Find Files" },
      ["fg"] = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
      ["fb"] = { "<cmd>Telescope buffers<cr>", "List Buffers" },
      ["fh"] = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
      ["fx"] = { "<cmd>Telescope find_files<cr>", "Find Files", {
        ["<C-x>"] = "select_horizontal",
        ["<C-v>"] = "select_vertical"
      }},
    }
    which_key.register(telescope_mappings, { prefix = "<leader>" })

-- which-key registration
which_key.register({
  f = {
    name = "File & Floaterm",
    fz = "Devdocs Open Current Float",
    fn = "New Floaterm",
    fp = "Previous Floaterm",
    ft = "Toggle Floaterm",
    fx = "Close Floaterm",
    fc = "Compile & Run",
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
