#!/bin/bash
# Test script to verify FZF installation and shell integration

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

# Test FZF installation
test_fzf_installation() {
    info "🔍 Testing FZF installation..."
    
    if command -v fzf >/dev/null 2>&1; then
        local fzf_version
        fzf_version=$(fzf --version | head -1)
        success "✅ FZF is installed: $fzf_version"
        return 0
    else
        error "❌ FZF is not installed or not in PATH"
        return 1
    fi
}

# Test shell integration
test_shell_integration() {
    info "🐚 Testing shell integration..."
    
    local shell_name
    shell_name=$(basename "$SHELL")
    local config_file="$HOME/.${shell_name}rc"
    
    info "Shell: $shell_name"
    info "Config file: $config_file"
    
    if [[ ! -f "$config_file" ]]; then
        warning "⚠️  Shell config file not found: $config_file"
        return 1
    fi
    
    # Check for modern FZF integration
    if grep -q "fzf --zsh\|fzf --bash" "$config_file" 2>/dev/null; then
        success "✅ Modern FZF shell integration found"
        return 0
    elif grep -q "source.*fzf" "$config_file" 2>/dev/null; then
        warning "⚠️  Legacy FZF integration found (consider updating)"
        return 0
    else
        error "❌ No FZF shell integration found"
        return 1
    fi
}

# Test FZF functionality
test_fzf_functionality() {
    info "⚡ Testing FZF functionality..."
    
    # Test basic FZF functionality with a simple input
    if echo -e "test1\ntest2\ntest3" | fzf --filter="test2" | grep -q "test2"; then
        success "✅ FZF filtering works correctly"
    else
        error "❌ FZF filtering failed"
        return 1
    fi
    
    # Test FZF key bindings (if available)
    if command -v fzf >/dev/null 2>&1; then
        if fzf --help | grep -q "bash\|zsh"; then
            success "✅ FZF shell integration commands available"
        else
            warning "⚠️  FZF shell integration commands not available (older version)"
        fi
    fi
    
    return 0
}

# Test environment variables
test_environment_variables() {
    info "🌍 Testing FZF environment variables..."
    
    local env_vars=(
        "FZF_DEFAULT_OPTS"
        "FZF_DEFAULT_COMMAND"
        "FZF_CTRL_T_COMMAND"
        "FZF_ALT_C_COMMAND"
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
        success "✅ $configured_vars FZF environment variables configured"
    else
        warning "⚠️  No FZF environment variables configured"
    fi
    
    return 0
}

# Test optional dependencies
test_optional_dependencies() {
    info "🔧 Testing optional FZF dependencies..."
    
    local deps=(
        "rg:ripgrep"
        "fd:fd-find"
        "bat:bat"
        "git:git"
    )
    
    local available_deps=0
    
    for dep in "${deps[@]}"; do
        local cmd="${dep%:*}"
        local name="${dep#*:}"
        
        if command -v "$cmd" >/dev/null 2>&1; then
            success "✅ $name: Available"
            ((available_deps++))
        else
            info "ℹ️  $name: Not available (optional)"
        fi
    done
    
    info "📊 $available_deps/4 optional dependencies available"
    return 0
}

# Main test execution
main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                    FZF INTEGRATION TEST                     ║
║              Verifying Installation and Setup               ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    local tests_passed=0
    local total_tests=5
    
    # Run tests
    if test_fzf_installation; then
        ((tests_passed++))
    fi
    
    if test_shell_integration; then
        ((tests_passed++))
    fi
    
    if test_fzf_functionality; then
        ((tests_passed++))
    fi
    
    if test_environment_variables; then
        ((tests_passed++))
    fi
    
    if test_optional_dependencies; then
        ((tests_passed++))
    fi
    
    echo
    info "📊 Test Results: $tests_passed/$total_tests tests passed"
    
    if [[ $tests_passed -eq $total_tests ]]; then
        success "🎉 All tests passed! FZF integration is working correctly."
        echo
        info "💡 Try these FZF commands:"
        echo "  • Ctrl+T - File search"
        echo "  • Ctrl+R - History search"
        echo "  • Alt+C - Directory search"
        echo "  • fzf --help - Show help"
        return 0
    else
        warning "⚠️  Some tests failed. FZF may not be fully configured."
        echo
        info "🔧 Troubleshooting:"
        echo "  • Restart your shell: exec \$SHELL"
        echo "  • Check FZF installation: which fzf"
        echo "  • Verify shell config: cat ~/.zshrc | grep fzf"
        return 1
    fi
}

# Execute main function
main "$@"
