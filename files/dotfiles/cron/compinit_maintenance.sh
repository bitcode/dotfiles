#!/bin/bash

ZSHRC="$HOME/.zshrc"
ZCOMPDUMP_DIR="$HOME/.zsh"

# Ensure the zshrc file exists
if [[ ! -f $ZSHRC ]]; then
    echo "Error: $ZSHRC not found!"
    exit 1
fi

# Load zsh environment to use zsh commands
zsh -c "
    autoload -Uz compinit
    compinit -d '$ZCOMPDUMP_DIR/.zcompdump'
    
    # Run compdump, compdef, and zrecompile
    autoload -Uz compdump
    compdump
    
    compdef
    zrecompile
"

echo "Maintenance tasks (compdump, compdef, zrecompile) completed."
