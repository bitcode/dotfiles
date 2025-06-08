#!/bin/bash
# Ubuntu/Debian-Specific Bootstrap Script for Dotsible
set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

# Logging
LOG_DIR="$HOME/.dotsible/logs"
LOG_FILE="$LOG_DIR/bootstrap_ubuntu_$(date +%Y%m%d_%H%M%S).log"
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
validate_ubuntu_system() {
    info "Validating Ubuntu/Debian system..."
    
    if [[ ! -f /etc/lsb-release ]] && [[ ! -f /etc/debian_version ]]; then
        error "This script is designed for Ubuntu/Debian systems"
        exit 1
    fi
    
    if ! command -v apt >/dev/null 2>&1; then
        error "apt package manager not found"
        exit 1
    fi
    
    if [[ -f /etc/lsb-release ]]; then
        local ubuntu_version
        ubuntu_version=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d= -f2)
        info "Detected Ubuntu version: $ubuntu_version"
    elif [[ -f /etc/debian_version ]]; then
        local debian_version
        debian_version=$(cat /etc/debian_version)
        info "Detected Debian version: $debian_version"
    fi
    
    success "Ubuntu/Debian system validation passed"
}

# System update
update_system() {
    info "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    success "System update completed"
}

# Base development tools
install_base_tools() {
    info "Installing base development tools..."
    
    local base_packages=(
        "build-essential"
        "git"
        "curl"
        "wget"
        "python3"
        "python3-pip"
        "python3-venv"
        "python3-dev"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "sudo"
    )
    
    for package in "${base_packages[@]}"; do
        if dpkg -l | grep -q "^ii  $package "; then
            success "Base package already installed: $package"
        else
            info "Installing base package: $package"
            sudo apt install -y "$package"
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
    
    # Upgrade pip
    info "Upgrading pip..."
    python3 -m pip install --user --upgrade pip
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
    
    # Try apt first
    if sudo apt install -y ansible; then
        success "Ansible installed via apt"
    else
        warning "apt installation failed, trying pip..."
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

# Configure snap
configure_snap() {
    info "Configuring Snap package manager..."
    
    if ! command -v snap >/dev/null 2>&1; then
        info "Installing snapd..."
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        
        if [[ ! -L /snap ]]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
    else
        success "Snap already installed"
    fi
    
    if command -v snap >/dev/null 2>&1; then
        success "Snap configured successfully"
    else
        warning "Snap configuration failed"
    fi
}

# Configure flatpak
configure_flatpak() {
    info "Configuring Flatpak package manager..."
    
    if ! command -v flatpak >/dev/null 2>&1; then
        info "Installing flatpak..."
        sudo apt install -y flatpak
        
        info "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        success "Flatpak already installed"
        
        if ! flatpak remotes | grep -q flathub; then
            info "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
    fi
    
    if command -v flatpak >/dev/null 2>&1; then
        success "Flatpak configured successfully"
    else
        warning "Flatpak configuration failed"
    fi
}

# Configure sudo permissions
configure_sudo() {
    info "Configuring sudo permissions..."
    
    if groups "$USER" | grep -q sudo; then
        success "User already in sudo group"
    else
        info "Adding user to sudo group..."
        sudo usermod -aG sudo "$USER"
        success "User added to sudo group"
    fi
    
    local sudoers_file="/etc/sudoers.d/$USER"
    if [[ ! -f "$sudoers_file" ]]; then
        info "Configuring passwordless sudo..."
        echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "$sudoers_file" >/dev/null
        sudo chmod 440 "$sudoers_file"
        success "Passwordless sudo configured"
    else
        success "Sudo already configured for user"
    fi
}

# Final validation
final_validation() {
    info "Performing final validation..."
    
    # Check apt
    if ! command -v apt >/dev/null 2>&1; then
        error "apt validation failed"
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
    
    # Check snap (optional)
    if command -v snap >/dev/null 2>&1; then
        success "Snap available"
    else
        warning "Snap not available"
    fi
    
    # Check flatpak (optional)
    if command -v flatpak >/dev/null 2>&1; then
        success "Flatpak available"
    else
        warning "Flatpak not available"
    fi
    
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
    echo -e "${BLUE}║                UBUNTU BOOTSTRAP SCRIPT                      ║${NC}"
    echo -e "${BLUE}║              Dotsible Environment Setup                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    log "Ubuntu bootstrap started for environment: $ENVIRONMENT_TYPE"
    
    local total_steps=10
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Validating Ubuntu system..."
    validate_ubuntu_system
    
    show_progress $((++current_step)) $total_steps "Updating system..."
    update_system
    
    show_progress $((++current_step)) $total_steps "Installing base tools..."
    install_base_tools
    
    show_progress $((++current_step)) $total_steps "Validating Python..."
    validate_python
    
    show_progress $((++current_step)) $total_steps "Installing Ansible..."
    install_ansible
    
    show_progress $((++current_step)) $total_steps "Installing pipx..."
    install_pipx
    
    show_progress $((++current_step)) $total_steps "Installing Ansible dev tools..."
    install_ansible_dev_tools
    
    show_progress $((++current_step)) $total_steps "Configuring Snap..."
    configure_snap
    
    show_progress $((++current_step)) $total_steps "Configuring Flatpak..."
    configure_flatpak
    
    show_progress $((++current_step)) $total_steps "Configuring sudo..."
    configure_sudo
    
    show_progress $total_steps $total_steps "Performing final validation..."
    final_validation
    
    echo
    success "Ubuntu bootstrap completed successfully!"
    echo
    info "Installed components:"
    echo "  - System packages: Updated and build-essential installed"
    echo "  - Python: $(python3 --version)"
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
    if command -v snap >/dev/null 2>&1; then
        echo "  - Snap: $(snap version | head -1 2>/dev/null || echo 'installed')"
    fi
    if command -v flatpak >/dev/null 2>&1; then
        echo "  - Flatpak: $(flatpak --version 2>/dev/null || echo 'installed')"
    fi
    echo
    info "Environment: $ENVIRONMENT_TYPE"
    info "Log: $LOG_FILE"
}

trap 'error "Ubuntu bootstrap failed at line $LINENO"; exit 1' ERR
main "$@"
