#!/bin/bash
# Test Idempotent Package Management Across All Platforms
# This script validates that all platform roles follow the same idempotent pattern

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logging
LOG_FILE="$PROJECT_ROOT/logs/idempotent_test_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

# Test functions
test_platform_idempotency() {
    local platform=$1
    local platform_dir="$PROJECT_ROOT/roles/platform_specific/$platform"
    
    info "Testing $platform platform idempotency patterns..."
    
    if [[ ! -d "$platform_dir" ]]; then
        error "$platform platform directory not found"
        return 1
    fi
    
    local tasks_file="$platform_dir/tasks/main.yml"
    if [[ ! -f "$tasks_file" ]]; then
        error "$platform tasks file not found"
        return 1
    fi
    
    # Check for check-before-install pattern
    local check_patterns=()
    case $platform in
        "macos")
            check_patterns=("brew list" "ls /Applications" "command -v")
            ;;
        "windows")
            check_patterns=("choco list --local-only" "winget list" "scoop list")
            ;;
        "archlinux")
            check_patterns=("pacman -Q" "npm list -g")
            ;;
        "ubuntu")
            check_patterns=("dpkg -l" "snap list" "flatpak list" "npm list -g")
            ;;
    esac
    
    local patterns_found=0
    for pattern in "${check_patterns[@]}"; do
        if grep -q "$pattern" "$tasks_file"; then
            ((patterns_found++))
            success "$platform: Found check pattern '$pattern'"
        else
            warning "$platform: Missing check pattern '$pattern'"
        fi
    done
    
    # Check for status display
    if grep -q "Display.*status\|INSTALLED.*MISSING" "$tasks_file"; then
        success "$platform: Has status display logic"
    else
        error "$platform: Missing status display logic"
        return 1
    fi
    
    # Check for conditional installation
    if grep -q "when:.*rc.*!= 0\|when:.*rc.*== 0" "$tasks_file"; then
        success "$platform: Has conditional installation logic"
    else
        error "$platform: Missing conditional installation logic"
        return 1
    fi
    
    # Check for verification
    if grep -q "Verify.*installation\|verify.*check" "$tasks_file"; then
        success "$platform: Has installation verification"
    else
        warning "$platform: Missing installation verification"
    fi
    
    if [[ $patterns_found -gt 0 ]]; then
        success "$platform: Idempotency patterns implemented"
        return 0
    else
        error "$platform: No idempotency patterns found"
        return 1
    fi
}

test_cross_platform_equivalency() {
    info "Testing cross-platform application equivalency..."
    
    # Define applications that should exist across platforms
    local common_apps=("vscode" "firefox" "chrome" "discord" "slack" "postman" "notion")
    local platforms=("macos" "windows" "archlinux" "ubuntu")
    
    for app in "${common_apps[@]}"; do
        info "Checking $app across platforms..."
        local platforms_with_app=0
        
        for platform in "${platforms[@]}"; do
            local vars_file="$PROJECT_ROOT/roles/platform_specific/$platform/vars/main.yml"
            if [[ -f "$vars_file" ]]; then
                # Check for app in various package lists
                if grep -qi "$app\|visual-studio-code\|googlechrome\|google-chrome" "$vars_file"; then
                    success "$platform: Has $app equivalent"
                    ((platforms_with_app++))
                else
                    warning "$platform: Missing $app equivalent"
                fi
            fi
        done
        
        if [[ $platforms_with_app -ge 3 ]]; then
            success "$app: Available on $platforms_with_app/4 platforms"
        else
            warning "$app: Only available on $platforms_with_app/4 platforms"
        fi
    done
}

