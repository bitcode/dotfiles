#!/bin/bash
# Script to launch alacritty, set it to fullscreen, and then run cmatrix in fullscreen on workspace 8 in i3

LOGFILE=~/dotfiles/scripts/start_cmatrix_screensaver.log

# Log function
log() {
    echo "$(date) - $1" >> $LOGFILE
}

# Function to get the current workspace
get_current_workspace() {
    i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name'
}

# Start logging
log "Script started."

# Switch to workspace 8
i3-msg "workspace 8"
log "Switched to workspace 8."

# Log current workspace
CURRENT_WORKSPACE=$(get_current_workspace)
log "Current workspace after switching: $CURRENT_WORKSPACE"

# Launch alacritty
i3-msg "exec --no-startup-id alacritty"
log "Launched alacritty."

# Add a delay to ensure alacritty and shell are fully loaded
sleep 3
log "Waited 3 seconds for alacritty to load."

# Log current workspace
CURRENT_WORKSPACE=$(get_current_workspace)
log "Current workspace after waiting: $CURRENT_WORKSPACE"

# Find the alacritty window ID
ALACRITTY_WINDOW_ID=$(xdotool search --class Alacritty | tail -1)
log "Found alacritty window ID: $ALACRITTY_WINDOW_ID"

# Ensure the alacritty window is in focus
xdotool windowactivate --sync $ALACRITTY_WINDOW_ID
log "Activated alacritty window ID: $ALACRITTY_WINDOW_ID"

# Log current workspace
CURRENT_WORKSPACE=$(get_current_workspace)
log "Current workspace after activating alacritty: $CURRENT_WORKSPACE"

# Make the terminal fullscreen
i3-msg "[id=\"$ALACRITTY_WINDOW_ID\"] fullscreen enable"
log "Set alacritty to fullscreen."

# Add a short delay to ensure fullscreen is set
sleep 1

# Send the cmatrix command to the alacritty window
xdotool type --window $ALACRITTY_WINDOW_ID "cmatrix -bas"
log "Typed cmatrix command."

xdotool key --window $ALACRITTY_WINDOW_ID Return
log "Sent Return key to execute cmatrix command."

# Log current workspace
CURRENT_WORKSPACE=$(get_current_workspace)
log "Current workspace after sending command: $CURRENT_WORKSPACE"

log "Script finished."
