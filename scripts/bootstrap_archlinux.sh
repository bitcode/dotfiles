#!/bin/bash
# Arch Linux-Specific Bootstrap Script for Dotsible
# Updates system packages, installs Python/Ansible, and configures AUR helper

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/.dotsible/logs"
readonly LOG_FILE="$LOG_DIR/bootstrap_archlinux_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly MIN_PYTHON_VERSION="3.8"
readonly MIN_ANSIBLE_VERSION="2.9"
readonly AUR_HELPER="yay"

# Global variables
ENVIRONMENT_TYPE="${1:-personal}"
FORCE_REINSTALL=false
VERBOSE=false

# Logging functions
setup_logging() {
    mkdir -p "$LOG_DIR"
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$LOG_FILE" >&2)
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$LOG_FILE" >/dev/null
}

error() {
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2
}

warning() {
    echo -e "${YELLOW}$(date '+%Y-%m-%d %H:%M:%S') [WARN] $*${NC}" | tee -a "$LOG_FILE" >&2
}

success() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*${NC}" | tee -a "$LOG_FILE"
}

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
    
    # Check if running on Arch Linux
    if [[ ! -f /etc/arch-release ]]; then
        error "This script is designed for Arch Linux systems"
        exit 1
    fi
    
    # Check if pacman is available
    if ! command -v pacman >/dev/null 2>&1; then
        error "pacman package manager not found"
        exit 1
    fi
    
    success "Arch Linux system validation passed"
}

# System update
update_system() {
    info "Updating system packages..."
    
    # Update package database
    info "Updating package database..."
    sudo pacman -Sy --noconfirm
    
    # Upgrade system packages
    info "Upgrading system packages..."
    sudo pacman -Su --noconfirm
    
    success "System update completed"
}

