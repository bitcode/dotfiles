#!/bin/bash

# Set the DISPLAY variable
export DISPLAY=:0

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/dotfiles/walls/"

# Select a random file from the directory
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the wallpaper using feh and log output
feh --bg-scale "$WALLPAPER" >> "$HOME/wallpaper_change.log" 2>&1
