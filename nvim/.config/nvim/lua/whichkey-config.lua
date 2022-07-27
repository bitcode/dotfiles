local wk = require("which-key")
local mappings = {
    f = {":Telescope find_files<cr>", "Telescope Find Files"},
    r = {":Telescope oldfiles<cr>", "Open Recent File"}
}
local opts = {prefix = '<leader>'}
wk.register(mappings, opts)
