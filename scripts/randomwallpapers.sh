#!/bin/bash

# Load user profile to ensure environment variables are set
if [ -f "$HOME/.profile" ]; then
    source "$HOME/.profile"
fi

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/dotfiles/walls/"

# Select a random file from Directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using feh and log output
feh --bg-scale "$WALLPAPER" >> $HOME/wallpaper_change.log 2>&1
