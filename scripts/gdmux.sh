gdmux() {
    local executable="$1"
    if [[ -z "$executable" ]]; then
        echo "Usage: gdmux <executable>"
        return 1
    fi

    local log_file="$HOME/gdmux_log.txt"
    echo "Starting gdmux script..." > "$log_file"
    exec 3>&1 4>&2 1>>"$log_file" 2>&1

    set -x

    if ! command -v tmux &> /dev/null; then
        echo "tmux not found, please install tmux."
        return 1
    fi

    if ! tmux has-session -t gdbSession 2> /dev/null; then
        tmux new-session -d -s gdbSession -n gdb "bash"
        tmux split-window -h -p 40 "tail -f ~/gdb.txt"
        local left_pane_id=$(tmux list-panes -F '#{pane_id}' | head -n1)
        tmux send-keys -t "$left_pane_id" "gdb $executable" C-m
        tmux send-keys -t "$left_pane_id" "run >~/gdb.txt 2>&1" C-m
    fi

    tmux attach-session -t gdbSession

    exec 1>&3 2>&4
    set +x
    echo "Script ended. Logs are in $log_file"
}
