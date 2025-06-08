#!/bin/bash
# macOS-Specific Bootstrap Script for Dotsible
set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

# Logging
LOG_DIR="$HOME/.dotsible/logs"
LOG_FILE="$LOG_DIR/bootstrap_macos_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() { echo "$(date) [INFO] $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}$(date) [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2; }
success() { echo -e "${GREEN}$(date) [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}$(date) [INFO] $*${NC}" | tee -a "$LOG_FILE"; }

ENVIRONMENT_TYPE="${1:-personal}"

main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  macOS BOOTSTRAP SCRIPT                     ║${NC}"
    echo -e "${BLUE}║              Dotsible Environment Setup                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    log "macOS bootstrap started for environment: $ENVIRONMENT_TYPE"
    
    # Check for Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        info "Please complete the Xcode Command Line Tools installation and re-run this script"
        exit 1
    fi
    success "Xcode Command Line Tools: $(xcode-select -p)"
    
    # Install Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        success "Homebrew already installed"
        brew update
    fi
    
    # Install Python
    if ! command -v python3 >/dev/null 2>&1 || ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
        info "Installing Python..."
        brew install python3
    fi
    success "Python: $(python3 --version)"
    
    # Install Ansible
    if ! command -v ansible >/dev/null 2>&1; then
        info "Installing Ansible..."
        python3 -m pip install --user ansible
        
        # Add pip user bin to PATH
        PIP_USER_BIN="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin"
        if [[ -d "$PIP_USER_BIN" ]] && [[ ":$PATH:" != *":$PIP_USER_BIN:"* ]]; then
            export PATH="$PIP_USER_BIN:$PATH"
        fi
    fi
    success "Ansible: $(ansible --version | head -1)"
    
    # Test Ansible
    if ansible localhost -m ping >/dev/null 2>&1; then
        success "Ansible functionality verified"
    else
        info "Ansible ping test failed, but installation appears successful"
    fi
    
    success "macOS bootstrap completed successfully!"
    info "Environment: $ENVIRONMENT_TYPE"
    info "Log: $LOG_FILE"
}

trap 'error "macOS bootstrap failed at line $LINENO"; exit 1' ERR
main "$@"
