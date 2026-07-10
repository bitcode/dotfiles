# Claude Code integration

How Claude Code itself is configured in this dotfiles repo, and the
terminal fixes that make it work well in Alacritty + tmux + zsh.

## Source of truth

`files/dotfiles/claude/.claude/` mirrors `~/.claude/`, stowed like every
other app (added to `base_apps` in `roles/dotfiles/tasks/main.yml` since
it's platform-agnostic, not X11/i3-specific). Only the following are
tracked; everything else under `~/.claude/` (sessions, history, cache,
credentials, projects, backups, ...) is real, untracked, machine-local
state that GNU Stow leaves alone because it already exists as a real
directory (stow "folds" onto individual files instead of symlinking the
whole `~/.claude` tree):

- `CLAUDE.md` — global instructions
- `settings.json` — see below
- `statusline.sh` / `statusline.ps1` — Gruvbox powerline statusline
- `file-suggest.sh` — `@`-mention file completion (uses `fd`, falls back to `find`)
- `skills/` — `deep-research`, `feature-classification`, `signal-discipline`

## settings.json

Merges what Claude Code's own onboarding wrote (`theme`, `tui`, `model`,
`agentPushNotifEnabled`) with the hand-tuned config (vim editor mode,
statusline, file-suggestion, permissions allowlist, plugin marketplace).
Also has a `Notification` hook that fires `notify-send` (via dunst, already
running under i3) since Alacritty isn't one of the terminals Claude Code
sends desktop notifications to natively (only Ghostty/Kitty/iTerm2 are).

### tmux-claude and the symlink

`.tmux.conf` declares the `smilovanovic/tmux-claude` plugin, which adds a
live `#{claude_status}` segment to the tmux status bar. Its init script
(`~/.tmux/plugins/tmux-claude/claude.tmux` → `install_hooks.sh`) rewrites
`~/.claude/settings.json` on every **new tmux server start** (not every
new session/window — tpm only re-runs plugin init scripts when the tmux
server itself boots) to merge in hooks for `SessionStart`,
`UserPromptSubmit`, `PreToolUse`, `Stop`, `StopFailure`, `SubagentStart`,
`PreCompact`, `Elicitation`, `SessionEnd`, plus a `permission_prompt`
Notification matcher — all wired to its own `hook.sh`.

**This breaks the stow symlink.** The script does `mv "$tmp" "$SETTINGS"`,
and `mv` onto a symlink target replaces the symlink itself with a real
file — it does not write through it. So after a fresh tmux server start,
`~/.claude/settings.json` silently stops being a symlink into this repo.

If you notice `settings.json` changes aren't showing up in `git status`,
or you want to re-sync after tmux-claude has rewritten it:

```bash
command cp -f ~/.claude/settings.json files/dotfiles/claude/.claude/settings.json
command rm -f ~/.claude/settings.json
ansible-playbook site.yml -i inventories/local/hosts.yml -e profile=developer --tags dotfiles
```

(`cp`/`rm` are aliased to their `-i` interactive forms in `.zshrc`, hence
`command cp` / `command rm` to bypass the confirmation prompt in a script.)

## Shift+Enter in Alacritty + tmux

Per <https://code.claude.com/docs/en/terminal-config>, Alacritty needs
`/terminal-setup` for Shift+Enter — but that alone didn't work here (a
[known issue](https://dylancastillo.co/til/fix-claude-code-shift-enter-alacritty.html)).
The actual fix, already applied, is three pieces:

1. **Alacritty** (`files/dotfiles/alacritty/.config/alacritty/alacritty.toml`):
   ```toml
   [keyboard]
   bindings = [
       { key = "Return", mods = "Shift", chars = "\n" },
   ]
   ```
2. **tmux** (`files/dotfiles/tmux/.tmux.conf`) — required because Claude
   Code always runs inside tmux here (Alacritty's shell launches
   `tmux new-session -A`):
   ```
   set-option -g extended-keys always
   set-option -as terminal-features 'xterm*:extkeys'
   set-option -g allow-passthrough on
   ```
   `extended-keys`/`terminal-features` let tmux distinguish Shift+Enter
   from plain Enter. `allow-passthrough` lets desktop notifications and
   Claude Code's progress bar escape sequences reach the outer terminal
   instead of being swallowed by tmux.
3. Fallback that always works regardless of terminal config: `Ctrl+J`, or
   `\` then `Enter`.

## tmux plugins

`.tmux.conf` declares `tpm`, `tmux-sensible`, `tmux-yank`, `tmux-claude`,
`tmux-gruvbox` via `@plugin`, but nothing installs `tpm` itself except the
`applications/tmux` Ansible role (`install_tpm.yml`) — if that role was
never run, `~/.tmux/plugins/` doesn't exist and none of the plugins load
(the status bar theme silently does nothing, `#{claude_status}` shows up
as literal text). Run:

```bash
ansible-playbook site.yml -i inventories/local/hosts.yml -e profile=developer --tags tmux
```

then `prefix + I` inside tmux (or `tmux run-shell '~/.tmux/plugins/tpm/bindings/install_plugins'`)
to fetch the plugins themselves.
