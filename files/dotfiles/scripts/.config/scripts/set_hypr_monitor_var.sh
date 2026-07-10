#!/bin/bash

# Get the list of connected monitors
monitors=$(hyprctl monitors)

# Extract the first monitor name
monitor_name=$(echo "$monitors" | awk -F': ' '/^Monitor/ {print $2}' | head -n 1)

# Export the monitor name as a system variable
export MONITOR_NAME="$monitor_name"

echo "Monitor name: $MONITOR_NAME"
