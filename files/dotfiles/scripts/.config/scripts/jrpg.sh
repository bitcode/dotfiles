#!/bin/bash
tmux new-session -d -s jrpg
tmux attach-session -t jrpg
tmux split-window -p 30 -h
tmux select-pane -L
tmux send-keys 'cd /home/bit/jrpaintinggroup' C-m
tmux send-keys 'nvim' C-m
tmux select-pane -R
tmux send-keys 'cd /home/bit/jrpaintinggroup' C-m
tmux send-keys 'npm run dev' C-m
tmux select-pane -L
tmux send-keys '\ ff' C-m
