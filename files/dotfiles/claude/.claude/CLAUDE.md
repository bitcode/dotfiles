# Global Claude Instructions

## Who I Am
- Software engineer primarily on macOS (arm64), also working on Linux (Ubuntu, Arch) and Windows
- Daily tools: Neovim (lazy.nvim), Zsh (vi mode), Tmux, Git, Ansible
- Dotfiles managed via Dotsible (Ansible + GNU Stow) at `~/dotfiles`

## Communication Style
- Be concise. Skip preamble, filler words, and restating the question
- Lead with the answer or action, not the reasoning
- Short sentences. No trailing summaries — I can read the diff
- Use markdown only when it genuinely helps (tables, code blocks)

## Code Style
- Prefer simple solutions over clever ones
- Don't add abstractions, helpers, or error handling for hypothetical future needs
- Don't add comments unless the logic is non-obvious
- Don't add docstrings, type annotations, or refactoring beyond what's asked
- Match the style and conventions already in the file

## Workflow Preferences
- Make changes directly — don't propose changes to code you haven't read first
- Read existing code before modifying it
- Prefer editing existing files over creating new ones
- Commit messages: imperative mood, concise subject, explain why not what

## Cross-Platform Awareness
- macOS: Homebrew at `/opt/homebrew` (arm64) or `/usr/local` (x86)
- Linux: check distro before assuming package manager (apt vs pacman vs dnf)
- Use `$HOME` and `$XDG_CONFIG_HOME` over hardcoded paths in configs
- Ansible roles handle platform differences — check `roles/platform_specific/` before adding OS-specific logic inline

## Neovim
- Config lives at `~/dotfiles/files/dotfiles/nvim/.config/nvim/`
- Plugin manager: lazy.nvim — each plugin has its own file in `lua/plugins/`
- LSP: nvim 0.11+ API — use `vim.lsp.config()` + `vim.lsp.enable()`, not `lspconfig.server.setup()`
- Keymaps defined in which-key — check `lua/plugins/which-key.lua` before adding new bindings

## Security
- Never commit secrets, tokens, or API keys
- Never suggest hardcoding credentials
- Sanitize inputs at system boundaries (user input, external APIs)
