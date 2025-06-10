#!/bin/bash
# Test script to verify Homebrew installation and PATH management

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

# Test Homebrew installation
test_homebrew_installation() {
    info "🍺 Testing Homebrew installation..."
    
    if command -v brew >/dev/null 2>&1; then
        local brew_version
        brew_version=$(brew --version | head -1)
        local brew_path
        brew_path=$(which brew)
        success "✅ Homebrew is installed: $brew_version"
        success "✅ Homebrew location: $brew_path"
        return 0
    else
        error "❌ Homebrew is not installed or not in PATH"
        return 1
    fi
}

# Test Homebrew functionality
test_homebrew_functionality() {
    info "⚡ Testing Homebrew functionality..."
    
    # Test basic brew commands
    local commands=("--version" "list" "doctor")
    local failed_commands=()
    
    for cmd in "${commands[@]}"; do
        if brew $cmd >/dev/null 2>&1; then
            success "✅ brew $cmd: Working"
        else
            error "❌ brew $cmd: Failed"
            failed_commands+=("$cmd")
        fi
    done
    
    if [[ ${#failed_commands[@]} -eq 0 ]]; then
        success "✅ All Homebrew commands working"
        return 0
    else
        error "❌ Failed commands: ${failed_commands[*]}"
        return 1
    fi
}

# Test shell integration
test_shell_integration() {
    info "🐚 Testing shell integration..."
    
    local shell_configs=(
        "$HOME/.zprofile"
        "$HOME/.zshrc"
        "$HOME/.bash_profile"
        "$HOME/.bashrc"
        "$HOME/.profile"
    )
    
    local configured_files=()
    
    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]] && grep -q "brew shellenv" "$config" 2>/dev/null; then
            configured_files+=("$(basename "$config")")
            success "✅ Homebrew integration found in: $(basename "$config")"
        fi
    done
    
    if [[ ${#configured_files[@]} -gt 0 ]]; then
        success "✅ Shell integration configured in: ${configured_files[*]}"
        return 0
    else
        warning "⚠️  No Homebrew shell integration found"
        return 1
    fi
}

# Test PATH configuration
test_path_configuration() {
    info "🛤️  Testing PATH configuration..."
    
    # Check if Homebrew paths are in PATH
    local homebrew_paths=(
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        "/usr/local/bin"
        "/usr/local/sbin"
    )
    
    local found_paths=()
    
    for path in "${homebrew_paths[@]}"; do
        if [[ ":$PATH:" == *":$path:"* ]]; then
            found_paths+=("$path")
            success "✅ PATH includes: $path"
        fi
    done
    
    if [[ ${#found_paths[@]} -gt 0 ]]; then
        success "✅ Homebrew paths found in PATH: ${found_paths[*]}"
        return 0
    else
        error "❌ No Homebrew paths found in PATH"
        return 1
    fi
}

# Test package installation
test_package_installation() {
    info "📦 Testing package installation..."
    
    # Test installing a simple package
    local test_package="tree"
    
    # Check if already installed
    if brew list "$test_package" >/dev/null 2>&1; then
        success "✅ Test package '$test_package' already installed"
        return 0
    fi
    
    # Try to install
    info "Installing test package: $test_package"
    if brew install "$test_package" >/dev/null 2>&1; then
        success "✅ Successfully installed test package: $test_package"
        
        # Verify the command is available
        if command -v "$test_package" >/dev/null 2>&1; then
            success "✅ Test package command is available: $(which $test_package)"
            return 0
        else
            error "❌ Test package installed but command not available"
            return 1
        fi
    else
        error "❌ Failed to install test package: $test_package"
        return 1
    fi
}

# Test idempotency
test_idempotency() {
    info "🔄 Testing idempotency..."
    
    # Run brew doctor to check for issues
    local doctor_output
    doctor_output=$(brew doctor 2>&1 || true)
    
    if echo "$doctor_output" | grep -q "Your system is ready to brew"; then
        success "✅ Homebrew system is healthy"
        return 0
    elif echo "$doctor_output" | grep -q "Warning"; then
        warning "⚠️  Homebrew has warnings (this is often normal):"
        echo "$doctor_output" | grep "Warning" | head -3
        return 0
    else
        error "❌ Homebrew system has issues:"
        echo "$doctor_output" | head -5
        return 1
    fi
}

# Test environment variables
test_environment_variables() {
    info "🌍 Testing Homebrew environment variables..."
    
    local env_vars=(
        "HOMEBREW_PREFIX"
        "HOMEBREW_CELLAR"
        "HOMEBREW_REPOSITORY"
    )
    
    local configured_vars=0
    
    for var in "${env_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            success "✅ $var: ${!var}"
            ((configured_vars++))
        else
            info "ℹ️  $var: Not set"
        fi
    done
    
    if [[ $configured_vars -gt 0 ]]; then
        success "✅ $configured_vars Homebrew environment variables configured"
        return 0
    else
        warning "⚠️  No Homebrew environment variables configured"
        return 1
    fi
}

# Display system information
display_system_info() {
    info "💻 System Information:"
    echo "  • macOS Version: $(sw_vers -productVersion)"
    echo "  • Architecture: $(uname -m)"
    echo "  • Shell: $SHELL"
    echo "  • User: $USER"
    echo "  • Home: $HOME"
    echo
}

# Main test execution
main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                 HOMEBREW INTEGRATION TEST                   ║
║              Verifying Installation and Setup               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    display_system_info
    
    local tests_passed=0
    local total_tests=7
    
    # Run tests
    if test_homebrew_installation; then
        ((tests_passed++))
    fi
    
    if test_homebrew_functionality; then
        ((tests_passed++))
    fi
    
    if test_shell_integration; then
        ((tests_passed++))
    fi
    
    if test_path_configuration; then
        ((tests_passed++))
    fi
    
    if test_package_installation; then
        ((tests_passed++))
    fi
    
    if test_idempotency; then
        ((tests_passed++))
    fi
    
    if test_environment_variables; then
        ((tests_passed++))
    fi
    
    echo
    info "📊 Test Results: $tests_passed/$total_tests tests passed"
    
    if [[ $tests_passed -eq $total_tests ]]; then
        success "🎉 All tests passed! Homebrew integration is working correctly."
        echo
        info "💡 Homebrew is ready to use:"
        echo "  • Install packages: brew install <package>"
        echo "  • Search packages: brew search <term>"
        echo "  • Update Homebrew: brew update"
        echo "  • Upgrade packages: brew upgrade"
        return 0
    else
        warning "⚠️  Some tests failed. Homebrew may not be fully configured."
        echo
        info "🔧 Troubleshooting:"
        echo "  • Restart your shell: exec \$SHELL"
        echo "  • Check Homebrew installation: which brew"
        echo "  • Run Homebrew doctor: brew doctor"
        echo "  • Check shell config: cat ~/.zprofile | grep brew"
        return 1
    fi
}

# Execute main function
main "$@"
