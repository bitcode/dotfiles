---
name: i3
description: Navigate and query the i3 window manager from the CLI — find windows, switch workspaces, focus/move windows in a direction, check what's currently visible. Use whenever a task needs to know what's on screen, move focus between windows/workspaces, arrange windows for a side-by-side comparison, or otherwise interact with the desktop beyond the single terminal Claude is running in. Same self-targeting hazard as tmux: Claude Code's own terminal is itself a window in the i3 tree, so commands that focus/move/kill "the active window" can hit Claude's own window instead of the intended target.
allowed-tools: Bash(i3-msg *), Bash(xdotool *)
---

# i3

i3 is a tiling window manager: the screen is divided into **workspaces** (i3's term for virtual desktops — numbered 1-3 on this machine, bound to a single output `DP-3`), and each workspace holds a tree of **containers** (windows), split/stacked/tabbed. There is no separate "which desktop am I on" concept beyond workspaces.

Claude Code runs inside an Alacritty window that is itself one container in this tree — not a special, protected object. `i3-msg` commands issued from here execute against the live window manager with no sandboxing. A `focus`/`move`/`kill` command aimed at "the current window" from i3's perspective may not be the pane you meant, and if it targets Claude's own container, it can defocus, relocate, or close the window Claude is running in.

## Rule 1 — Identify your own window before targeting anything

Multiple windows of the same class can coexist (e.g. two Alacritty terminals on different workspaces) — class/title alone does not disambiguate. Before issuing any `i3-msg` command that focuses, moves, or kills a specific window, get your own window's identity:

```bash
echo "WINDOWID=$WINDOWID"
xdotool getactivewindow      # decimal X11 window id of whatever currently has focus
```

`$WINDOWID` (set by Alacritty in the shell env) is the ground truth for "this terminal, right now." It matches the `"window"` field in `i3-msg -t get_tree` output — **not** the `"id"` field, which is i3's own internal container id and looks similar but is a different number. See [`references/sample-ipc-output.txt`](references/sample-ipc-output.txt) for a worked example of exactly this ambiguity (two Alacritty windows, only one of which is "self").

## Rule 2 — Query before you act, every time

Never assume the current workspace/window layout from memory — it changes as the user works. Read state fresh:

```bash
i3-msg -t get_workspaces           # list workspaces: which is focused, which is visible, which output
i3-msg -t get_tree                 # full window tree (large; grep or pipe through python3 -m json.tool)
xdotool getactivewindow getwindowname   # human-readable title of the focused window
```

`get_tree` is verbose. To scan it for window names/classes without dumping the whole structure:

```bash
i3-msg -t get_tree | python3 -c "
import json,sys
t=json.load(sys.stdin)
def walk(n):
    wp = n.get('window_properties')
    if wp: print(n.get('id'), n.get('window'), wp.get('class'), wp.get('title'), 'focused=' + str(n.get('focused')))
    for c in n.get('nodes',[])+n.get('floating_nodes',[]): walk(c)
walk(t)
"
```

## Navigation commands (direction = N/S/E/W of the currently focused container)

This machine remaps the default vim-style bindings — direction keys are **not** the standard h/j/k/l. Confirmed from `~/dotfiles/files/dotfiles/i3/.config/i3/config`:

| Direction | Key bound in i3 | `i3-msg` command |
|---|---|---|
| West (left)  | `$mod+j` / `$mod+Left`  | `i3-msg focus left` |
| South (down) | `$mod+k` / `$mod+Down`  | `i3-msg focus down` |
| North (up)   | `$mod+l` / `$mod+Up`    | `i3-msg focus up` |
| East (right) | `$mod+semicolon` / `$mod+Right` | `i3-msg focus right` |

Same direction words work for `move`: `i3-msg move left` / `move down` / `move up` / `move right` — moves the *focused* container one step in that direction within the tree.

`$mod` is `Mod4` (Super/Windows key) — irrelevant for `i3-msg` since IPC commands bypass keybindings entirely and take the command word directly.

## Workspace switching

```bash
i3-msg workspace number 2                    # switch to workspace 2
i3-msg move container to workspace number 2  # move focused window to workspace 2
```

Only workspaces 1-3 are in active use on this machine (config defines bindings up to 10, but only 1-3 have windows — confirm with `get_workspaces` rather than assuming a workspace exists).

## Practical patterns

**Find and focus a specific app** (e.g. bring a browser to front to check something):
```bash
i3-msg -t get_tree | python3 -c "
import json,sys
t=json.load(sys.stdin)
def find(n, cls):
    wp = n.get('window_properties')
    if wp and wp.get('class','').lower() == cls.lower(): return n
    for c in n.get('nodes',[])+n.get('floating_nodes',[]):
        r = find(c, cls)
        if r: return r
find_result = find(t, 'firefox')
print(find_result['id'] if find_result else 'not found')
"
# then: i3-msg "[con_id=<id>] focus"
```

**Arrange two windows side by side for visual comparison** (pairs well with the `flameshot` skill — arrange, then screenshot):
```bash
i3-msg 'workspace number 1'
i3-msg split h
# launch/focus the second window, i3 tiles it alongside automatically
```

**Check what's currently on screen before describing it to the user** — always `get_workspaces` + `get_tree` first rather than assuming; the visible workspace can change between turns if the user switches manually.

## What NOT to do

- Don't run `i3-msg kill` (closes focused window) without first confirming via Rule 1 that the focused window isn't Claude's own terminal.
- Don't run `i3-msg exit` (logs out of the X session) or `i3-msg restart` — both are destructive to the user's whole session; never run without explicit confirmation, and `exit` should essentially never be run by Claude.
- Don't assume workspace numbers/names beyond what `get_workspaces` just showed you.
- Don't assume h/j/k/l are the direction keys on this config — they aren't (see table above). This only matters if you're simulating keypresses (`xdotool key`); `i3-msg focus <direction>` takes the literal word `left`/`right`/`up`/`down` regardless of keybinding.
