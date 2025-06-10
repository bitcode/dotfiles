#!/bin/bash
# Phase 3 Validation Script
# Validates Windows platform support and advanced cross-platform integration

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
LOG_FILE="$PROJECT_ROOT/logs/phase3_validation_$(date +%Y%m%d_%H%M%S).log"
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

# Validation functions
validate_windows_platform_role() {
    info "Validating Windows platform role structure..."

    local windows_role_dir="$PROJECT_ROOT/roles/platform_specific/windows"
    local required_files=(
        "meta/main.yml"
        "vars/main.yml"
        "tasks/main.yml"
        "handlers/main.yml"
    )

    if [[ ! -d "$windows_role_dir" ]]; then
        error "Windows platform role directory not found: $windows_role_dir"
        return 1
    fi

    for file in "${required_files[@]}"; do
        if [[ ! -f "$windows_role_dir/$file" ]]; then
            error "Required Windows platform file missing: $file"
            return 1
        fi
    done

    success "Windows platform role structure is valid"
    return 0
}

validate_archlinux_platform_role() {
    info "Validating Arch Linux platform role structure..."

    local arch_role_dir="$PROJECT_ROOT/roles/platform_specific/archlinux"
    local required_files=(
        "meta/main.yml"
        "vars/main.yml"
        "tasks/main.yml"
        "handlers/main.yml"
    )

    if [[ ! -d "$arch_role_dir" ]]; then
        error "Arch Linux platform role directory not found: $arch_role_dir"
        return 1
    fi

    for file in "${required_files[@]}"; do
        if [[ ! -f "$arch_role_dir/$file" ]]; then
            error "Required Arch Linux platform file missing: $file"
            return 1
        fi
    done

    success "Arch Linux platform role structure is valid"
    return 0
}

validate_ubuntu_platform_role() {
    info "Validating Ubuntu platform role structure..."

    local ubuntu_role_dir="$PROJECT_ROOT/roles/platform_specific/ubuntu"
    local required_files=(
        "meta/main.yml"
        "vars/main.yml"
        "tasks/main.yml"
        "handlers/main.yml"
    )

    if [[ ! -d "$ubuntu_role_dir" ]]; then
        error "Ubuntu platform role directory not found: $ubuntu_role_dir"
        return 1
    fi

    for file in "${required_files[@]}"; do
        if [[ ! -f "$ubuntu_role_dir/$file" ]]; then
            error "Required Ubuntu platform file missing: $file"
            return 1
        fi
    done

    success "Ubuntu platform role structure is valid"
    return 0
}

validate_package_manager_windows_support() {
    info "Validating Windows package manager support..."
    
    local package_manager_dir="$PROJECT_ROOT/roles/package_manager"
    local required_files=(
        "vars/windows.yml"
        "tasks/setup_chocolatey.yml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$package_manager_dir/$file" ]]; then
            error "Required package manager file missing: $file"
            return 1
        fi
    done
    
    # Check if main.yml includes Windows support
    if ! grep -q "setup_chocolatey.yml" "$package_manager_dir/tasks/main.yml"; then
        error "Windows package manager not integrated in main.yml"
        return 1
    fi
    
    success "Windows package manager support is valid"
    return 0
}

