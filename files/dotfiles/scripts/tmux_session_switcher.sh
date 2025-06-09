#!/usr/bin/bash

# Log file
LOG_FILE="$HOME/tmux_debug.log"

# Function to log debug information
debug_log() {
    echo "$(date): DEBUG: $1" >> "$LOG_FILE"
}

# Function to log errors
error_log() {
    echo "$(date): ERROR: $1 (Exit status: $2)" >> "$LOG_FILE"
}

debug_log "--- New Tmux Session Switch Execution ---"

# Function to capture pane content for preview
preview_session_content() {
    local session_name="$1"
    tmux capture-pane -eJpt "$session_name:0.0" -S -100 > /tmp/tmux_preview_buffer && cat /tmp/tmux_preview_buffer
}

# Function to create a new session
create_new_session() {
    local new_session_name
    new_session_name=$(tmux new-session -d -P)
    if [ $? -eq 0 ]; then
        debug_log "Created new session: $new_session_name"
        echo "$new_session_name"
    else
        debug_log "Failed to create new session"
        echo ""
    fi
}

# Get list of sessions
sessions=$(tmux list-sessions -F "#{session_name}|#{session_id}|#{session_windows}")
debug_log "Available sessions:"
debug_log "$sessions"

# Use fzf-tmux to select a session
debug_log "Starting fzf-tmux for session selection"
selected=$(echo "$sessions" | \
    fzf-tmux -p 90%,90% --layout=reverse \
    --preview 'tmux capture-pane -eJpt {1}:0.0 -S -100 > /tmp/tmux_preview_buffer && cat /tmp/tmux_preview_buffer' \
    --preview-window=top:70% \
    --prompt 'Switch to session: ' \
    --header 'New Session: Alt-n | Kill Session: Alt-k | Refresh List: Alt-r | Quit: Ctrl-c or Esc' \
    --bind 'alt-n:execute(tmux new-session -d -P | xargs -I {} tmux switch-client -t {})+abort' \
    --bind 'alt-k:execute(tmux kill-session -t {1})+abort' \
    --bind 'alt-r:reload(tmux list-sessions -F "#{session_name}|#{session_id}|#{session_windows}")' \
    --bind 'ctrl-c:abort' \
    --bind 'esc:abort' \
    --bind 'ctrl-n:down' \
    --bind 'ctrl-p:up' \
    --with-nth=1 \
    --delimiter='|' 2>> "$LOG_FILE")

exit_status=$?
debug_log "fzf-tmux exit status: $exit_status"

if [ $exit_status -eq 130 ] || [ $exit_status -eq 1 ]; then
    debug_log "User aborted or no session selected"
    exit 0
fi

debug_log "fzf-tmux returned: $selected"

if [ -n "$selected" ]; then
    session_name=$(echo "$selected" | cut -d'|' -f1)
    debug_log "Switching to session: $session_name"
    if ! tmux switch-client -t "$session_name" 2>> "$LOG_FILE"; then
        debug_log "Failed to switch to session $session_name"
        exit 1
    fi
else
    debug_log "No session selected"
fi

debug_log "--- End of Tmux Session Switch Execution ---"
