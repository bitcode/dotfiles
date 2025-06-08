#!/bin/bash
# Universal Bootstrap Script for Cross-Platform Dotfiles System
set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

# Logging
LOG_DIR="$HOME/.dotsible/logs"
LOG_FILE="$LOG_DIR/bootstrap_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() { echo "$(date) [INFO] $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}$(date) [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2; }
success() { echo -e "${GREEN}$(date) [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}$(date) [INFO] $*${NC}" | tee -a "$LOG_FILE"; }

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then echo "archlinux"
            elif [[ -f /etc/lsb-release ]] && grep -q "Ubuntu" /etc/lsb-release; then echo "ubuntu"
            elif [[ -f /etc/debian_version ]]; then echo "ubuntu"
            else echo "linux"; fi ;;
        CYGWIN*|MINGW*|MSYS*)
            error "Windows detected. Please use bootstrap.ps1 for Windows systems."
            exit 1 ;;
        *) error "Unsupported OS: $(uname -s)"; exit 1 ;;
    esac
}

# Main function
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                    DOTSIBLE BOOTSTRAP                        ║${NC}"
    echo -e "${BLUE}║              Cross-Platform Environment Setup               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    log "Bootstrap started"
    
    PLATFORM=$(detect_platform)
    success "Detected platform: $PLATFORM"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BOOTSTRAP_SCRIPT="$SCRIPT_DIR/scripts/bootstrap_${PLATFORM}.sh"
    
    if [[ ! -f "$BOOTSTRAP_SCRIPT" ]]; then
        error "Bootstrap script not found: $BOOTSTRAP_SCRIPT"
        exit 1
    fi
    
    chmod +x "$BOOTSTRAP_SCRIPT"
    info "Executing: $BOOTSTRAP_SCRIPT"
    
    if "$BOOTSTRAP_SCRIPT" "personal"; then
        success "Platform-specific bootstrap completed successfully"
        echo
        success "Bootstrap completed successfully!"
        echo
        info "Next steps:"
        echo "  1. Run: ansible-playbook site.yml"
        echo "  2. Check logs: $LOG_FILE"
    else
        error "Platform-specific bootstrap failed"
        exit 1
    fi
}

trap 'error "Bootstrap failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR
main "$@"
