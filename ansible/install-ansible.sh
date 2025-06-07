#!/bin/bash

# install-ansible.sh - Comprehensive Ansible installation and configuration for macOS
# Usage: ./install-ansible.sh [--test]

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_PYTHON_NOT_FOUND=1
readonly EXIT_PYTHON_VERSION_INCOMPATIBLE=2
readonly EXIT_ANSIBLE_INSTALL_FAILED=3
readonly EXIT_PATH_CONFIG_FAILED=4
readonly EXIT_VERIFICATION_FAILED=5

# Configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="ansible-install-$(date +%Y%m%d-%H%M%S).log"
readonly MIN_PYTHON_VERSION="3.8"
readonly TEST_MODE="${1:-}"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# Print functions with colors
print_success() {
    echo -e "${GREEN}✓ $*${NC}" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}✗ $*${NC}" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}⚠ $*${NC}" | tee -a "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}ℹ $*${NC}" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "\n${BLUE}=== $* ===${NC}" | tee -a "$LOG_FILE"
}

# Version comparison function
version_compare() {
    local version1="$1"
    local version2="$2"

    # Convert versions to comparable format (e.g., 3.9.6 -> 3009006)
    local v1=$(echo "$version1" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')
    local v2=$(echo "$version2" | awk -F. '{printf "%d%03d%03d", $1, $2, $3}')

    if [[ "$v1" -ge "$v2" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if Python 3 is installed and meets minimum version
check_python() {
    print_header "Checking Python 3 Installation"
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed or not in PATH"
        print_error "Please install Python 3.8+ from https://www.python.org/downloads/"
        exit $EXIT_PYTHON_NOT_FOUND
    fi
    
    local python_version
    python_version=$(python3 --version 2>&1 | awk '{print $2}')
    print_info "Detected Python version: $python_version"
    
    if ! version_compare "$python_version" "$MIN_PYTHON_VERSION"; then
        print_error "Python version $python_version is below minimum required version $MIN_PYTHON_VERSION"
        print_error "Please upgrade Python to version $MIN_PYTHON_VERSION or higher"
        exit $EXIT_PYTHON_VERSION_INCOMPATIBLE
    fi
    
    print_success "Python $python_version meets requirements"
    echo "$python_version"
}

# Install Ansible using pip
install_ansible() {
    print_header "Installing Ansible"
    
    # Check if Ansible is already installed and accessible
    if command -v ansible &> /dev/null; then
        local ansible_version
        ansible_version=$(ansible --version | head -n1 | awk '{print $3}' | tr -d '[]')
        print_warning "Ansible $ansible_version is already installed and accessible"
        print_info "Skipping installation step"
        return 0
    fi
    
    print_info "Installing Ansible using pip..."
    log "Running: python3 -m pip install --user ansible"
    
    if python3 -m pip install --user ansible 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Ansible installation completed"
    else
        print_error "Failed to install Ansible"
        print_error "Check the log file for details: $LOG_FILE"
        exit $EXIT_ANSIBLE_INSTALL_FAILED
    fi
}

# Detect shell and configure PATH
configure_path() {
    print_header "Configuring PATH"
    
    local shell_name
    shell_name=$(basename "$SHELL")
    print_info "Detected shell: $shell_name"
    
    local python_version="$1"
    local python_major_minor
    python_major_minor=$(echo "$python_version" | cut -d. -f1-2)
    
    local ansible_bin_path="/Users/$USER/Library/Python/$python_major_minor/bin"
    local path_export="export PATH=\"$ansible_bin_path:\$PATH\""
    
    local config_file
    case "$shell_name" in
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        bash)
            # Prefer .bash_profile on macOS, fallback to .bashrc
            if [[ -f "$HOME/.bash_profile" ]] || [[ ! -f "$HOME/.bashrc" ]]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
        *)
            print_warning "Unsupported shell: $shell_name"
            print_warning "Please manually add $ansible_bin_path to your PATH"
            return 0
            ;;
    esac
    
    print_info "Using configuration file: $config_file"
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        print_info "Creating $config_file"
        touch "$config_file"
    fi
    
    # Check if PATH export already exists
    if grep -q "$ansible_bin_path" "$config_file" 2>/dev/null; then
        print_warning "PATH already configured in $config_file"
    else
        print_info "Adding PATH export to $config_file"
        echo "" >> "$config_file"
        echo "# Added by $SCRIPT_NAME on $(date)" >> "$config_file"
        echo "$path_export" >> "$config_file"
        print_success "PATH configuration added"
    fi
    
    # Source the configuration file
    print_info "Reloading shell configuration..."
    if source "$config_file" 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Shell configuration reloaded"
    else
        print_warning "Failed to reload shell configuration automatically"
        print_info "Please run: source $config_file"
    fi
}

# Verify installation
verify_installation() {
    print_header "Verifying Installation"
    
    # Check if ansible is in PATH
    if ! command -v ansible &> /dev/null; then
        print_error "Ansible is not accessible in PATH"
        print_error "You may need to restart your terminal or run: source ~/.zshrc"
        exit $EXIT_VERIFICATION_FAILED
    fi
    
    local ansible_path
    ansible_path=$(which ansible)
    print_success "Ansible found at: $ansible_path"
    
    # Get and display version
    local ansible_version
    ansible_version=$(ansible --version | head -n1)
    print_success "Version: $ansible_version"
    
    # Verify core commands
    local commands=("ansible-playbook" "ansible-galaxy" "ansible-vault")
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "$cmd is accessible"
        else
            print_error "$cmd is not accessible"
            exit $EXIT_VERIFICATION_FAILED
        fi
    done
    
    print_success "All Ansible commands verified successfully"
}

# Test playbook syntax if requested
test_playbook() {
    if [[ "$TEST_MODE" == "--test" ]]; then
        print_header "Testing Playbook"
        
        local playbook_path="ansible/macsible.yaml"
        if [[ -f "$playbook_path" ]]; then
            print_info "Running syntax check on $playbook_path"
            if ansible-playbook --syntax-check "$playbook_path" 2>&1 | tee -a "$LOG_FILE"; then
                print_success "Playbook syntax is valid"
                
                echo -e "\n${YELLOW}Would you like to run the playbook now? (y/N)${NC}"
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    print_info "Running playbook..."
                    ansible-playbook -c local -i localhost, "$playbook_path"
                fi
            else
                print_error "Playbook syntax check failed"
                exit $EXIT_VERIFICATION_FAILED
            fi
        else
            print_warning "Playbook not found at $playbook_path"
        fi
    fi
}

# Main execution
main() {
    print_header "Ansible Installation Script for macOS"
    log "Starting Ansible installation process"
    log "Script: $SCRIPT_NAME"
    log "User: $USER"
    log "Shell: $SHELL"
    log "Working directory: $(pwd)"
    
    # Step 1: Check Python
    local python_version
    python_version=$(check_python)
    
    # Step 2: Install Ansible
    install_ansible
    
    # Step 3: Configure PATH
    configure_path "$python_version"
    
    # Step 4: Verify installation
    verify_installation
    
    # Step 5: Optional testing
    test_playbook
    
    # Summary
    print_header "Installation Summary"
    print_success "Ansible installation and configuration completed successfully!"
    print_info "Log file: $LOG_FILE"
    print_info "You can now run: ansible-playbook -c local -i localhost, ansible/macsible.yaml"
    
    if [[ "$TEST_MODE" != "--test" ]]; then
        print_info "Tip: Run '$SCRIPT_NAME --test' to validate your playbook"
    fi
    
    log "Installation completed successfully"
}

# Run main function
main "$@"
