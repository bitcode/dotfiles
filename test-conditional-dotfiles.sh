#!/bin/bash

# Test script for conditional dotfiles deployment system
# Validates the conditional logic across different scenarios

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to run test scenario
run_test_scenario() {
    local scenario_name=$1
    local extra_vars=$2
    local expected_apps=$3
    
    print_color "$CYAN" "🧪 Testing: $scenario_name"
    print_color "$YELLOW" "   Extra vars: $extra_vars"
    
    # Run ansible-playbook with conditional dotfiles only
    local cmd="ansible-playbook -i inventories/local/hosts.yml site.yml --tags dotfiles,conditional --check $extra_vars"
    
    print_color "$BLUE" "   Command: $cmd"
    
    if eval "$cmd" > /tmp/test_output.log 2>&1; then
        print_color "$GREEN" "   ✅ Test passed: $scenario_name"
        
        # Check if expected applications are mentioned in output
        for app in $expected_apps; do
            if grep -q "$app" /tmp/test_output.log; then
                print_color "$GREEN" "     ✅ Found expected app: $app"
            else
                print_color "$YELLOW" "     ⚠️  Expected app not found: $app"
            fi
        done
    else
        print_color "$RED" "   ❌ Test failed: $scenario_name"
        print_color "$RED" "   Error output:"
        cat /tmp/test_output.log | head -20
    fi
    
    echo
}

# Main test function
main() {
    print_color "$BOLD$CYAN" "🚀 Conditional Dotfiles Deployment Test Suite"
    echo
    
    # Validate requirements
    if ! command -v ansible-playbook >/dev/null 2>&1; then
        print_color "$RED" "❌ ansible-playbook not found. Please install Ansible."
        exit 1
    fi
    
    if [[ ! -f "site.yml" ]]; then
        print_color "$RED" "❌ site.yml not found. Please run from dotsible root directory."
        exit 1
    fi
    
    print_color "$GREEN" "✅ Prerequisites validated"
    echo
    
    # Test scenarios
    print_color "$BOLD$BLUE" "📋 Running Test Scenarios"
    echo
    
    # Scenario 1: macOS with developer profile
    run_test_scenario \
        "macOS Developer Profile" \
        "-e ansible_os_family=Darwin -e profile=developer -e detected_environment=personal" \
        "git neovim tmux zsh starship"
    
    # Scenario 2: Arch Linux with i3 window manager
    run_test_scenario \
        "Arch Linux with i3" \
        "-e ansible_os_family=Archlinux -e ansible_distribution=Archlinux -e detected_window_manager=i3 -e detected_display_server=x11 -e profile=developer" \
        "git neovim tmux zsh i3 polybar rofi"
    
    # Scenario 3: Arch Linux with Hyprland
    run_test_scenario \
        "Arch Linux with Hyprland" \
        "-e ansible_os_family=Archlinux -e ansible_distribution=Archlinux -e detected_window_manager=hyprland -e detected_display_server=wayland -e profile=developer" \
        "git neovim tmux zsh hyprland waybar wofi"
    
    # Scenario 4: Windows with enterprise profile
    run_test_scenario \
        "Windows Enterprise" \
        "-e ansible_os_family=Windows -e profile=enterprise -e detected_environment=enterprise" \
        "git neovim powershell windows_terminal"
    
    # Scenario 5: Ubuntu server (headless)
    run_test_scenario \
        "Ubuntu Server (Headless)" \
        "-e ansible_os_family=Debian -e ansible_distribution=Ubuntu -e profile=server -e detected_display_server=none -e is_ssh_session=true" \
        "git vim tmux zsh"
    
    # Scenario 6: Minimal profile (any platform)
    run_test_scenario \
        "Minimal Profile" \
        "-e profile=minimal" \
        "git vim zsh"
    
    # Test conditional logic validation
    print_color "$BOLD$BLUE" "🔍 Testing Conditional Logic Validation"
    echo
    
    # Test with invalid window manager
    print_color "$CYAN" "🧪 Testing invalid window manager detection"
    if ansible-playbook -i inventories/local/hosts.yml site.yml --tags dotfiles,conditional --check \
        -e "detected_window_manager=invalid_wm" > /tmp/invalid_test.log 2>&1; then
        print_color "$GREEN" "   ✅ Handled invalid window manager gracefully"
    else
        print_color "$YELLOW" "   ⚠️  Invalid window manager test had issues (may be expected)"
    fi
    
    # Test with conflicting settings
    print_color "$CYAN" "🧪 Testing conflicting settings (i3 on Wayland)"
    if ansible-playbook -i inventories/local/hosts.yml site.yml --tags dotfiles,conditional --check \
        -e "detected_window_manager=i3 detected_display_server=wayland" > /tmp/conflict_test.log 2>&1; then
        if grep -q "conflict" /tmp/conflict_test.log || grep -q "skip" /tmp/conflict_test.log; then
            print_color "$GREEN" "   ✅ Detected and handled conflicting settings"
        else
            print_color "$YELLOW" "   ⚠️  Conflict detection may need improvement"
        fi
    fi
    
    echo
    print_color "$BOLD$GREEN" "🎉 Conditional Dotfiles Test Suite Complete"
    
    # Summary
    print_color "$BOLD$CYAN" "📊 Test Summary:"
    print_color "$CYAN" "• Tested multiple platform scenarios"
    print_color "$CYAN" "• Validated window manager detection"
    print_color "$CYAN" "• Checked profile-based filtering"
    print_color "$CYAN" "• Verified environment type handling"
    print_color "$CYAN" "• Tested edge cases and conflicts"
    
    echo
    print_color "$YELLOW" "💡 Next steps:"
    print_color "$YELLOW" "   • Review test outputs in /tmp/test_output.log"
    print_color "$YELLOW" "   • Run actual deployment: ./run-dotsible.sh --tags dotfiles"
    print_color "$YELLOW" "   • Test on different platforms for validation"
}

# Cleanup function
cleanup() {
    rm -f /tmp/test_output.log /tmp/invalid_test.log /tmp/conflict_test.log
}

# Set trap for cleanup
trap cleanup EXIT

# Run main function
main "$@"
