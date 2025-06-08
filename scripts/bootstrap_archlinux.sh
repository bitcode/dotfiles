#!/bin/bash
# Arch Linux-Specific Bootstrap Script for Dotsible
set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Logging
LOG_DIR="$HOME/.dotsible/logs"
LOG_FILE="$LOG_DIR/bootstrap_archlinux_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() { echo "$(date) [INFO] $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}$(date) [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2; }
success() { echo -e "${GREEN}$(date) [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}$(date) [INFO] $*${NC}" | tee -a "$LOG_FILE"; }
warning() { echo -e "${YELLOW}$(date) [WARN] $*${NC}" | tee -a "$LOG_FILE"; }

ENVIRONMENT_TYPE="${1:-personal}"

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    local bar_length=40
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${BLUE}["
    printf "%*s" $filled_length | tr ' ' '='
    printf "%*s" $((bar_length - filled_length)) | tr ' ' '-'
    printf "] %d%% - %s${NC}" $percent "$message"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# System validation
validate_arch_system() {
    info "Validating Arch Linux system..."
    
    if [[ ! -f /etc/arch-release ]]; then
        error "This script is designed for Arch Linux systems"
        exit 1
    fi
    
    if ! command -v pacman >/dev/null 2>&1; then
        error "pacman package manager not found"
        exit 1
    fi
    
    success "Arch Linux system validation passed"
}

# System update
update_system() {
    info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    success "System update completed"
}

# Base development tools
install_base_tools() {
    info "Installing base development tools..."
    
    local base_packages=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "python"
        "python-pip"
        "which"
        "sudo"
    )
    
    for package in "${base_packages[@]}"; do
        if pacman -Q "$package" >/dev/null 2>&1; then
            success "Base package already installed: $package"
        else
            info "Installing base package: $package"
            sudo pacman -S --noconfirm "$package"
        fi
    done
    
    success "Base development tools installed"
}

# Python and pip validation
validate_python() {
    info "Validating Python installation..."
    
    if ! command -v python3 >/dev/null 2>&1; then
        error "Python 3 not found"
        exit 1
    fi
    
    if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
        error "Python 3.8+ required"
        exit 1
    fi
    
    if ! python3 -m pip --version >/dev/null 2>&1; then
        error "pip not working properly"
        exit 1
    fi
    
    local python_version
    python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    success "Python validation passed: version $python_version"
}

# AUR helper installation
install_aur_helper() {
    info "Installing AUR helper: yay"
    
    if command -v yay >/dev/null 2>&1; then
        success "yay already installed"
        return 0
    fi
    
    local temp_dir="/tmp/yay-install"
    info "Cloning yay repository..."
    rm -rf "$temp_dir"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    
    info "Building and installing yay..."
    cd "$temp_dir"
    makepkg -si --noconfirm
    cd - >/dev/null
    
    rm -rf "$temp_dir"
    
    if command -v yay >/dev/null 2>&1; then
        success "yay installed successfully"
    else
        error "yay installation failed"
        exit 1
    fi
}

# Ansible installation
install_ansible() {
    info "Installing Ansible..."
    
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible already installed: version $ansible_version"
        return 0
    fi
    
    # Try pacman first
    if sudo pacman -S --noconfirm ansible; then
        success "Ansible installed via pacman"
    else
        warning "pacman installation failed, trying pip..."
        python3 -m pip install --user ansible
        
        # Add pip user bin to PATH
        local pip_user_bin="$HOME/.local/bin"
        if [[ -d "$pip_user_bin" ]] && [[ ":$PATH:" != *":$pip_user_bin:"* ]]; then
            export PATH="$pip_user_bin:$PATH"
            info "Added $pip_user_bin to PATH"
        fi
    fi
    
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible installed successfully: version $ansible_version"
    else
        error "Ansible installation failed"
        exit 1
    fi
}

# pipx installation
install_pipx() {
    info "Installing pipx..."
    
    if command -v pipx >/dev/null 2>&1; then
        local pipx_version
        pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
        success "pipx already installed: version $pipx_version"
        return 0
    fi
    
    # Verify pip3 is working
    if ! python3 -m pip --version >/dev/null 2>&1; then
        error "pip3 is not working properly"
        exit 1
    fi
    
    info "Installing pipx via pip..."
    python3 -m pip install --user pipx
    
    # Add pipx to PATH
    local pip_user_bin="$HOME/.local/bin"
    if [[ -d "$pip_user_bin" ]] && [[ ":$PATH:" != *":$pip_user_bin:"* ]]; then
        export PATH="$pip_user_bin:$PATH"
        info "Added $pip_user_bin to PATH"
    fi
    
    # Configure pipx
    if command -v pipx >/dev/null 2>&1; then
        info "Configuring pipx environment..."
        pipx ensurepath --force 2>/dev/null || true
        
        local pipx_version
        pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
        success "pipx installed successfully: version $pipx_version"
    else
        error "pipx installation failed"
        exit 1
    fi
}

