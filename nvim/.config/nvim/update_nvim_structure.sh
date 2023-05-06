#!/bin/bash

# Change to your Neovim configuration directory
cd ~/dotfies/nvim/.config/nvim


# Create the new directory structure
mkdir -p lua/config
mkdir -p lua/lsp
mkdir -p lua/plugins
mkdir -p lua/snippets

# Move configuration files to appropriate folders
mv lua/emmet-ls-config.lua lua/config/
mv lua/gitsigns-config.lua lua/config/
mv lua/lualine-config.lua lua/config/
mv lua/luasnip-config.lua lua/config/
mv lua/null-ls-config.lua lua/config/
mv lua/settings.lua lua/config/
mv lua/sumneko-config.lua lua/config/
mv lua/tabnine-config.lua lua/config/
mv lua/telescope-config.lua lua/config/
mv lua/telescope-file-browser-config.lua lua/config/
mv lua/toggleterm-config.lua lua/config/
mv lua/whichkey-config.lua lua/config/

mv lua/ls-emmet.lua lua/lsp/
mv lua/lsp_lua lua/lsp/

mv lua/plugins.lua lua/plugins/

mv lua/cmp-config.lua lua/snippets/