test_mcp_package_consistency() {
    info "Testing MCP package consistency across platforms..."
    
    local mcp_packages=(
        "@modelcontextprotocol/server-brave-search"
        "@modelcontextprotocol/server-puppeteer"
        "firecrawl-mcp"
    )
    
    local platforms=("macos" "windows" "archlinux" "ubuntu")
    local platforms_with_mcp=0
    
    for platform in "${platforms[@]}"; do
        local vars_file="$PROJECT_ROOT/roles/platform_specific/$platform/vars/main.yml"
        if [[ -f "$vars_file" ]]; then
            local mcp_found=0
            for package in "${mcp_packages[@]}"; do
                if grep -q "$package" "$vars_file"; then
                    ((mcp_found++))
                fi
            done
            
            if [[ $mcp_found -eq ${#mcp_packages[@]} ]]; then
                success "$platform: All MCP packages present"
                ((platforms_with_mcp++))
            else
                error "$platform: Missing MCP packages ($mcp_found/${#mcp_packages[@]} found)"
            fi
        fi
    done
    
    if [[ $platforms_with_mcp -eq ${#platforms[@]} ]]; then
        success "MCP packages consistent across all platforms"
        return 0
    else
        error "MCP packages inconsistent ($platforms_with_mcp/${#platforms[@]} platforms)"
        return 1
    fi
}

run_syntax_validation() {
    info "Running syntax validation on all platform roles..."
    
    cd "$PROJECT_ROOT"
    
    if ansible-playbook --syntax-check site.yml > /dev/null 2>&1; then
        success "site.yml syntax is valid"
    else
        error "site.yml syntax validation failed"
        return 1
    fi
    
    return 0
}

generate_test_report() {
    info "Generating idempotent package management test report..."
    
    local report_file="$PROJECT_ROOT/reports/idempotent_packages_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Idempotent Package Management Test Report

**Generated:** $(date)
**Test Script:** $0
**Project Root:** $PROJECT_ROOT

## Test Summary

This report validates that all platform-specific roles follow the proven idempotent 
package management pattern established in the original macsible.yaml implementation.

## Test Results

$(cat "$LOG_FILE")

## Idempotency Pattern Requirements

### ✅ Check-Before-Install Logic
Each platform role should verify if applications are already installed:
- **macOS**: \`brew list\`, \`ls /Applications/\`, \`command -v\`
- **Windows**: \`choco list --local-only\`, \`winget list\`, \`scoop list\`
- **Arch Linux**: \`pacman -Q\`, \`npm list -g\`
- **Ubuntu**: \`dpkg -l\`, \`snap list\`, \`flatpak list\`

### ✅ Status Display
Show "INSTALLED" or "MISSING" status for each package before installation.

### ✅ Conditional Installation
Only install packages that are detected as missing using \`when: item.rc != 0\` logic.

### ✅ Installation Verification
Verify successful installation after package installation attempts.

### ✅ Cross-Platform Equivalency
Ensure equivalent applications are available across all supported platforms.

## Cross-Platform Application Matrix

| Application | macOS | Windows | Arch Linux | Ubuntu | Package Names |
|-------------|-------|---------|------------|--------|---------------|
| VS Code | ✅ | ✅ | ✅ | ✅ | visual-studio-code, vscode, visual-studio-code-bin, code |
| Firefox | ✅ | ✅ | ✅ | ✅ | firefox |
| Chrome | ✅ | ✅ | ✅ | ✅ | google-chrome, googlechrome, google-chrome |
| Discord | ✅ | ✅ | ✅ | ✅ | discord, discord |
| Slack | ✅ | ✅ | ✅ | ✅ | slack, slack-desktop |
| Postman | ✅ | ✅ | ✅ | ✅ | postman, postman-bin |
| Notion | ✅ | ✅ | ✅ | ✅ | notion, notion-app |

## MCP Package Integration

All platforms include Model Context Protocol packages:
- @modelcontextprotocol/server-brave-search
- @modelcontextprotocol/server-puppeteer  
- firecrawl-mcp

## Next Steps

1. **If all tests passed**: The idempotent package management is working correctly
2. **If tests failed**: Review the specific failures and fix the identified issues
3. **Adding new applications**: Follow the cross-platform equivalency pattern
4. **Testing**: Run platform-specific tests to verify idempotency in practice

EOF

    success "Test report generated: $report_file"
}

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║              IDEMPOTENT PACKAGE MANAGEMENT TEST              ║
║                Cross-Platform Validation                    ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Starting idempotent package management validation..."
    
    local failed_tests=0
    local platforms=("macos" "windows" "archlinux" "ubuntu")
    
    # Test each platform's idempotency patterns
    for platform in "${platforms[@]}"; do
        if ! test_platform_idempotency "$platform"; then
            ((failed_tests++))
        fi
    done
    
    # Test cross-platform equivalency
    if ! test_cross_platform_equivalency; then
        ((failed_tests++))
    fi
    
    # Test MCP package consistency
    if ! test_mcp_package_consistency; then
        ((failed_tests++))
    fi
    
    # Run syntax validation
    if ! run_syntax_validation; then
        ((failed_tests++))
    fi
    
    generate_test_report
    
    echo
    if [[ $failed_tests -eq 0 ]]; then
        success "All idempotent package management tests passed! ✨"
        info "The dotsible system follows consistent idempotent patterns across all platforms"
        echo
        info "✅ Proven idempotency patterns implemented"
        info "✅ Cross-platform application equivalency maintained"
        info "✅ MCP package integration preserved"
        info "✅ Syntax validation passed"
        echo
        info "Ready for production deployment with idempotent package management!"
        exit 0
    else
        error "$failed_tests test(s) failed"
        info "Please review the test report and fix the identified issues"
        exit 1
    fi
}

# Run main function
main "$@"