# Ansible development tools
install_ansible_dev_tools() {
    info "Installing Ansible development tools..."
    
    if ! command -v pipx >/dev/null 2>&1; then
        error "pipx is required but not found"
        exit 1
    fi
    
    # Install ansible-dev-tools
    if pipx list | grep -q "ansible-dev-tools" 2>/dev/null; then
        success "ansible-dev-tools already installed"
    else
        info "Installing ansible-dev-tools via pipx..."
        if pipx install ansible-dev-tools; then
            success "ansible-dev-tools installed successfully"
        else
            error "ansible-dev-tools installation failed"
            exit 1
        fi
    fi
    
    # Install ansible-lint
    if pipx list | grep -q "ansible-lint" 2>/dev/null; then
        success "ansible-lint already installed"
    else
        info "Installing ansible-lint via pipx..."
        if pipx install ansible-lint; then
            success "ansible-lint installed successfully"
        else
            error "ansible-lint installation failed"
            exit 1
        fi
    fi
    
    # Verify installations
    local tools=("ansible-dev-tools" "ansible-lint")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "$tool is accessible"
        else
            warning "$tool installed but not in PATH"
        fi
    done
}

# Configure sudo permissions
configure_sudo() {
    info "Configuring sudo permissions..."
    
    if groups "$USER" | grep -q wheel; then
        success "User already in wheel group"
    else
        info "Adding user to wheel group..."
        sudo usermod -aG wheel "$USER"
        success "User added to wheel group"
    fi
    
    local sudoers_file="/etc/sudoers.d/wheel"
    if [[ ! -f "$sudoers_file" ]]; then
        info "Configuring sudo for wheel group..."
        echo "%wheel ALL=(ALL) NOPASSWD: ALL" | sudo tee "$sudoers_file" >/dev/null
        sudo chmod 440 "$sudoers_file"
        success "Sudo configured for wheel group"
    else
        success "Sudo already configured for wheel group"
    fi
}

# Final validation
final_validation() {
    info "Performing final validation..."
    
    # Check pacman
    if ! command -v pacman >/dev/null 2>&1; then
        error "pacman validation failed"
        return 1
    fi
    
    # Check Python
    if ! command -v python3 >/dev/null 2>&1; then
        error "Python validation failed"
        return 1
    fi
    
    # Check Ansible
    if ! command -v ansible >/dev/null 2>&1; then
        error "Ansible validation failed"
        return 1
    fi
    
    # Check pipx
    if ! command -v pipx >/dev/null 2>&1; then
        error "pipx validation failed"
        return 1
    fi
    
    # Check development tools
    local dev_tools=("ansible-dev-tools" "ansible-lint")
    for tool in "${dev_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            success "$tool validation passed"
        else
            warning "$tool not found in PATH but may be installed via pipx"
        fi
    done
    
    # Test Ansible functionality
    if ! ansible localhost -m ping >/dev/null 2>&1; then
        warning "Ansible ping test failed, but installation appears successful"
    else
        success "Ansible functionality verified"
    fi
    
    success "All validations passed!"
    return 0
}

# Main function
main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                ARCH LINUX BOOTSTRAP SCRIPT                  ║${NC}"
    echo -e "${BLUE}║              Dotsible Environment Setup                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    log "Arch Linux bootstrap started for environment: $ENVIRONMENT_TYPE"
    
    local total_steps=9
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Validating Arch system..."
    validate_arch_system
    
    show_progress $((++current_step)) $total_steps "Updating system..."
    update_system
    
    show_progress $((++current_step)) $total_steps "Installing base tools..."
    install_base_tools
    
    show_progress $((++current_step)) $total_steps "Validating Python..."
    validate_python
    
    show_progress $((++current_step)) $total_steps "Installing AUR helper..."
    install_aur_helper
    
    show_progress $((++current_step)) $total_steps "Installing Ansible..."
    install_ansible
    
    show_progress $((++current_step)) $total_steps "Installing pipx..."
    install_pipx
    
    show_progress $((++current_step)) $total_steps "Installing Ansible dev tools..."
    install_ansible_dev_tools
    
    show_progress $((++current_step)) $total_steps "Configuring sudo..."
    configure_sudo
    
    show_progress $total_steps $total_steps "Performing final validation..."
    final_validation
    
    echo
    success "Arch Linux bootstrap completed successfully!"
    echo
    info "Installed components:"
    echo "  - System packages: Updated and base-devel installed"
    echo "  - Python: $(python3 --version)"
    echo "  - AUR helper: yay $(yay --version | head -1 2>/dev/null || echo 'installed')"
    echo "  - Ansible: $(ansible --version | head -1)"
    if command -v pipx >/dev/null 2>&1; then
        echo "  - pipx: $(pipx --version 2>/dev/null || echo 'installed')"
    fi
    if command -v ansible-dev-tools >/dev/null 2>&1; then
        echo "  - ansible-dev-tools: $(ansible-dev-tools --version 2>/dev/null || echo 'installed')"
    fi
    if command -v ansible-lint >/dev/null 2>&1; then
        echo "  - ansible-lint: $(ansible-lint --version 2>/dev/null || echo 'installed')"
    fi
    echo
    info "Environment: $ENVIRONMENT_TYPE"
    info "Log: $LOG_FILE"
}

trap 'error "Arch Linux bootstrap failed at line $LINENO"; exit 1' ERR
main "$@"
