# Custom Neovim Keybindings

## General

- `<C-h>`: Move to left split
- `<C-j>`: Move to bottom split
- `<C-k>`: Move to top split
- `<C-l>`: Move to right split

## Leader Key

The leader key is set to `<Space>`.

## Window Management (Changed from <C-w> to <C-p>)

- `<C-p>w`: Switch to other window
- `<C-p>h`: Move to left window
- `<C-p>j`: Move to window below
- `<C-p>k`: Move to window above
- `<C-p>l`: Move to right window
- `<C-p>v`: Split window vertically
- `<C-p>s`: Split window horizontally
- `<C-p>q`: Close current window
- `<C-p>c`: Close all other windows
- `<C-p>+`: Increase window height
- `<C-p>-`: Decrease window height
- `<C-p>>`: Increase window width
- `<C-p><`: Decrease window width
- `<C-p>=`: Equalize window sizes
- `<C-p>T`: Break out into new tab
- `<C-p>o`: Close all other windows
- `<C-p>r`: Rotate windows downwards/rightwards
- `<C-p>_`: Maximize window height

## File and Floaterm

- `<leader>fz`: Open DevDocs for current file in float
- `<leader>fn`: New Floaterm
- `<leader>fp`: Previous Floaterm
- `<leader>ft`: Toggle Floaterm
- `<leader>fx`: Close Floaterm
- `<leader>fc`: Compile and run current file

## Telescope

- `<leader>ff`: Find files
- `<leader>fg`: Live grep
- `<leader>fb`: List buffers
- `<leader>fh`: Help tags

## Oil

- `<leader>of`: Open Oil float
- `<leader>ot`: Toggle Oil float
- `<leader>oc`: Close Oil window

## Harpoon

- `<leader>ui`: Toggle quick menu
- `<leader>m`: Add mark
- `<leader>jn`: Next buffer
- `<leader>jp`: Previous buffer
- `<leader>ha`: Add file
- `<leader>hr`: Remove file
- `<leader>hc`: Send command to terminal

## LSP

- `<leader>e`: Open diagnostics float
- `<leader>dp`: Go to previous diagnostic
- `<leader>dn`: Go to next diagnostic
- `<leader>q`: Open diagnostic loclist
- `<leader>ff`: Format document
- `<leader>fs`: Format document (sync)
- `<leader>gd`: Go to definition
- `<leader>gD`: Go to declaration
- `<leader>gi`: Go to implementation
- `<leader>gr`: Go to references
- `<leader>r`: Rename
- `<leader>a`: Code action
- `<leader>wa`: Add workspace folder
- `<leader>wr`: Remove workspace folder
- `<leader>wl`: List workspace folders
- `<leader>lc`: Close diagnostic loclist

## GitGutter

- `<leader>gn`: Next hunk
- `<leader>gp`: Previous hunk
- `<leader>gs`: Stage hunk
- `<leader>gu`: Undo hunk
- `<leader>gP`: Preview hunk

## Miscellaneous

- `<leader><CR>`: Insert new line below without entering insert mode
- `<leader><S-CR>`: Insert new line above without entering insert mode


## Save with sudo

    - `:w !sudo tee %` to save as admin

