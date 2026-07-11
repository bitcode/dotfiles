#!/bin/bash

# Calendar popup for the polybar date module.
# Shows the current month in a themed rofi window; Esc or clicking away
# dismisses it (same interaction model as the rofi power menu).

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rofi -show calendar -modi "calendar:${DIR}/rofi-calendar" \
    -no-custom \
    -theme ~/.config/rofi/themes/foraya.rasi