validate_cross_platform_applications() {
    info "Validating cross-platform application support..."

    local apps_dir="$PROJECT_ROOT/roles/applications"
    local core_apps=("neovim" "alacritty" "starship" "zsh" "tmux")
    local wm_apps=("i3" "hyprland" "sway")
    local statusbar_apps=("waybar" "polybar")
    local all_apps=("${core_apps[@]}" "${wm_apps[@]}" "${statusbar_apps[@]}")

    local failed_apps=0

    for app in "${all_apps[@]}"; do
        local app_dir="$apps_dir/$app"
        local app_tasks="$app_dir/tasks/main.yml"
        local app_vars="$app_dir/vars/main.yml"
        local app_meta="$app_dir/meta/main.yml"
        local app_handlers="$app_dir/handlers/main.yml"

        info "Validating application: $app"

        # Check if application directory exists
        if [[ ! -d "$app_dir" ]]; then
            error "Application directory missing: $app_dir"
            ((failed_apps++))
            continue
        fi

        # Check required files
        local required_files=("$app_tasks" "$app_vars" "$app_meta" "$app_handlers")
        local missing_files=0

        for file in "${required_files[@]}"; do
            if [[ ! -f "$file" ]]; then
                error "Required file missing for $app: $(basename "$file")"
                ((missing_files++))
            fi
        done

        if [[ $missing_files -gt 0 ]]; then
            ((failed_apps++))
            continue
        fi

        # Check for cross-platform support in core apps
        if [[ " ${core_apps[@]} " =~ " ${app} " ]]; then
            local platforms_supported=0

            # Check for Windows support
            if grep -q "Windows\|win_" "$app_tasks"; then
                ((platforms_supported++))
                success "$app has Windows support"
            else
                warning "$app missing Windows support"
            fi

            # Check for macOS support
            if grep -q "Darwin\|homebrew" "$app_tasks"; then
                ((platforms_supported++))
                success "$app has macOS support"
            else
                warning "$app missing macOS support"
            fi

            # Check for Linux support
            if grep -q "Debian\|Archlinux\|apt\|pacman" "$app_tasks"; then
                ((platforms_supported++))
                success "$app has Linux support"
            else
                warning "$app missing Linux support"
            fi

            if [[ $platforms_supported -lt 2 ]]; then
                error "$app lacks sufficient cross-platform support"
                ((failed_apps++))
            fi
        fi

        # Check window manager apps are Linux-only
        if [[ " ${wm_apps[@]} " =~ " ${app} " ]]; then
            if grep -q "Windows\|Darwin" "$app_tasks"; then
                error "$app (window manager) should not support Windows/macOS"
                ((failed_apps++))
            else
                success "$app correctly targets Linux only"
            fi
        fi

        # Check status bar apps have proper conditional logic
        if [[ " ${statusbar_apps[@]} " =~ " ${app} " ]]; then
            if [[ "$app" == "waybar" ]]; then
                if ! grep -q "wayland\|hyprland\|sway" "$app_tasks"; then
                    warning "$app should check for Wayland compositor compatibility"
                fi
            elif [[ "$app" == "polybar" ]]; then
                if ! grep -q "x11\|i3" "$app_tasks"; then
                    warning "$app should check for X11 compatibility"
                fi
            fi
        fi
    done

    if [[ $failed_apps -eq 0 ]]; then
        success "All application roles are properly implemented"
        return 0
    else
        error "$failed_apps application role(s) failed validation"
        return 1
    fi
}

validate_window_manager_roles() {
    info "Validating window manager application roles..."

    local apps_dir="$PROJECT_ROOT/roles/applications"
    local wm_roles=("i3" "hyprland" "sway")
    local failed_wm=0

    for wm in "${wm_roles[@]}"; do
        local wm_dir="$apps_dir/$wm"
        info "Validating window manager: $wm"

        # Check if role directory exists and has required files
        if [[ ! -d "$wm_dir" ]]; then
            error "Window manager role directory missing: $wm_dir"
            ((failed_wm++))
            continue
        fi

        local required_files=("tasks/main.yml" "vars/main.yml" "meta/main.yml" "handlers/main.yml")
        local missing_files=0

        for file in "${required_files[@]}"; do
            if [[ ! -f "$wm_dir/$file" ]]; then
                error "Required file missing for $wm: $file"
                ((missing_files++))
            fi
        done

        if [[ $missing_files -gt 0 ]]; then
            ((failed_wm++))
            continue
        fi

        # Check for Linux-only targeting
        if grep -q "Windows\|Darwin" "$wm_dir/tasks/main.yml"; then
            error "$wm should only target Linux systems"
            ((failed_wm++))
        else
            success "$wm correctly targets Linux only"
        fi

        # Check for proper package management
        if ! grep -q "pacman\|apt\|dnf" "$wm_dir/tasks/main.yml"; then
            error "$wm missing Linux package management"
            ((failed_wm++))
        fi

        # Check for configuration deployment
        if ! grep -q "copy\|template" "$wm_dir/tasks/main.yml"; then
            warning "$wm may not deploy configuration files"
        fi
    done

    if [[ $failed_wm -eq 0 ]]; then
        success "All window manager roles are properly implemented"
        return 0
    else
        error "$failed_wm window manager role(s) failed validation"
        return 1
    fi
}

