#!/bin/bash

# Check if Hyprland is running
if pgrep -x "Hyprland" > /dev/null; then

    # If Hyprland is running, start tmux
    ZSH_TMUX_AUTOSTART=true
else
    # If Hyprland is not running, do not start tmux
    ZSH_TMUX_AUTOSTART=false
fi

export ZSH_TMUX_AUTOSTART