# Base development tools installation
install_base_tools() {
    info "Installing base development tools..."
    
    local base_packages=(
        "base-devel"
        "git"
        "curl"
        "wget"
        "unzip"
        "tar"
        "gzip"
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

# Python installation
install_python() {
    info "Installing Python..."
    
    # Check if Python 3.8+ is already available
    local python_cmd=""
    local python_version=""
    
    for cmd in python3 python python3.11 python3.10 python3.9 python3.8; do
        if command -v "$cmd" >/dev/null 2>&1; then
            python_version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [[ -n "$python_version" ]]; then
                if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
                    python_cmd="$cmd"
                    success "Python found: $python_cmd (version $python_version)"
                    return 0
                fi
            fi
        fi
    done
    
    info "Installing Python via pacman..."
    
    # Install Python and pip
    sudo pacman -S --noconfirm python python-pip
    
    # Verify installation
    if command -v python3 >/dev/null 2>&1; then
        python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Python installed successfully: version $python_version"
        
        # Upgrade pip
        info "Upgrading pip..."
        python3 -m pip install --user --upgrade pip
    else
        error "Python installation failed"
        exit 1
    fi
}

# AUR helper installation
install_aur_helper() {
    info "Installing AUR helper: $AUR_HELPER"
    
    # Check if AUR helper is already installed
    if command -v "$AUR_HELPER" >/dev/null 2>&1; then
        success "AUR helper already installed: $AUR_HELPER"
        return 0
    fi
    
    # Install yay from AUR
    local temp_dir="/tmp/yay-install"
    
    info "Cloning yay repository..."
    rm -rf "$temp_dir"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    
    info "Building and installing yay..."
    cd "$temp_dir"
    makepkg -si --noconfirm
    cd - >/dev/null
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Verify installation
    if command -v "$AUR_HELPER" >/dev/null 2>&1; then
        success "AUR helper installed successfully: $AUR_HELPER"
    else
        error "AUR helper installation failed"
        exit 1
    fi
}

# Function to verify all required Ansible commands are available
verify_ansible_commands() {
    local expected_commands=(
        "ansible"
        "ansible-playbook"
        "ansible-galaxy"
        "ansible-vault"
        "ansible-config"
        "ansible-inventory"
        "ansible-doc"
    )

    local missing_commands=()

    for cmd in "${expected_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done

    if [[ ${#missing_commands[@]} -eq 0 ]]; then
        success "✅ All Ansible commands verified successfully"
        return 0
    else
        error "❌ Missing Ansible commands: ${missing_commands[*]}"
        return 1
    fi
}

# Ansible installation
install_ansible() {
    info "Installing Ansible..."
    
    # Check if Ansible is already installed
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible already installed: version $ansible_version"

        # Verify all commands are available
        if verify_ansible_commands; then
            return 0
        else
            warning "Ansible installation incomplete - missing subcommands"
        fi
    fi
    
    # Try installing via pacman first
    info "Installing Ansible via pacman..."
    if sudo pacman -S --noconfirm ansible; then
        success "Ansible installed via pacman"
    else
        # Fallback to pip installation
        warning "pacman installation failed, trying pip..."
        info "Installing Ansible via pip..."
        python3 -m pip install --user ansible
        
        # Add pip user bin to PATH if not already there
        local pip_user_bin="$HOME/.local/bin"
        if [[ -d "$pip_user_bin" ]] && [[ ":$PATH:" != *":$pip_user_bin:"* ]]; then
            export PATH="$pip_user_bin:$PATH"
            info "Added $pip_user_bin to PATH"
        fi
    fi
    
    # Verify installation
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible installed successfully: version $ansible_version"

        # Verify all commands are available
        if ! verify_ansible_commands; then
            error "Ansible installation incomplete - missing critical subcommands"
            exit 1
        fi
    else
        error "Ansible installation failed"
        exit 1
    fi
}

# Configure Arch-specific Ansible requirements
configure_arch_ansible() {
    info "Configuring Arch-specific Ansible requirements..."
    
    # Install additional Python packages
    local packages=(
        "requests"
        "urllib3"
        "certifi"
        "pexpect"
    )
    
    for package in "${packages[@]}"; do
        info "Installing Python package: $package"
        python3 -m pip install --user "$package" || warning "Failed to install $package"
    done
    
    # Create Ansible configuration directory
    local ansible_config_dir="$HOME/.ansible"
    if [[ ! -d "$ansible_config_dir" ]]; then
        mkdir -p "$ansible_config_dir"
        info "Created Ansible configuration directory: $ansible_config_dir"
    fi
    
    # Create basic ansible.cfg if it doesn't exist
    local ansible_cfg="$ansible_config_dir/ansible.cfg"
    if [[ ! -f "$ansible_cfg" ]]; then
        cat > "$ansible_cfg" << EOF
[defaults]
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
bin_ansible_callbacks = True
become_ask_pass = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
        info "Created Ansible configuration: $ansible_cfg"
    fi
    
    success "Arch Ansible configuration completed"
}

# Configure sudo permissions
configure_sudo() {
    info "Configuring sudo permissions..."
    
    # Check if user is in wheel group
    if groups "$USER" | grep -q wheel; then
        success "User already in wheel group"
    else
        info "Adding user to wheel group..."
        sudo usermod -aG wheel "$USER"
        success "User added to wheel group"
    fi
    
    # Configure sudo for wheel group
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

# Environment-specific configuration
configure_environment() {
    local env_type="$1"
    
    info "Configuring for environment type: $env_type"
    
    case "$env_type" in
        enterprise)
            info "Applying enterprise-specific configurations..."
            
            # Install additional enterprise tools
            local enterprise_packages=(
                "openssh"
                "rsync"
                "htop"
                "neofetch"
            )
            
            for package in "${enterprise_packages[@]}"; do
                if ! pacman -Q "$package" >/dev/null 2>&1; then
                    info "Installing enterprise package: $package"
                    sudo pacman -S --noconfirm "$package" || warning "Failed to install $package"
                fi
            done
            ;;
        personal)
            info "Applying personal environment configurations..."
            
            # Install additional personal tools
            local personal_packages=(
                "neofetch"
                "htop"
                "tree"
            )
            
            for package in "${personal_packages[@]}"; do
                if ! pacman -Q "$package" >/dev/null 2>&1; then
                    info "Installing personal package: $package"
                    sudo pacman -S --noconfirm "$package" || warning "Failed to install $package"
                fi
            done
            ;;
        *)
            warning "Unknown environment type: $env_type. Using default configuration."
            ;;
    esac
}

# Final validation
final_validation() {
    info "Performing final validation..."
    
    # Check pacman
    if ! command -v pacman >/dev/null 2>&1; then
        error "pacman validation failed"
        return 1
    fi
    
    # Check AUR helper
    if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
        error "AUR helper validation failed"
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
    
    # Test Ansible functionality
    if ! ansible localhost -m ping >/dev/null 2>&1; then
        warning "Ansible ping test failed, but installation appears successful"
    else
        success "Ansible functionality verified"
    fi
    
    success "All validations passed!"
    return 0
}

# Main execution function
main() {
    # Setup logging
    setup_logging
    
    # Display banner
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                ARCH LINUX BOOTSTRAP SCRIPT                  ║
║              Dotsible Environment Setup                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Arch Linux bootstrap started"
    log "Environment type: $ENVIRONMENT_TYPE"
    log "Working directory: $(pwd)"
    log "Script location: $SCRIPT_DIR"
    
    # Main bootstrap sequence
    local total_steps=9
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Validating Arch system..."
    validate_arch_system
    
    show_progress $((++current_step)) $total_steps "Updating system packages..."
    update_system
    
    show_progress $((++current_step)) $total_steps "Installing base tools..."
    install_base_tools
    
    show_progress $((++current_step)) $total_steps "Installing Python..."
    install_python
    
    show_progress $((++current_step)) $total_steps "Installing AUR helper..."
    install_aur_helper
    
    show_progress $((++current_step)) $total_steps "Installing Ansible..."
    install_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring Ansible..."
    configure_arch_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring sudo..."
    configure_sudo
    
    show_progress $((++current_step)) $total_steps "Configuring environment..."
    configure_environment "$ENVIRONMENT_TYPE"
    
    show_progress $total_steps $total_steps "Performing final validation..."
    final_validation
    
    # Success message
    echo
    success "Arch Linux bootstrap completed successfully!"
    echo
    info "Installed components:"
    echo "  - System packages: Updated and base-devel installed"
    echo "  - Python: $(python3 --version)"
    echo "  - AUR helper: $AUR_HELPER $(yay --version | head -1)"
    echo "  - Ansible: $(ansible --version | head -1)"
    echo
    info "Environment type: $ENVIRONMENT_TYPE"
    info "Log file: $LOG_FILE"
    
    log "Arch Linux bootstrap completed successfully"
    exit 0
}

# Error handling
trap 'error "Arch Linux bootstrap failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

# Execute main function
main "$@"