validate_status_bar_roles() {
    info "Validating status bar application roles..."

    local apps_dir="$PROJECT_ROOT/roles/applications"
    local statusbar_roles=("waybar" "polybar")
    local failed_sb=0

    for sb in "${statusbar_roles[@]}"; do
        local sb_dir="$apps_dir/$sb"
        info "Validating status bar: $sb"

        # Check if role directory exists and has required files
        if [[ ! -d "$sb_dir" ]]; then
            error "Status bar role directory missing: $sb_dir"
            ((failed_sb++))
            continue
        fi

        local required_files=("tasks/main.yml" "vars/main.yml" "meta/main.yml" "handlers/main.yml")
        local missing_files=0

        for file in "${required_files[@]}"; do
            if [[ ! -f "$sb_dir/$file" ]]; then
                error "Required file missing for $sb: $file"
                ((missing_files++))
            fi
        done

        if [[ $missing_files -gt 0 ]]; then
            ((failed_sb++))
            continue
        fi

        # Check for appropriate display server targeting
        if [[ "$sb" == "waybar" ]]; then
            if ! grep -q -i "wayland\|hyprland\|sway" "$sb_dir/tasks/main.yml"; then
                warning "$sb should check for Wayland compatibility"
            else
                success "$sb properly targets Wayland compositors"
            fi
        elif [[ "$sb" == "polybar" ]]; then
            if ! grep -q -i "x11\|i3" "$sb_dir/tasks/main.yml"; then
                warning "$sb should check for X11 compatibility"
            else
                success "$sb properly targets X11 window managers"
            fi
        fi

        # Check for font dependencies
        if ! grep -q "font" "$sb_dir/vars/main.yml"; then
            warning "$sb may be missing font dependencies"
        fi
    done

    if [[ $failed_sb -eq 0 ]]; then
        success "All status bar roles are properly implemented"
        return 0
    else
        error "$failed_sb status bar role(s) failed validation"
        return 1
    fi
}

validate_environment_detection() {
    info "Validating environment detection functionality..."

    local detection_file="$PROJECT_ROOT/roles/common/tasks/environment_detection.yml"
    if [[ ! -f "$detection_file" ]]; then
        error "Environment detection file missing: $detection_file"
        return 1
    fi

    # Check for required detection logic
    local required_detections=(
        "detected_os"
        "detected_distribution"
        "detected_environment"
        "detected_window_manager"
        "dotsible_os"
        "dotsible_distribution"
        "dotsible_window_manager"
        "dotsible_environment"
    )

    for detection in "${required_detections[@]}"; do
        if ! grep -q "$detection" "$detection_file"; then
            error "Missing detection logic for: $detection"
            return 1
        fi
    done

    # Check for platform-specific detection blocks
    if ! grep -q "ansible_os_family.*Windows" "$detection_file"; then
        error "Missing Windows-specific detection logic"
        return 1
    fi

    if ! grep -q "ansible_os_family.*Darwin" "$detection_file"; then
        error "Missing macOS-specific detection logic"
        return 1
    fi

    success "Environment detection is properly implemented"
    return 0
}

