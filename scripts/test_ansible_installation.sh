#!/bin/bash
# Test script to verify Ansible installation with --include-deps flag

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
error() {
    echo -e "${RED}[ERROR] $*${NC}" >&2
}

warning() {
    echo -e "${YELLOW}[WARN] $*${NC}" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS] $*${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $*${NC}"
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
        "ansible-console"
        "ansible-pull"
        "ansible-test"
        "ansible-connection"
    )

    local missing_commands=()
    local available_commands=()

    info "🔍 Verifying Ansible commands availability..."

    for cmd in "${expected_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            available_commands+=("$cmd")
            success "  ✅ $cmd: $(which "$cmd")"
        else
            missing_commands+=("$cmd")
            error "  ❌ $cmd: Not found"
        fi
    done

    echo
    info "📊 Summary:"
    info "  Available commands: ${#available_commands[@]}"
    info "  Missing commands: ${#missing_commands[@]}"

    if [[ ${#missing_commands[@]} -eq 0 ]]; then
        success "✅ All Ansible commands verified successfully"
        return 0
    else
        error "❌ Missing Ansible commands: ${missing_commands[*]}"
        echo
        warning "💡 To fix this issue, run:"
        echo "  pipx uninstall ansible"
        echo "  pipx install --include-deps ansible"
        return 1
    fi
}

# Test current installation
test_current_installation() {
    info "🧪 Testing current Ansible installation..."
    
    # Check if pipx is available
    if ! command -v pipx >/dev/null 2>&1; then
        error "pipx is not available. Please install pipx first."
        return 1
    fi
    
    # Check if Ansible is installed via pipx
    if ! pipx list | grep -q ansible; then
        warning "Ansible is not installed via pipx"
        return 1
    fi
    
    # Verify commands
    verify_ansible_commands
}

# Demonstrate the fix
demonstrate_fix() {
    info "🔧 Demonstrating the fix..."
    
    if ! command -v pipx >/dev/null 2>&1; then
        error "pipx is not available. Cannot demonstrate fix."
        return 1
    fi
    
    info "Current pipx packages:"
    pipx list | grep -E "(ansible|community-ansible-dev-tools|ansible-lint)" || echo "No Ansible packages found"
    
    echo
    warning "⚠️  To fix incomplete Ansible installation, run:"
    echo "  pipx uninstall ansible"
    echo "  pipx install --include-deps ansible"
    echo
    info "The --include-deps flag ensures all Ansible subcommands are installed"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║              ANSIBLE INSTALLATION TEST SCRIPT               ║
║                  Verifying --include-deps Fix               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    if test_current_installation; then
        success "🎉 Ansible installation is complete and working correctly!"
    else
        warning "⚠️  Ansible installation needs attention"
        demonstrate_fix
    fi
    
    echo
    info "📚 For more information, see:"
    echo "  - Official Ansible docs: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html"
    echo "  - pipx documentation: https://pipx.pypa.io/"
}

# Execute main function
main "$@"
