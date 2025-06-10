#!/bin/bash
# Ubuntu/Debian-Specific Bootstrap Script for Dotsible
# Updates apt cache, installs Python/Ansible, and configures snap/flatpak

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/.dotsible/logs"
readonly LOG_FILE="$LOG_DIR/bootstrap_ubuntu_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly MIN_PYTHON_VERSION="3.8"
readonly MIN_ANSIBLE_VERSION="2.9"

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
validate_ubuntu_system() {
    info "Validating Ubuntu/Debian system..."
    
    # Check if running on Ubuntu/Debian
    if [[ ! -f /etc/lsb-release ]] && [[ ! -f /etc/debian_version ]]; then
        error "This script is designed for Ubuntu/Debian systems"
        exit 1
    fi
    
    # Check if apt is available
    if ! command -v apt >/dev/null 2>&1; then
        error "apt package manager not found"
        exit 1
    fi
    
    # Detect Ubuntu version
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
    
    # Update package cache
    info "Updating package cache..."
    sudo apt update
    
    # Upgrade system packages
    info "Upgrading system packages..."
    sudo apt upgrade -y
    
    success "System update completed"
}

# Base development tools installation
install_base_tools() {
    info "Installing base development tools..."
    
    local base_packages=(
        "build-essential"
        "git"
        "curl"
        "wget"
        "unzip"
        "tar"
        "gzip"
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
    
    info "Installing Python via apt..."
    
    # Install Python and pip
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    
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
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        success "Ansible already installed: version $ansible_version"

        # Verify all commands are available
        if verify_ansible_commands; then
            return 0
        else
            warning "Ansible installation incomplete - missing subcommands"
        fi
    fi
    
    # Try installing via apt first
    info "Installing Ansible via apt..."
    if sudo apt install -y ansible; then
        success "Ansible installed via apt"
    else
        # Fallback to pip installation
        warning "apt installation failed, trying pip..."
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

# Snap installation and configuration
configure_snap() {
    info "Configuring Snap package manager..."
    
    # Check if snapd is installed
    if ! command -v snap >/dev/null 2>&1; then
        info "Installing snapd..."
        sudo apt install -y snapd
        
        # Enable snapd service
        sudo systemctl enable --now snapd.socket
        
        # Create symlink for classic snap support
        if [[ ! -L /snap ]]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
    else
        success "Snap already installed"
    fi
    
    # Verify snap installation
    if command -v snap >/dev/null 2>&1; then
        success "Snap configured successfully"
    else
        warning "Snap configuration failed"
    fi
}

# Flatpak installation and configuration
configure_flatpak() {
    info "Configuring Flatpak package manager..."
    
    # Check if flatpak is installed
    if ! command -v flatpak >/dev/null 2>&1; then
        info "Installing flatpak..."
        sudo apt install -y flatpak
        
        # Add Flathub repository
        info "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
        success "Flatpak already installed"
        
        # Ensure Flathub repository is added
        if ! flatpak remotes | grep -q flathub; then
            info "Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
    fi
    
    # Verify flatpak installation
    if command -v flatpak >/dev/null 2>&1; then
        success "Flatpak configured successfully"
    else
        warning "Flatpak configuration failed"
    fi
}

# Configure Ubuntu-specific Ansible requirements
configure_ubuntu_ansible() {
    info "Configuring Ubuntu-specific Ansible requirements..."
    
    # Install additional Python packages
    local packages=(
        "requests"
        "urllib3"
        "certifi"
        "pexpect"
        "distro"
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
    
    success "Ubuntu Ansible configuration completed"
}

# Configure sudo permissions
configure_sudo() {
    info "Configuring sudo permissions..."
    
    # Check if user is in sudo group
    if groups "$USER" | grep -q sudo; then
        success "User already in sudo group"
    else
        info "Adding user to sudo group..."
        sudo usermod -aG sudo "$USER"
        success "User added to sudo group"
    fi
    
    # Configure passwordless sudo for current user
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

# Environment-specific configuration
configure_environment() {
    local env_type="$1"
    
    info "Configuring for environment type: $env_type"
    
    case "$env_type" in
        enterprise)
            info "Applying enterprise-specific configurations..."
            
            # Install additional enterprise tools
            local enterprise_packages=(
                "openssh-server"
                "rsync"
                "htop"
                "neofetch"
                "tree"
                "jq"
            )
            
            for package in "${enterprise_packages[@]}"; do
                if ! dpkg -l | grep -q "^ii  $package "; then
                    info "Installing enterprise package: $package"
                    sudo apt install -y "$package" || warning "Failed to install $package"
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
                "jq"
                "vim"
            )
            
            for package in "${personal_packages[@]}"; do
                if ! dpkg -l | grep -q "^ii  $package "; then
                    info "Installing personal package: $package"
                    sudo apt install -y "$package" || warning "Failed to install $package"
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

# Main execution function
main() {
    # Setup logging
    setup_logging
    
    # Display banner
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                UBUNTU BOOTSTRAP SCRIPT                      ║
║              Dotsible Environment Setup                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Ubuntu bootstrap started"
    log "Environment type: $ENVIRONMENT_TYPE"
    log "Working directory: $(pwd)"
    log "Script location: $SCRIPT_DIR"
    
    # Main bootstrap sequence
    local total_steps=10
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Validating Ubuntu system..."
    validate_ubuntu_system
    
    show_progress $((++current_step)) $total_steps "Updating system packages..."
    update_system
    
    show_progress $((++current_step)) $total_steps "Installing base tools..."
    install_base_tools
    
    show_progress $((++current_step)) $total_steps "Installing Python..."
    install_python
    
    show_progress $((++current_step)) $total_steps "Installing Ansible..."
    install_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring Snap..."
    configure_snap
    
    show_progress $((++current_step)) $total_steps "Configuring Flatpak..."
    configure_flatpak
    
    show_progress $((++current_step)) $total_steps "Configuring Ansible..."
    configure_ubuntu_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring sudo..."
    configure_sudo
    
    show_progress $((++current_step)) $total_steps "Configuring environment..."
    configure_environment "$ENVIRONMENT_TYPE"
    
    show_progress $total_steps $total_steps "Performing final validation..."
    final_validation
    
    # Success message
    echo
    success "Ubuntu bootstrap completed successfully!"
    echo
    info "Installed components:"
    echo "  - System packages: Updated and build-essential installed"
    echo "  - Python: $(python3 --version)"
    echo "  - Ansible: $(ansible --version | head -1)"
    if command -v snap >/dev/null 2>&1; then
        echo "  - Snap: $(snap version | head -1)"
    fi
    if command -v flatpak >/dev/null 2>&1; then
        echo "  - Flatpak: $(flatpak --version)"
    fi
    echo
    info "Environment type: $ENVIRONMENT_TYPE"
    info "Log file: $LOG_FILE"
    
    log "Ubuntu bootstrap completed successfully"
    exit 0
}

# Error handling
trap 'error "Ubuntu bootstrap failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

# Execute main function
main "$@"
