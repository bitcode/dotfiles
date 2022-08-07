local wk = require("which-key")
local mappings = {
    ff = {":Telescope find_files<cr>", "Telescope Find Files"},
    fr = {":Telescope oldfiles<cr>", "Open Recent File"},
    fb = {":Telescope file_browser<cr>", "Built-in File Browser"},
    fh = {":Telescope help_tags<cr>", "Help Tags"},

}
local opts = {prefix = '<leader>'}
wk.register(mappings, opts)

--vim.api.nvim_set_keymap("n", "<space>fb", "<cmd>lua require 'telescope'.extensions.file_browser.file_browser()<CR>", {noremap = true})
-- ------ Navigate Vim Panes with H, J, K, L ----

-- nnoremap <C-J> <C-W><C-J>
-- nnoremap <C-K> <C-W><C-K>
-- nnoremap <C-L> <C-W><C-L>
-- nnoremap <C-H> <C-W><C-H>

-- --- Vim Diff ThePrimeagen keybinds ---

-- nmap <leader>gh :diffget //3<CR>
-- nmap <leader>gu :diffget //2<CR>
-- nmap <leader>gs :G<CR>

