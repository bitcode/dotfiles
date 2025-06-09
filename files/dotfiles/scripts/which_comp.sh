#!/bin/bash

# List of known compositors
compositors=("compton" "picom" "xcompmgr" "kwin" "mutter" "xfwm4")

# Check running processes
for comp in "${compositors[@]}"; do
    if pgrep -x "$comp" &> /dev/null; then
        echo "Current compositor: $comp"
        exit 0
    fi
done

echo "No compositor detected"
