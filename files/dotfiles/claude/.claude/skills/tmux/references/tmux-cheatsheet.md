# tmux command reference (scripted / non-interactive use)

Commands to run via the shell tool, not interactive prefix-key sequences. All mutating commands need an explicit `-t` target — see SKILL.md Rules 1-2 before using any of these against a pane you didn't just create.

## Inspect (always safe, read-only)

```bash
tmux list-sessions                                   # -F for custom format
tmux list-windows -a                                  # all windows, all sessions
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} active=#{pane_active}'
tmux display-message -p '#{session_name}:#{window_index}.#{pane_index} #{pane_pid}'  # "where am I"
tmux capture-pane -p -t <target>                       # dump pane content to stdout
tmux capture-pane -p -t <target> -S -1000              # last 1000 lines of scrollback
tmux show-options -g                                   # global options
```

## Sessions

```bash
tmux new-session -d -s <name>                          # -d = detached, don't attach
tmux new-session -d -s <name> -c <start-dir>
tmux has-session -t <name>                              # exit code 0 if exists
tmux rename-session -t <old> <new>
tmux kill-session -t <name>                             # DESTRUCTIVE — confirm target first (Rule 1)
```

## Windows

```bash
tmux new-window -d -t <session> -n <name>               # -d keeps focus where it was
tmux new-window -d -t <session> -n <name> -c <dir> '<command>'
tmux rename-window -t <target> <name>
tmux kill-window -t <target>                             # DESTRUCTIVE
```

## Panes

```bash
tmux split-window -h -t <target> -c <dir>               # vertical split (side by side)
tmux split-window -v -t <target> -c <dir>                # horizontal split (stacked)
tmux split-window -d -h -t <target> '<command>'          # -d = don't switch focus to new pane
tmux kill-pane -t <target>                               # DESTRUCTIVE (fine if you created it this task)
tmux select-pane -t <target>
tmux resize-pane -t <target> -D 5                        # -D/-U/-L/-R + cell count
```

## Sending input

```bash
tmux send-keys -t <target> 'echo hello' Enter            # payload and Enter as separate args
tmux send-keys -t <target> C-c                           # send Ctrl-C
tmux send-keys -t <target> -l 'literal $tring no expand'  # -l = literal, no key-name parsing
```

Never combine payload+Enter into one string like `'echo hello\n'` passed as a single arg — pass `Enter` as its own argument. Never send to a target you haven't confirmed isn't your own pane (SKILL.md Rule 1) or isn't running an unfamiliar modal program (Rule 3).

## Running a command and capturing its result (common Claude pattern)

```bash
tmux new-window -d -t <session> -n scratch -P -F '#{window_id}' '<command>'
# -P -F prints the new window's id so you can target it precisely afterward
tmux capture-pane -p -t <window_id>
tmux kill-window -t <window_id>   # clean up since you created it
```

## Popups (this user has custom popup bindings — see references/list-keys.txt)

```bash
tmux display-popup -E '<command>'                        # -E = close popup when command exits
tmux display-popup -h 90% -w 90% -E '<command>'
```

## Copy mode / buffers

```bash
tmux show-buffer                                          # print top paste buffer
tmux save-buffer <file>
tmux set-buffer '<text>'
```
