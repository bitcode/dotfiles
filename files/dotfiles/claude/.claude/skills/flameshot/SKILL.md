---
name: flameshot
description: Take screenshots from the CLI with flameshot for visual verification — before/after comparisons, capturing UI state after an action, checking a specific region/window looks right, or any task where seeing the actual rendered result matters more than reading code. Use this whenever verifying a UI/visual change (themes, layouts, dotfiles configs, web pages, app windows) instead of just trusting the diff.
allowed-tools: Bash(flameshot *)
---

# flameshot

CLI-scriptable screenshot tool, already running as a background daemon on this machine (autostart service, tray icon). Every subcommand below runs **fully non-interactively** when given the right flags — no GUI popup, no user interaction required — which is what makes it useful for Claude to drive directly: capture, read the file, compare.

Full captured `--help` output for every subcommand: [`references/help-output.txt`](references/help-output.txt).

## Core pattern: capture straight to a file, then Read it

```bash
flameshot full -p /path/to/output.png
```

`flameshot full` grabs all monitors, no interaction, exits immediately once saved. This is the default choice for "show me what the screen looks like right now." Always pass an explicit `-p <file>` — don't rely on flameshot's own default save directory (unconfigured on this machine; `flameshot.ini` sets no `savePath`). Save into this session's scratchpad directory (given in your system prompt), then use the Read tool on the resulting PNG to actually look at it — a screenshot on disk is not verification until you've viewed it.

```bash
flameshot full -p /path/to/scratchpad/screenshots/after.png
```

## Before/after comparison workflow

The pattern that matters most: capture, act, capture again, view both.

```bash
flameshot full -p /path/to/scratchpad/screenshots/before.png
# ... make the change (edit config, reload app, click something, etc.) ...
sleep 1   # let the UI settle/repaint before capturing
flameshot full -p /path/to/scratchpad/screenshots/after.png
```

Then Read both PNGs and describe the diff. For a UI that needs time to redraw after a trigger (window manager reload, animation, app restart), use `-d <milliseconds>` instead of a separate sleep — it delays flameshot's own capture, not your shell:

```bash
flameshot full -p /path/to/scratchpad/screenshots/after.png -d 800
```

## Capturing a specific region (not the whole screen)

`--region` only works on `gui`, **not** `screen`, despite `screen --help` listing the flag — tested on v14.0.0, `flameshot screen --region ...` silently aborts with "Screenshot aborted." Always use `gui` for region captures:

```bash
flameshot gui -p /path/to/scratchpad/screenshots/widget.png --region 400x300+100+100 -s
```

- `--region WxH+X+Y` — exact pixel geometry
- `-s, --accept-on-select` — required for non-interactive use; without it, `gui` still waits for the user to confirm/press Enter even with a region pre-selected
- Omit `-s` only if you deliberately want the interactive editor to stay open (rare for scripted use)

### Finding the right geometry once, then reusing it

To capture the same region repeatedly (e.g. a specific panel/widget across multiple before/after rounds) without re-guessing coordinates each time:

```bash
flameshot gui -g   # interactively select once; prints WxH+X+Y to stdout, doesn't save
```

Capture that string and reuse it in every subsequent `--region` call for the rest of the task, or use `--last-region` to repeat the immediately-prior manual selection:

```bash
flameshot gui -p out.png --last-region -s
```

## Single-monitor capture

```bash
flameshot screen -p out.png -n 0        # screen 0 specifically
flameshot screen -p out.png             # screen under the cursor (default)
flameshot screen -p out.png -e          # interactive edit-then-capture (not scriptable)
```

Prefer `flameshot full` unless the user has a specific multi-monitor setup where only one screen is relevant.

## Other useful flags

- `-c, --clipboard` — also copy the capture to clipboard (combine with `-p` to get both file and clipboard)
- `-r, --raw` — print raw PNG bytes to stdout instead of a notification; pipe into another tool rather than reading a file
- `--pin` — pin the capture as an always-on-top window (interactive use only, not useful for scripted verification)

## What NOT to do

- Don't use `flameshot gui` without `-s` (or `--region`+`-s` together) for scripted capture — it can hang waiting for interactive confirmation.
- Don't assume a default save path — always pass `-p`.
- Don't forget to actually Read the resulting PNG. Confirming the file exists on disk is not the same as verifying the visual result — the whole point of this skill is looking at the actual pixels.
- Don't use `screen --region` — it's broken on this install; use `gui --region` instead.