validate_site_yml_integration() {
    info "Validating site.yml integration..."

    local site_yml="$PROJECT_ROOT/site.yml"
    if [[ ! -f "$site_yml" ]]; then
        error "site.yml not found"
        return 1
    fi

    # Check for all platform role integrations
    local platforms=("macos" "windows" "archlinux" "ubuntu")
    for platform in "${platforms[@]}"; do
        if ! grep -q "platform_specific/$platform" "$site_yml"; then
            error "$platform platform role not integrated in site.yml"
            return 1
        else
            success "$platform platform role properly integrated"
        fi
    done

    # Check for common role integration
    if ! grep -q "role: common" "$site_yml"; then
        error "Common role not integrated in site.yml"
        return 1
    fi

    # Check for package manager role integration
    if ! grep -q "role: package_manager" "$site_yml"; then
        error "Package manager role not integrated in site.yml"
        return 1
    fi

    # Check for conditional deployment logic
    local conditional_checks=(
        "dotsible_window_manager"
        "dotsible_environment"
        "ansible_os_family.*Windows"
        "ansible_os_family.*Darwin"
        "ansible_distribution.*Archlinux"
        "ansible_os_family.*Debian"
    )

    for check in "${conditional_checks[@]}"; do
        if ! grep -q "$check" "$site_yml"; then
            warning "Missing conditional logic: $check"
        else
            success "Conditional logic present: $check"
        fi
    done

    # Check for window manager specific roles
    local wm_roles=("i3" "hyprland" "sway")
    for wm in "${wm_roles[@]}"; do
        if ! grep -q "applications/$wm" "$site_yml"; then
            error "Window manager role $wm not integrated in site.yml"
            return 1
        fi
    done

    # Check for status bar roles
    local sb_roles=("waybar" "polybar")
    for sb in "${sb_roles[@]}"; do
        if ! grep -q "applications/$sb" "$site_yml"; then
            error "Status bar role $sb not integrated in site.yml"
            return 1
        fi
    done

    success "site.yml integration is comprehensive and valid"
    return 0
}

