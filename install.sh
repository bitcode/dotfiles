#!/bin/bash
# One-liner entry point for a brand-new machine that doesn't have the
# dotfiles repo (or git) yet:
#
#   curl -fsSL https://raw.githubusercontent.com/bitcode/dotfiles/master/install.sh | bash
#
# Ensures git exists, clones the repo over HTTPS (no SSH key required),
# then hands off to bootstrap.sh for the rest of the platform-specific setup.
set -euo pipefail

readonly REPO_URL="https://github.com/bitcode/dotfiles.git"
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

log()     { echo -e "${BLUE}[install]${NC} $*"; }
success() { echo -e "${GREEN}[install]${NC} $*"; }
error()   { echo -e "${RED}[install]${NC} $*" >&2; }

ensure_git() {
    if command -v git >/dev/null 2>&1; then
        return 0
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        error "git is not installed and this isn't an Arch system (no pacman found)."
        error "Install git yourself, then clone the repo and run ./bootstrap.sh."
        exit 1
    fi

    log "git not found, installing via pacman..."
    sudo pacman -Sy --needed --noconfirm git
}

clone_or_update_repo() {
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        log "Found existing dotfiles repo at $DOTFILES_DIR, using it as-is."
        return 0
    fi

    if [[ -e "$DOTFILES_DIR" ]]; then
        error "$DOTFILES_DIR exists but is not a git repo. Move it aside or set DOTFILES_DIR to a different path."
        exit 1
    fi

    log "Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
}

main() {
    case "$(uname -s)" in
        Linux) ;;
        *)
            error "This one-liner targets fresh Linux (Arch) installs."
            error "On other platforms, clone the repo manually and run ./bootstrap.sh."
            exit 1
            ;;
    esac

    ensure_git
    clone_or_update_repo

    success "Repo ready at $DOTFILES_DIR"
    log "Handing off to bootstrap.sh..."
    cd "$DOTFILES_DIR"
    chmod +x ./bootstrap.sh
    exec ./bootstrap.sh "$@"
}

main "$@"
