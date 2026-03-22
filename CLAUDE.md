# CLAUDE.md — Dotsible Dotfiles Repo

## What This Is

**Dotsible** — an Ansible + GNU Stow based cross-platform dotfiles manager. It configures 36+ apps across macOS, Ubuntu, Arch Linux, and Windows via Ansible roles and deploys the actual config files using GNU Stow symlinks.

## Repo Layout

```
dotfiles/
├── site.yml                  # Main Ansible orchestration playbook
├── ansible.cfg               # Ansible config (uses dotsible_clean callback plugin)
├── run-dotsible.sh           # Primary deployment wrapper (1,225 lines — prefer this over ansible-playbook directly)
├── bootstrap.sh              # First-time setup, platform detection
├── files/dotfiles/           # Actual dotfiles (36+ app dirs, managed via GNU Stow)
├── roles/
│   ├── common/               # Base system, Python/environment detection
│   ├── dotfiles/             # GNU Stow deployment logic
│   ├── applications/         # Per-app roles (15 sub-roles: neovim, zsh, tmux, alacritty, etc.)
│   ├── profiles/             # developer | enterprise profiles
│   ├── platform_specific/    # darwin | ubuntu | archlinux | windows
│   ├── python_management/
│   └── macos_enterprise/
├── group_vars/all/           # Ansible variables
├── inventories/local/        # Local host inventory
├── docs/                     # 14 core documentation files
└── plugins/callback/         # Custom dotsible_clean Ansible output plugin
```

## Known Mess — Root Directory Clutter

The root has **40+ test/diagnostic/summary files** that were never organized:
- `test-*.yml` — ad-hoc test playbooks (should live in a `tests/` dir)
- `debug-*.yml` — debugging playbooks
- `*_SUMMARY.md`, `*_FIXES.md`, `*_IMPLEMENTATION.md` — one-off notes from iterative development
- Shell scripts: `diagnose-stow-issues.sh`, `comprehensive-diagnostic.sh`, `working-stow-deployment.sh`, etc.

These are not part of the core deployment flow. Don't treat them as canonical. When cleaning up, the right destination for test playbooks is `tests/` and diagnostic docs can either be deleted or moved to `docs/`.

## Deployment

```bash
# Primary way to run
./run-dotsible.sh                          # interactive, auto-detects platform
./run-dotsible.sh --profile developer      # full dev environment
./run-dotsible.sh --profile enterprise     # MDM-compatible macOS setup
./run-dotsible.sh --dry-run               # preview changes
./run-dotsible.sh --tags dotfiles         # only deploy dotfile symlinks
ansible-playbook site.yml -i inventories/local/hosts.yml  # direct playbook run
```

GNU Stow is used to symlink `files/dotfiles/<app>/` into `$HOME`. Each app dir mirrors the home directory structure.

## Key Dotfile Locations

| App | Path |
|-----|------|
| Neovim | `files/dotfiles/nvim/.config/nvim/` |
| Zsh | `files/dotfiles/zsh/.zshrc`, `.zprofile` |
| Tmux | `files/dotfiles/tmux/` |
| Git | `files/dotfiles/git/` |
| Alacritty | `files/dotfiles/alacritty/` |
| Starship | `files/dotfiles/starship/` |

## Neovim Config

`files/dotfiles/nvim/.config/nvim/`

- `lua/plugins/` — 32 plugin configs (lazy.nvim)
- `lua/settings/init.lua` — core options, keymaps, colorscheme (Gruvbox)
- `lua/settings/lspconfig.lua` — LSP setup with keybindings (recently active)
- `lazy-lock.json` — frozen plugin versions

Notable plugins: which-key (extensively configured), telescope, harpoon, oil.nvim, nvim-cmp, mason, lspsaga, treesitter, gitsigns, codecompanion, copilot

Assembly support is a first-class feature: `asm_lsp.lua`, examples in `nvim/examples/` for ARM32/ARM64/RISC-V/x86-64.

`.bak` files (`manscope.bak`, `markview.bak`) are leftovers — safe to clean up.

## Zsh Config

`.zshrc` highlights:
- Homebrew paths (arm64 macOS)
- XDG Base Directory spec
- Vi mode with cursor shape changes per mode
- 50k history, shared across sessions
- Aliases for git, tmux, lsd, fzf
- PATH deduplication

## Ansible Roles Worth Knowing

- `roles/dotfiles/tasks/main.yml` — 1,111 lines, handles all Stow symlink logic, broken link cleanup, force/adopt strategies
- `roles/applications/neovim/` — Neovim-specific install + config tasks
- `roles/profiles/developer/` — full dev setup
- `roles/profiles/enterprise/` — MDM-compatible, conservative installs

## Variables

`group_vars/all/` controls:
- Which dotfiles are deployed per platform
- Profile feature flags
- Package lists per distro

## Platforms

| Platform | Support Level |
|----------|---------------|
| macOS (arm64/x86) | Primary, most tested |
| Ubuntu/Debian | Supported |
| Arch Linux | Supported |
| Windows | Bootstrap + partial (PowerShell) |

## What NOT to Touch Without Reading First

- `site.yml` — complex pre-flight checks, don't simplify blindly
- `roles/dotfiles/tasks/main.yml` — stow logic is subtle, idempotency matters
- `run-dotsible.sh` — large but each section has purpose; profile/tag/dry-run logic

## Dependencies

- Ansible collections: `requirements.yml` (ansible.posix, community.general, etc.)
- Python: `requirements.txt` / `requirements-dev.txt`
- Node.js: `package.json` at root (tooling only, not core deployment)
- GNU Stow: installed by the `dotfiles` role if missing
