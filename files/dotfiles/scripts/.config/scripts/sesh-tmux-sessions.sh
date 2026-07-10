#!/bin/bash
LOGFILE="/tmp/tmux_sesh.log"
echo "Script started" > $LOGFILE

# Check if sesh and fzf-tmux are available
if ! command -v sesh &> /dev/null; then
    echo "sesh command not found" >> $LOGFILE
    exit 127
fi

if ! command -v fzf-tmux &> /dev/null; then
    echo "fzf-tmux command not found" >> $LOGFILE
    exit 127
fi

echo "Commands found, executing fzf-tmux" >> $LOGFILE

# Run fzf-tmux and capture the selected session
SESSION=$(sesh list | fzf-tmux -p 55%,60% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^x zoxide ^f find ^d kill ^n new' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 3 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {})+reload(sesh list)' \
    --bind 'ctrl-n:execute(tmux new-session -d -s \"$(read -p \"Session name: \")\";)+reload(sesh list)')

# Check if a session was selected
if [[ -z "$SESSION" ]]; then
    echo "No session selected" >> $LOGFILE
    exit 1
fi

echo "Selected session: $SESSION" >> $LOGFILE

# Connect to the selected session
sesh connect "$SESSION"

echo "Command executed, exiting" >> $LOGFILE

