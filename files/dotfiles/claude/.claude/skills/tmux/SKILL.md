---
name: tmux
description: How to safely drive tmux (panes, windows, sessions, send-keys, popups) from inside Claude Code. Use whenever a task involves running commands in other tmux panes/windows, splitting/creating panes, sending keys to another program, or anything tmux-related — especially because Claude Code itself usually runs inside a tmux pane, and careless tmux commands (kill-session, send-keys into your own pane, detach-client, kill-window) can kill or scramble the very session Claude is running in.
---

# tmux

Claude Code is almost always running **inside a tmux pane** on this machine (see `~/dotfiles/files/dotfiles/tmux/.tmux.conf`). Any `tmux` command you run is executed by the shell tool *in that same pane*, using the ambient `$TMUX` socket — there is no isolation. A command aimed at "the session" can just as easily hit the session Claude itself is running in. That's how a prior session sent a key sequence intended for another pane and exited itself instead.

## Rule 1 — Always identify yourself before any mutating command

Before running any tmux command that sends keys, kills, or switches state (`send-keys`, `kill-session`, `kill-window`, `kill-pane`, `switch-client`, `detach-client`, `respawn-pane`, `respawn-window`), run this first, every time, even if you think you already know the answer:

```bash
echo "TMUX=$TMUX"
tmux display-message -p '#{session_id} #{session_name}:#{window_index}.#{pane_index} #{pane_pid}'
```

If `$TMUX` is unset, you are not inside tmux — `tmux` commands still work (they attach to the default/only server) but there's no "self" pane to protect; skip to Rule 2 with that in mind.

If `$TMUX` is set, that session/window/pane is **yours**. Never target it with a mutating command unless the user explicitly asked you to affect *this* Claude session (e.g. "rename this window"). Treat `-t` targets as unsafe until you've compared them against your own identity string above.

**Live-confirmed gotcha:** when more than one Claude-Code-in-tmux window exists on screen (e.g. two Alacritty windows on different i3 workspaces — see the `i3` skill), they can look visually identical in a screenshot: same terminal chrome, similar-looking output. The tmux status bar's session ID (bottom-left) is the only reliable visual differentiator — cross-check it against the `#{session_id}`/`#{session_name}` from the Rule 1 command above, not against how the screenshot looks. A workspace switch between two such windows can appear to have "done nothing" when it actually worked correctly; don't diagnose that as a bug without checking the session ID first.

## Rule 2 — Target explicitly, never rely on "current"

Every mutating command must carry an explicit `-t <target>` derived from `tmux list-sessions` / `tmux list-windows` / `tmux list-panes` output you just read — not from memory, not from what you assume is "the other pane." Ambiguous/omitted `-t` falls back to the attached client's active pane, which is frequently *your own pane* when Claude is the one issuing the command.

```bash
tmux list-sessions
tmux list-windows -a
tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} active=#{pane_active}'
```

Use the `pane_current_command` / `session_name` columns to confirm you've found the *other* pane (e.g. the one running a dev server or the target shell), not the `claude` process pane from Rule 1.

## Rule 3 — send-keys needs an explicit Enter, and never blind-send to an unknown pane

`send-keys` types into whatever program owns that pane. If the pane is running vim, less, fzf, or another TUI (not a shell prompt), literal keys can trigger quit/write/kill bindings in *that* program. Before sending keys:

1. Confirm the target pane's `pane_current_command` (see Rule 2) — is it a shell, or something modal (vim/less/man/fzf/tmux-file-picker popup/etc.)?
2. If modal and you don't know its keybindings, don't guess — check `references/list-keys.txt` (this skill) or ask the user.
3. Send the payload and Enter as separate args, not baked into one string with `\n`:
   ```bash
   tmux send-keys -t <target> 'echo hello' Enter
   ```
4. Never send a bare `Enter`, `q`, `C-c`, `C-d`, `Escape`, or `:wq` to a target you have not just confirmed with Rule 2 — these are exactly the keys that quit/kill/detach things.

## Rule 4 — the destructive-command list

These require explicit user confirmation before running, same as any other destructive action (per global instructions): `kill-session`, `kill-server`, `kill-window`, `kill-pane -a`, `detach-client`, `respawn-pane`/`respawn-window` on a pane with unsaved state. `kill-pane` on a pane you just created yourself for a scoped task is fine without asking. Never run `kill-server` — it takes down every session on the machine, including this one.

## Common operations

Read command reference: [`references/tmux-cheatsheet.md`](references/tmux-cheatsheet.md) — grouped by session/window/pane/copy-mode/send-keys, with the exact syntax for scripted (non-interactive) use.

This user's live keybindings (captured via `tmux list-keys` / `tmux list-keys -T copy-mode-vi` from their actual `.tmux.conf`, including custom prefix-bound popups like `v`/`g`/`z`/`u` for the fuzzy file picker): [`references/list-keys.txt`](references/list-keys.txt). Re-run `tmux list-keys` yourself if the user has edited `~/.tmux.conf` since this was captured — don't trust a stale copy for anything safety-relevant.

Their prefix is the tmux default `C-b` (not remapped) — see `~/dotfiles/files/dotfiles/tmux/.tmux.conf`.

## Quick decision guide

- **Run a command in a new scratch pane/window and read its output** → `tmux new-window`/`split-window` with a target you control end-to-end, then `capture-pane -p` to read output. Safe, no ambiguity.
- **Send input to an existing pane the user is using** → Rule 2 + Rule 3, full stop.
- **Anything that kills/detaches/respawns** → Rule 4, ask first unless it's a pane you spun up yourself this task.
- **Not sure if you're about to hit your own pane** → re-run the Rule 1 identity check. It's cheap; a wrong guess isn't.