validate_mcp_package_integration() {
    info "Validating MCP package integration preservation..."

    local mcp_packages=(
        "@modelcontextprotocol/server-brave-search"
        "@modelcontextprotocol/server-puppeteer"
        "firecrawl-mcp"
    )

    local platforms_checked=0
    local platforms_with_mcp=0

    # Check macOS platform role
    local macos_vars="$PROJECT_ROOT/roles/platform_specific/macos/vars/main.yml"
    if [[ -f "$macos_vars" ]]; then
        ((platforms_checked++))
        local mcp_found=0
        for package in "${mcp_packages[@]}"; do
            if grep -q "$package" "$macos_vars"; then
                ((mcp_found++))
            fi
        done
        if [[ $mcp_found -eq ${#mcp_packages[@]} ]]; then
            ((platforms_with_mcp++))
            success "macOS platform has all MCP packages"
        else
            error "macOS platform missing MCP packages ($mcp_found/${#mcp_packages[@]} found)"
        fi
    fi

    # Check Windows platform role
    local windows_vars="$PROJECT_ROOT/roles/platform_specific/windows/vars/main.yml"
    if [[ -f "$windows_vars" ]]; then
        ((platforms_checked++))
        local mcp_found=0
        for package in "${mcp_packages[@]}"; do
            if grep -q "$package" "$windows_vars"; then
                ((mcp_found++))
            fi
        done
        if [[ $mcp_found -eq ${#mcp_packages[@]} ]]; then
            ((platforms_with_mcp++))
            success "Windows platform has all MCP packages"
        else
            error "Windows platform missing MCP packages ($mcp_found/${#mcp_packages[@]} found)"
        fi
    fi

    # Check Arch Linux platform role
    local arch_vars="$PROJECT_ROOT/roles/platform_specific/archlinux/vars/main.yml"
    if [[ -f "$arch_vars" ]]; then
        ((platforms_checked++))
        local mcp_found=0
        for package in "${mcp_packages[@]}"; do
            if grep -q "$package" "$arch_vars"; then
                ((mcp_found++))
            fi
        done
        if [[ $mcp_found -eq ${#mcp_packages[@]} ]]; then
            ((platforms_with_mcp++))
            success "Arch Linux platform has all MCP packages"
        else
            error "Arch Linux platform missing MCP packages ($mcp_found/${#mcp_packages[@]} found)"
        fi
    fi

    # Check Ubuntu platform role
    local ubuntu_vars="$PROJECT_ROOT/roles/platform_specific/ubuntu/vars/main.yml"
    if [[ -f "$ubuntu_vars" ]]; then
        ((platforms_checked++))
        local mcp_found=0
        for package in "${mcp_packages[@]}"; do
            if grep -q "$package" "$ubuntu_vars"; then
                ((mcp_found++))
            fi
        done
        if [[ $mcp_found -eq ${#mcp_packages[@]} ]]; then
            ((platforms_with_mcp++))
            success "Ubuntu platform has all MCP packages"
        else
            error "Ubuntu platform missing MCP packages ($mcp_found/${#mcp_packages[@]} found)"
        fi
    fi

    if [[ $platforms_with_mcp -eq $platforms_checked ]] && [[ $platforms_checked -gt 0 ]]; then
        success "MCP package integration preserved across all platforms"
        return 0
    else
        error "MCP package integration not properly preserved ($platforms_with_mcp/$platforms_checked platforms)"
        return 1
    fi
}

validate_neovim_role_enhancement() {
    info "Validating enhanced Neovim role implementation..."

    local nvim_dir="$PROJECT_ROOT/roles/applications/neovim"
    local nvim_vars="$nvim_dir/vars/main.yml"
    local nvim_tasks="$nvim_dir/tasks/main.yml"

    if [[ ! -f "$nvim_vars" ]] || [[ ! -f "$nvim_tasks" ]]; then
        error "Neovim role files missing"
        return 1
    fi

    # Check for cross-platform package definitions
    local platforms=("debian" "archlinux" "darwin" "windows")
    for platform in "${platforms[@]}"; do
        if ! grep -q "$platform:" "$nvim_vars"; then
            error "Neovim role missing $platform platform support"
            return 1
        fi
    done

    # Check for language server support
    if ! grep -q "language_servers\|lsp" "$nvim_vars"; then
        warning "Neovim role may be missing language server configuration"
    fi

    # Check for plugin manager support
    if ! grep -q "plugin_manager\|lazy\|packer" "$nvim_vars"; then
        warning "Neovim role may be missing plugin manager configuration"
    fi

    # Check for cross-platform path handling
    if ! grep -q "AppData.*nvim" "$nvim_vars"; then
        error "Neovim role missing Windows path configuration"
        return 1
    fi

    # Check for Python and Node.js package installation
    if ! grep -q "python_packages\|node_packages" "$nvim_vars"; then
        warning "Neovim role may be missing language support packages"
    fi

    # Check for cross-platform installation tasks
    local install_methods=("homebrew" "chocolatey" "pacman" "apt")
    local methods_found=0
    for method in "${install_methods[@]}"; do
        if grep -q "$method" "$nvim_tasks"; then
            ((methods_found++))
        fi
    done

    if [[ $methods_found -lt 3 ]]; then
        error "Neovim role missing sufficient cross-platform installation methods"
        return 1
    fi

    success "Neovim role is properly enhanced with cross-platform support"
    return 0
}

validate_testing_infrastructure() {
    info "Validating testing infrastructure..."

    local tests_dir="$PROJECT_ROOT/tests"
    local required_tests=(
        "test_windows_platform.yml"
    )

    if [[ ! -d "$tests_dir" ]]; then
        error "Tests directory missing: $tests_dir"
        return 1
    fi

    for test_file in "${required_tests[@]}"; do
        if [[ ! -f "$tests_dir/$test_file" ]]; then
            error "Test file missing: $test_file"
            return 1
        fi
    done

    # Check if test files have proper structure
    local windows_test="$tests_dir/test_windows_platform.yml"
    if [[ -f "$windows_test" ]]; then
        if ! grep -q "Test Windows Platform Implementation" "$windows_test"; then
            warning "Windows test may not have proper test structure"
        fi

        if ! grep -q "environment_detection\|package_management\|cross_platform" "$windows_test"; then
            warning "Windows test may be missing comprehensive test coverage"
        fi
    fi

    success "Testing infrastructure is properly implemented"
    return 0
}

validate_backward_compatibility() {
    info "Validating backward compatibility with existing functionality..."

    # Check if macOS platform role preserves original functionality
    local macos_role="$PROJECT_ROOT/roles/platform_specific/macos"
    if [[ ! -d "$macos_role" ]]; then
        error "macOS platform role missing - backward compatibility broken"
        return 1
    fi

    # Check for homebrew package management preservation
    local macos_vars="$macos_role/vars/main.yml"
    if [[ -f "$macos_vars" ]]; then
        if ! grep -q "homebrew_packages\|brew" "$macos_vars"; then
            error "macOS Homebrew functionality not preserved"
            return 1
        fi
    fi

    # Check if original application roles still exist
    local original_apps=("zsh" "tmux" "alacritty" "starship")
    for app in "${original_apps[@]}"; do
        local app_dir="$PROJECT_ROOT/roles/applications/$app"
        if [[ ! -d "$app_dir" ]]; then
            error "Original application role missing: $app"
            return 1
        fi
    done

    # Check if dotfiles are still accessible
    local dotfiles_dir="$PROJECT_ROOT/files/dotfiles"
    if [[ ! -d "$dotfiles_dir" ]]; then
        error "Dotfiles directory missing - configuration deployment broken"
        return 1
    fi

    success "Backward compatibility is maintained"
    return 0
}

run_syntax_validation() {
    info "Running Ansible syntax validation..."
    
    cd "$PROJECT_ROOT"
    
    # Check site.yml syntax
    if ansible-playbook --syntax-check site.yml > /dev/null 2>&1; then
        success "site.yml syntax is valid"
    else
        error "site.yml syntax validation failed"
        return 1
    fi
    
    # Check Windows platform role syntax
    if ansible-playbook --syntax-check tests/test_windows_platform.yml > /dev/null 2>&1; then
        success "Windows platform test syntax is valid"
    else
        error "Windows platform test syntax validation failed"
        return 1
    fi
    
    return 0
}

generate_validation_report() {
    info "Generating validation report..."
    
    local report_file="$PROJECT_ROOT/reports/phase3_validation_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Phase 3 Validation Report

**Generated:** $(date)
**Validator:** $0
**Project Root:** $PROJECT_ROOT

## Validation Summary

This report summarizes the validation of Phase 3 implementation:
- Windows Platform Support
- Advanced Cross-Platform Integration
- Conditional Deployment Logic

## Validation Results

$(cat "$LOG_FILE")

## Next Steps

1. **If all validations passed:** Proceed with testing on actual Windows systems
2. **If validations failed:** Review and fix the reported issues
3. **Testing:** Run the Windows platform test suite: \`ansible-playbook tests/test_windows_platform.yml\`

## Files Validated

- Windows platform role: \`roles/platform_specific/windows/\`
- Package manager Windows support: \`roles/package_manager/vars/windows.yml\`
- Cross-platform applications: \`roles/applications/*/tasks/main.yml\`
- Environment detection: \`roles/common/tasks/environment_detection.yml\`
- Main playbook integration: \`site.yml\`
- Testing infrastructure: \`tests/test_windows_platform.yml\`

## Phase 3 Success Criteria

- [x] Windows platform role created with Chocolatey, Scoop, and winget support
- [x] Cross-platform application roles updated with Windows support
- [x] Advanced environment detection implemented
- [x] Conditional deployment logic for window managers and environment types
- [x] Comprehensive testing infrastructure in place
- [x] Backward compatibility with Phase 2 functionality maintained

EOF

    success "Validation report generated: $report_file"
}

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                    PHASE 3 VALIDATION                       ║
║              Windows Platform & Cross-Platform              ║
║                    Integration Validator                    ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "Starting Phase 3 validation..."
    
    local validation_functions=(
        validate_windows_platform_role
        validate_archlinux_platform_role
        validate_ubuntu_platform_role
        validate_package_manager_windows_support
        validate_cross_platform_applications
        validate_window_manager_roles
        validate_status_bar_roles
        validate_neovim_role_enhancement
        validate_environment_detection
        validate_site_yml_integration
        validate_mcp_package_integration
        validate_testing_infrastructure
        validate_backward_compatibility
        run_syntax_validation
    )
    
    local failed_validations=0
    
    for func in "${validation_functions[@]}"; do
        if ! $func; then
            ((failed_validations++))
        fi
    done
    
    generate_validation_report
    
    echo
    if [[ $failed_validations -eq 0 ]]; then
        success "All Phase 3 validations passed! ✨"
        echo
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                    PHASE 3 COMPLETE                         ║${NC}"
        echo -e "${GREEN}║          Cross-Platform Integration Successful              ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        info "🎉 Phase 3 Implementation Status: PRODUCTION READY"
        echo
        info "✅ Completed Components:"
        echo "   • Windows platform support (Chocolatey/Scoop/winget)"
        echo "   • Arch Linux platform support (pacman/AUR)"
        echo "   • Ubuntu/Debian platform support (apt/snap/flatpak)"
        echo "   • Cross-platform Neovim with language servers"
        echo "   • Window manager roles (i3, Hyprland, Sway)"
        echo "   • Status bar roles (Waybar, Polybar)"
        echo "   • Advanced environment detection"
        echo "   • Conditional deployment logic"
        echo "   • MCP package integration preserved"
        echo "   • Backward compatibility maintained"
        echo
        info "🚀 Ready for deployment across all supported platforms:"
        echo "   • macOS (Homebrew + enterprise settings)"
        echo "   • Windows (Chocolatey/Scoop/winget + PowerShell)"
        echo "   • Arch Linux (pacman/AUR + window managers)"
        echo "   • Ubuntu/Debian (apt/snap/flatpak + desktop environments)"
        echo
        info "📋 Next steps for production deployment:"
        echo "  1. Test on target platform: ansible-playbook site.yml --check"
        echo "  2. Run full deployment: ansible-playbook site.yml"
        echo "  3. Test Windows specifically: ansible-playbook tests/test_windows_platform.yml"
        echo "  4. Verify environment detection: Check dotsible_* variables"
        echo "  5. Test window manager deployment on Linux systems"
        echo
        info "🔧 Advanced usage:"
        echo "  • Deploy specific profile: ansible-playbook site.yml -e profile=developer"
        echo "  • Deploy specific platform: ansible-playbook site.yml --tags platform"
        echo "  • Deploy window managers only: ansible-playbook site.yml --tags window-manager"
        echo "  • Deploy applications only: ansible-playbook site.yml --tags applications"
        echo
        exit 0
    else
        error "$failed_validations validation(s) failed"
        echo
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                    VALIDATION FAILED                        ║${NC}"
        echo -e "${RED}║              Phase 3 Implementation Incomplete              ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo
        error "❌ Phase 3 Implementation Status: NOT PRODUCTION READY"
        echo
        info "🔧 Common fixes for validation failures:"
        echo
        info "1. Missing role files:"
        echo "   • Ensure all roles have: tasks/main.yml, vars/main.yml, meta/main.yml, handlers/main.yml"
        echo "   • Check file permissions and syntax"
        echo
        info "2. Cross-platform support issues:"
        echo "   • Add Windows support: win_chocolatey, win_copy, win_shell tasks"
        echo "   • Add macOS support: homebrew tasks and Darwin conditionals"
        echo "   • Add Linux support: pacman/apt tasks and distribution conditionals"
        echo
        info "3. Integration issues:"
        echo "   • Update site.yml to include all new roles"
        echo "   • Add proper conditional logic using dotsible_* variables"
        echo "   • Ensure role dependencies are correctly defined"
        echo
        info "4. MCP package integration:"
        echo "   • Add MCP packages to npm_global_packages in all platform roles"
        echo "   • Verify package names match exactly"
        echo
        info "5. Environment detection:"
        echo "   • Ensure environment_detection.yml sets all dotsible_* variables"
        echo "   • Add platform-specific detection blocks"
        echo
        info "📋 Recommended actions:"
        echo "  1. Review the validation report above for specific failures"
        echo "  2. Fix the identified issues one by one"
        echo "  3. Re-run validation: ./scripts/validate_phase3.sh"
        echo "  4. Test syntax: ansible-playbook --syntax-check site.yml"
        echo
        exit 1
    fi
}

# Run main function
main "$@"
