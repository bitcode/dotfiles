#!/bin/bash

# Define the plugins and their git repositories
declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search"
    ["zsh-fzf-history-search"]="https://github.com/joshskidmore/zsh-fzf-history-search"
    ["zsh-vi-mode"]="https://github.com/jeffreytse/zsh-vi-mode"
)

# Create the plugins directory if it doesn't exist
mkdir -p ~/.zsh/plugins

# Clone each plugin
for plugin in "${!plugins[@]}"; do
    git clone "${plugins[$plugin]}" ~/.zsh/plugins/$plugin
done

echo "All plugins have been installed in ~/.zsh/plugins"
