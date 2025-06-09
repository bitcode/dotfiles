#!/bin/bash

# Dotsible Enhanced Execution Script
# Comprehensive cross-platform environment setup with full ecosystem integration
# Integrates bootstrap infrastructure, platform detection, conditional deployment,
# dotfiles management, and clean output formatting

set -euo pipefail

# Script directory for relative path resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default values
VERBOSE=false
DRY_RUN=false
PROFILE=""
ENVIRONMENT_TYPE=""
INVENTORY="inventories/local/hosts.yml"
TAGS=""
EXTRA_VARS=""
INTERACTIVE_MODE=false
NEED_SUDO=false
ASK_BECOME_PASS=""
BOOTSTRAP_REQUIRED=false
SKIP_BOOTSTRAP=false
WINDOW_MANAGER=""
DETECTED_PLATFORM=""
DETECTED_ENVIRONMENT=""
FORCE_BOOTSTRAP=false

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to detect platform and environment
detect_platform_environment() {
    print_color "$CYAN" "🔍 Detecting platform and environment..."

    # Detect OS and distribution
    case "$(uname -s)" in
        Darwin)
            DETECTED_PLATFORM="macos"
            ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then
                DETECTED_PLATFORM="archlinux"
            elif [[ -f /etc/lsb-release ]] && grep -q "Ubuntu" /etc/lsb-release; then
                DETECTED_PLATFORM="ubuntu"
            elif [[ -f /etc/debian_version ]]; then
                DETECTED_PLATFORM="ubuntu"
            else
                DETECTED_PLATFORM="linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            DETECTED_PLATFORM="windows"
            ;;
        *)
            DETECTED_PLATFORM="unknown"
            ;;
    esac

    # Detect window manager (Linux only)
    if [[ "$DETECTED_PLATFORM" == "archlinux" || "$DETECTED_PLATFORM" == "ubuntu" ]]; then
        if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
            case "${XDG_CURRENT_DESKTOP,,}" in
                *i3*) WINDOW_MANAGER="i3" ;;
                *hypr*) WINDOW_MANAGER="hyprland" ;;
                *sway*) WINDOW_MANAGER="sway" ;;
                *gnome*) WINDOW_MANAGER="gnome" ;;
                *kde*) WINDOW_MANAGER="kde" ;;
                *) WINDOW_MANAGER="unknown" ;;
            esac
        elif [[ -n "${DESKTOP_SESSION:-}" ]]; then
            case "${DESKTOP_SESSION,,}" in
                *i3*) WINDOW_MANAGER="i3" ;;
                *hypr*) WINDOW_MANAGER="hyprland" ;;
                *sway*) WINDOW_MANAGER="sway" ;;
                *) WINDOW_MANAGER="unknown" ;;
            esac
        else
            WINDOW_MANAGER="none"
        fi
    fi

    # Detect environment type (enterprise vs personal)
    DETECTED_ENVIRONMENT="personal"  # Default

    # Check for enterprise indicators
    if command -v realm >/dev/null 2>&1 && realm list 2>/dev/null | grep -q "domain-name"; then
        DETECTED_ENVIRONMENT="enterprise"
    elif [[ "$DETECTED_PLATFORM" == "macos" ]] && profiles status 2>/dev/null | grep -q "enrolled"; then
        DETECTED_ENVIRONMENT="enterprise"
    elif [[ -d "/Applications/Microsoft Teams.app" ]] || [[ -d "/Applications/Slack.app" ]]; then
        # Check for common enterprise software
        local enterprise_score=0
        [[ -d "/Applications/Microsoft Teams.app" ]] && ((enterprise_score++))
        [[ -d "/Applications/Slack.app" ]] && ((enterprise_score++))
        [[ -d "/Applications/Zoom.app" ]] && ((enterprise_score++))
        command -v code >/dev/null 2>&1 && ((enterprise_score++))

        [[ $enterprise_score -ge 2 ]] && DETECTED_ENVIRONMENT="enterprise"
    fi

    print_color "$GREEN" "✅ Platform: $DETECTED_PLATFORM"
    [[ -n "$WINDOW_MANAGER" ]] && print_color "$GREEN" "✅ Window Manager: $WINDOW_MANAGER"
    print_color "$GREEN" "✅ Environment: $DETECTED_ENVIRONMENT"
}

# Function to check bootstrap requirements with state management
check_bootstrap_requirements() {
    print_color "$CYAN" "🔍 Checking bootstrap requirements..."

    local needs_bootstrap=false

    # Source state manager if available (check multiple locations)
    local state_manager_locations=(
        "$SCRIPT_DIR/scripts/bootstrap_state_manager.sh"
        "$SCRIPT_DIR/bootstrap_state_manager.sh"
        "./scripts/bootstrap_state_manager.sh"
        "./bootstrap_state_manager.sh"
    )

    for state_manager in "${state_manager_locations[@]}"; do
        if [[ -f "$state_manager" ]]; then
            source "$state_manager" 2>/dev/null || true
            break
        fi
    done

    # Fix PATH for pipx installations first
    fix_pipx_path

    # Check if we have a valid bootstrap state
    local state_file="$HOME/.dotsible/state/bootstrap_state.json"
    if [[ -f "$state_file" ]]; then
        print_color "$CYAN" "📋 Found existing bootstrap state"

        # Check if all components are marked as installed
        if command -v jq >/dev/null 2>&1; then
            local homebrew_installed=$(jq -r '.installations.homebrew.installed' "$state_file" 2>/dev/null || echo "false")
            local ansible_installed=$(jq -r '.installations.ansible.installed' "$state_file" 2>/dev/null || echo "false")

            if [[ "$homebrew_installed" == "true" && "$ansible_installed" == "true" ]]; then
                print_color "$GREEN" "✅ Bootstrap state indicates system is ready"
            else
                print_color "$YELLOW" "⚠️  Bootstrap state indicates incomplete installation"
                needs_bootstrap=true
            fi
        fi
    fi

    # Verify actual command availability (double-check state)
    if ! verify_ansible_commands &> /dev/null; then
        print_color "$YELLOW" "⚠️  Ansible not found or incomplete - bootstrap required"
        needs_bootstrap=true
    fi

    # Check if Python is available and correct version
    if ! command -v python3 &> /dev/null; then
        print_color "$YELLOW" "⚠️  Python 3 not found - bootstrap required"
        needs_bootstrap=true
    else
        local python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        local python_path=$(which python3)

        # Check if Python version is adequate (3.13+ preferred, 3.8+ minimum)
        if ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
            print_color "$YELLOW" "⚠️  Python version too old ($python_version) - bootstrap required"
            needs_bootstrap=true
        elif ! python3 -c "import sys; exit(0 if sys.version_info >= (3, 13) else 1)" 2>/dev/null; then
            print_color "$YELLOW" "⚠️  Python version outdated ($python_version at $python_path) - upgrade to 3.13+ recommended"
            if [[ "$DETECTED_PLATFORM" == "macos" ]]; then
                print_color "$YELLOW" "    Bootstrap will upgrade to Python 3.13.4"
                needs_bootstrap=true
            fi
        fi
    fi

    # Platform-specific checks
    case "$DETECTED_PLATFORM" in
        "macos")
            if ! command -v brew &> /dev/null; then
                print_color "$YELLOW" "⚠️  Homebrew not found - bootstrap required"
                needs_bootstrap=true
            fi
            if ! xcode-select -p >/dev/null 2>&1; then
                print_color "$YELLOW" "⚠️  Xcode Command Line Tools not found - bootstrap required"
                needs_bootstrap=true
            fi
            ;;
        "archlinux"|"ubuntu")
            if ! command -v git &> /dev/null; then
                print_color "$YELLOW" "⚠️  Git not found - bootstrap required"
                needs_bootstrap=true
            fi
            ;;
    esac

    if [[ "$needs_bootstrap" == "true" ]]; then
        BOOTSTRAP_REQUIRED=true
        print_color "$YELLOW" "🔧 System bootstrap required before Ansible execution"
    else
        print_color "$GREEN" "✅ System ready for Ansible execution"
    fi
}

# Function to run bootstrap if needed
run_bootstrap_if_needed() {
    if [[ "$BOOTSTRAP_REQUIRED" == "true" && "$SKIP_BOOTSTRAP" == "false" ]]; then
        print_color "$BOLD$CYAN" "🚀 SYSTEM BOOTSTRAP REQUIRED"
        print_color "$CYAN" "Your system needs to be prepared before running Ansible."
        echo

        if [[ "$INTERACTIVE_MODE" == "true" ]]; then
            print_color "$YELLOW" "The following will be installed/configured:"
            case "$DETECTED_PLATFORM" in
                "macos")
                    print_color "$CYAN" "  • Xcode Command Line Tools"
                    print_color "$CYAN" "  • Homebrew package manager"
                    print_color "$CYAN" "  • Python 3.8+"
                    print_color "$CYAN" "  • Ansible automation platform"
                    ;;
                "archlinux"|"ubuntu")
                    print_color "$CYAN" "  • System package updates"
                    print_color "$CYAN" "  • Python 3.8+ and pip"
                    print_color "$CYAN" "  • Git version control"
                    print_color "$CYAN" "  • Ansible automation platform"
                    ;;
                "windows")
                    print_color "$CYAN" "  • Chocolatey package manager"
                    print_color "$CYAN" "  • Python 3.8+"
                    print_color "$CYAN" "  • Git for Windows"
                    print_color "$CYAN" "  • Ansible (via pip)"
                    ;;
            esac
            echo
            print_color "$CYAN" "Continue with bootstrap? (y/N): "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_color "$YELLOW" "👋 Bootstrap cancelled by user"
                exit 0
            fi
        fi

        echo
        print_color "$BOLD$BLUE" "🔧 Starting platform bootstrap..."

        # Run appropriate bootstrap script (prefer idempotent versions)
        local bootstrap_script=""
        case "$DETECTED_PLATFORM" in
            "macos")
                if [[ -f "./scripts/bootstrap_macos_idempotent.sh" ]]; then
                    bootstrap_script="./scripts/bootstrap_macos_idempotent.sh"
                else
                    bootstrap_script="./scripts/bootstrap_macos.sh"
                fi
                ;;
            "archlinux")
                bootstrap_script="./scripts/bootstrap_archlinux.sh"
                ;;
            "ubuntu")
                bootstrap_script="./scripts/bootstrap_ubuntu.sh"
                ;;
            "windows")
                bootstrap_script="./scripts/bootstrap_windows.ps1"
                ;;
            *)
                bootstrap_script="./bootstrap.sh"
                ;;
        esac

        if [[ -f "$bootstrap_script" ]]; then
            print_color "$CYAN" "🔧 Executing: $bootstrap_script"

            # Set dry run environment variable for bootstrap script
            if [[ "$DRY_RUN" == "true" ]]; then
                export DRY_RUN=true
                print_color "$CYAN" "🧪 Running bootstrap in dry-run mode"
            fi

            if [[ "$bootstrap_script" == *.ps1 ]]; then
                # Windows PowerShell script
                if powershell.exe -ExecutionPolicy Bypass -File "$bootstrap_script" "$DETECTED_ENVIRONMENT"; then
                    print_color "$GREEN" "✅ Bootstrap script completed successfully"
                else
                    print_color "$RED" "❌ Bootstrap script failed"
                    exit 1
                fi
            else
                # Unix shell script
                chmod +x "$bootstrap_script"
                if "$bootstrap_script" "$DETECTED_ENVIRONMENT"; then
                    print_color "$GREEN" "✅ Bootstrap script completed successfully"
                else
                    print_color "$RED" "❌ Bootstrap script failed"
                    exit 1
                fi
            fi

            # Unset dry run environment variable
            unset DRY_RUN

            # Post-bootstrap validation
            print_color "$CYAN" "🔍 Validating bootstrap results..."

            # Fix PATH for any new installations
            fix_pipx_path

            # Wait a moment for installations to settle
            sleep 2

            # Verify Ansible is now properly installed
            if verify_ansible_commands; then
                print_color "$GREEN" "✅ Bootstrap validation successful - all Ansible commands available"
            else
                print_color "$YELLOW" "⚠️  Bootstrap completed but Ansible installation incomplete"
                print_color "$CYAN" "🔧 Attempting automatic repair..."

                if repair_ansible_installation; then
                    print_color "$GREEN" "✅ Ansible installation repaired successfully"
                else
                    print_color "$RED" "❌ Bootstrap validation failed - Ansible installation incomplete"
                    echo
                    print_color "$CYAN" "💡 This is a known issue with Ansible 11.6.0 via pipx."
                    print_color "$CYAN" "💡 Manual fix: pipx install --force ansible"
                    exit 1
                fi
            fi
        else
            print_color "$RED" "❌ Bootstrap script not found: $bootstrap_script"
            exit 1
        fi

        echo
        print_color "$GREEN" "🎉 System bootstrap completed!"
        print_color "$CYAN" "Continuing with Ansible deployment..."
        echo
    fi
}

# Function to prompt for window manager selection (Linux only)
prompt_window_manager_selection() {
    if [[ "$DETECTED_PLATFORM" != "archlinux" && "$DETECTED_PLATFORM" != "ubuntu" ]]; then
        return  # Skip for non-Linux platforms
    fi

    if [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "unknown" && "$WINDOW_MANAGER" != "none" ]]; then
        print_color "$GREEN" "✅ Detected window manager: $WINDOW_MANAGER"
        print_color "$CYAN" "Use detected window manager? (Y/n): "
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            WINDOW_MANAGER=""  # Force manual selection
        else
            return  # Use detected
        fi
    fi

    print_color "$BOLD$CYAN" "🖥️  Window Manager Selection"
    print_color "$CYAN" "Choose your window manager (Linux only):"
    echo
    print_color "$GREEN" "1) i3         - Tiling window manager (X11)"
    print_color "$GREEN" "   • Lightweight and efficient"
    print_color "$GREEN" "   • Includes: polybar, rofi, picom, dunst"
    echo
    print_color "$YELLOW" "2) hyprland   - Modern tiling compositor (Wayland)"
    print_color "$YELLOW" "   • GPU-accelerated animations"
    print_color "$YELLOW" "   • Includes: waybar, wofi, mako"
    echo
    print_color "$BLUE" "3) sway       - i3-compatible Wayland compositor"
    print_color "$BLUE" "   • Drop-in replacement for i3"
    print_color "$BLUE" "   • Includes: waybar, wofi, mako"
    echo
    print_color "$CYAN" "4) none       - No window manager (desktop environment)"
    print_color "$CYAN" "   • For GNOME, KDE, or other DEs"
    echo
    print_color "$RED" "5) Cancel     - Exit without making changes"
    echo

    while true; do
        read -p "Enter your choice (1-5): " choice
        case $choice in
            1)
                WINDOW_MANAGER="i3"
                print_color "$GREEN" "✅ Selected: i3 window manager"
                break
                ;;
            2)
                WINDOW_MANAGER="hyprland"
                print_color "$GREEN" "✅ Selected: hyprland compositor"
                break
                ;;
            3)
                WINDOW_MANAGER="sway"
                print_color "$GREEN" "✅ Selected: sway compositor"
                break
                ;;
            4)
                WINDOW_MANAGER="none"
                print_color "$GREEN" "✅ Selected: no window manager"
                break
                ;;
            5)
                print_color "$YELLOW" "👋 Cancelled by user"
                exit 0
                ;;
            *)
                print_color "$RED" "❌ Invalid choice. Please enter 1, 2, 3, 4, or 5."
                ;;
        esac
    done
    echo
}

# Function to prompt for profile selection
prompt_profile_selection() {
    if [[ -n "$PROFILE" ]]; then
        return  # Already set
    fi

    print_color "$BOLD$CYAN" "📋 Profile Selection"
    print_color "$CYAN" "Choose your dotsible profile:"
    echo
    print_color "$GREEN" "1) minimal     - Basic system setup with essential tools"
    print_color "$GREEN" "   • Git configuration and basic shell setup"
    print_color "$GREEN" "   • Essential system tools"
    print_color "$GREEN" "   • Minimal dotfiles (git, vim, zsh basics)"
    echo
    print_color "$YELLOW" "2) developer   - Full development environment"
    print_color "$YELLOW" "   • Everything from minimal profile"
    print_color "$YELLOW" "   • Neovim with full configuration"
    print_color "$YELLOW" "   • Tmux terminal multiplexer"
    print_color "$YELLOW" "   • Zsh with oh-my-zsh and plugins"
    print_color "$YELLOW" "   • Development tools and languages"
    print_color "$YELLOW" "   • Complete dotfiles with conditional deployment"
    if [[ "$DETECTED_PLATFORM" == "archlinux" || "$DETECTED_PLATFORM" == "ubuntu" ]]; then
        print_color "$YELLOW" "   • Window manager configurations (if selected)"
    fi
    echo
    print_color "$BLUE" "3) enterprise  - Enterprise-ready setup"
    print_color "$BLUE" "   • Everything from developer profile"
    print_color "$BLUE" "   • Additional security tools"
    print_color "$BLUE" "   • Enterprise compliance settings"
    print_color "$BLUE" "   • Advanced monitoring and logging"
    print_color "$BLUE" "   • Restricted external integrations"
    echo
    print_color "$RED" "4) Cancel      - Exit without making changes"
    echo

    while true; do
        read -p "Enter your choice (1-4): " choice
        case $choice in
            1)
                PROFILE="minimal"
                print_color "$GREEN" "✅ Selected: minimal profile"
                break
                ;;
            2)
                PROFILE="developer"
                print_color "$GREEN" "✅ Selected: developer profile"
                break
                ;;
            3)
                PROFILE="enterprise"
                print_color "$GREEN" "✅ Selected: enterprise profile"
                break
                ;;
            4)
                print_color "$YELLOW" "👋 Cancelled by user"
                exit 0
                ;;
            *)
                print_color "$RED" "❌ Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    echo
}

# Function to prompt for environment type selection
prompt_environment_selection() {
    if [[ -n "$ENVIRONMENT_TYPE" ]]; then
        return  # Already set
    fi

    # Use detected environment as default
    if [[ -n "$DETECTED_ENVIRONMENT" ]]; then
        print_color "$GREEN" "✅ Detected environment: $DETECTED_ENVIRONMENT"
        print_color "$CYAN" "Use detected environment type? (Y/n): "
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            ENVIRONMENT_TYPE="$DETECTED_ENVIRONMENT"
            print_color "$GREEN" "✅ Using detected environment: $ENVIRONMENT_TYPE"
            echo
            return
        fi
    fi

    print_color "$BOLD$CYAN" "🏢 Environment Type Selection"
    print_color "$CYAN" "Choose your environment type:"
    echo
    print_color "$GREEN" "1) personal    - Personal workstation configuration"
    print_color "$GREEN" "   • Optimized for individual productivity"
    print_color "$GREEN" "   • Personal dotfiles and preferences"
    print_color "$GREEN" "   • Flexible security settings"
    print_color "$GREEN" "   • Full customization freedom"
    print_color "$GREEN" "   • MCP packages and external integrations enabled"
    echo
    print_color "$BLUE" "2) enterprise  - Corporate/enterprise environment"
    print_color "$BLUE" "   • Compliance with corporate policies"
    print_color "$BLUE" "   • Enhanced security configurations"
    print_color "$BLUE" "   • Standardized tool versions"
    print_color "$BLUE" "   • Audit logging and monitoring"
    print_color "$BLUE" "   • Restricted external integrations"
    echo
    print_color "$RED" "3) Cancel      - Exit without making changes"
    echo

    while true; do
        read -p "Enter your choice (1-3): " choice
        case $choice in
            1)
                ENVIRONMENT_TYPE="personal"
                print_color "$GREEN" "✅ Selected: personal environment"
                break
                ;;
            2)
                ENVIRONMENT_TYPE="enterprise"
                print_color "$GREEN" "✅ Selected: enterprise environment"
                break
                ;;
            3)
                print_color "$YELLOW" "👋 Cancelled by user"
                exit 0
                ;;
            *)
                print_color "$RED" "❌ Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    echo
}

# Function to detect if sudo privileges are needed
detect_sudo_requirements() {
    local os_type=$(uname -s)
    local needs_sudo=false

    case "$os_type" in
        "Darwin")
            # macOS may need sudo for some installations (Go, system modifications)
            if [[ "$PROFILE" == "developer" || "$PROFILE" == "enterprise" ]]; then
                needs_sudo=true
            fi
            ;;
        "Linux")
            # Linux typically needs sudo for package management
            needs_sudo=true
            ;;
        *)
            # Windows and other systems
            needs_sudo=false
            ;;
    esac

    if [[ "$needs_sudo" == "true" ]]; then
        NEED_SUDO=true
        ASK_BECOME_PASS="--ask-become-pass"
    fi
}

# Function to prompt for sudo password if needed
prompt_sudo_if_needed() {
    if [[ "$NEED_SUDO" == "true" && "$DRY_RUN" == "false" ]]; then
        print_color "$YELLOW" "🔐 Privilege Escalation Required"
        print_color "$CYAN" "Some tasks require administrator privileges for:"

        local os_type=$(uname -s)
        case "$os_type" in
            "Darwin")
                print_color "$CYAN" "  • Installing system packages (Go, system tools)"
                print_color "$CYAN" "  • Modifying system configurations"
                ;;
            "Linux")
                print_color "$CYAN" "  • Package management (apt, pacman, dnf)"
                print_color "$CYAN" "  • Installing system dependencies"
                print_color "$CYAN" "  • Configuring system services"
                ;;
        esac

        echo
        print_color "$YELLOW" "You will be prompted for your password when needed."
        print_color "$CYAN" "Press Enter to continue or Ctrl+C to cancel..."
        read -r
        echo
    fi
}

# Function to display selection summary
display_selection_summary() {
    if [[ "$INTERACTIVE_MODE" == "true" ]]; then
        print_color "$BOLD$GREEN" "📋 Configuration Summary"
        print_color "$GREEN" "Platform: $DETECTED_PLATFORM"
        print_color "$GREEN" "Profile: $PROFILE"
        print_color "$GREEN" "Environment: $ENVIRONMENT_TYPE"
        [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "none" ]] && print_color "$GREEN" "Window Manager: $WINDOW_MANAGER"

        if [[ "$BOOTSTRAP_REQUIRED" == "true" && "$SKIP_BOOTSTRAP" == "false" ]]; then
            print_color "$YELLOW" "Bootstrap: Required (system preparation needed)"
        else
            print_color "$GREEN" "Bootstrap: Not required (system ready)"
        fi

        if [[ "$NEED_SUDO" == "true" ]]; then
            print_color "$YELLOW" "Privileges: Administrator access required"
        else
            print_color "$GREEN" "Privileges: No administrator access needed"
        fi

        # Show what will be deployed
        echo
        print_color "$CYAN" "📦 Components to be deployed:"
        print_color "$CYAN" "  • Platform-specific packages and configurations"
        print_color "$CYAN" "  • Core applications (git, shell setup)"

        if [[ "$PROFILE" == "developer" || "$PROFILE" == "enterprise" ]]; then
            print_color "$CYAN" "  • Development environment (neovim, tmux, zsh)"
            print_color "$CYAN" "  • Dotfiles with conditional deployment"
            [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "none" ]] && print_color "$CYAN" "  • Window manager configurations ($WINDOW_MANAGER)"
        fi

        if [[ "$ENVIRONMENT_TYPE" == "personal" ]]; then
            print_color "$CYAN" "  • MCP packages (@modelcontextprotocol/server-*)"
            print_color "$CYAN" "  • External integrations and experimental features"
        else
            print_color "$CYAN" "  • Enterprise security configurations"
            print_color "$CYAN" "  • Compliance and audit logging"
        fi

        echo
        print_color "$CYAN" "Press Enter to proceed or Ctrl+C to cancel..."
        read -r
        echo
    fi
}

# Function to print usage
usage() {
    cat << EOF
🚀 Dotsible - Enhanced Cross-Platform Environment Setup
   Comprehensive developer environment restoration with full ecosystem integration

Usage: $0 [OPTIONS]

INTERACTIVE MODE:
    $0                         Run with interactive prompts for all selections
                              (automatically detects platform, environment, and window manager)

OPTIONS:
    -p, --profile PROFILE       Set profile (minimal|developer|enterprise)
    -e, --environment ENV       Set environment type (personal|enterprise)
    -w, --window-manager WM     Set window manager (i3|hyprland|sway|none) [Linux only]
    -i, --inventory FILE        Set inventory file [default: inventories/local/hosts.yml]
    -t, --tags TAGS            Run only tasks with specified tags
    --extra-vars VARS          Additional Ansible variables (e.g., "var1=value1 var2=value2")
    -v, --verbose              Enable verbose output (show all Ansible details)
    -n, --dry-run              Run in check mode (no changes made)
    --skip-bootstrap           Skip automatic system bootstrap (advanced users)
    --force-bootstrap          Force bootstrap even if system appears ready
    -h, --help                 Show this help message

EXAMPLES:
    # Interactive mode with automatic detection
    $0

    # Direct execution with specified options
    $0 --profile developer --environment personal

    # Linux with specific window manager
    $0 --profile developer --window-manager i3

    # Dry run to preview changes
    $0 --dry-run

    # Skip bootstrap (if system already prepared)
    $0 --skip-bootstrap

    # Install only platform-specific packages
    $0 --tags platform_specific

    # Verbose output for debugging
    $0 --verbose

    # Install specific applications with dotfiles
    $0 --tags applications,dotfiles

    # Enterprise setup with conditional deployment
    $0 --profile enterprise --environment enterprise

PROFILES:
    minimal     - Basic system setup with essential tools
                 • Git configuration and basic shell setup
                 • Essential system tools
                 • Minimal dotfiles (git, vim, zsh basics)

    developer   - Full development environment
                 • Everything from minimal profile
                 • Neovim with full configuration and dotfiles
                 • Tmux terminal multiplexer with dotfiles
                 • Zsh with oh-my-zsh, plugins, and dotfiles
                 • Development tools and languages
                 • Conditional dotfiles deployment based on platform/WM
                 • MCP packages (personal environment only)

    enterprise  - Enterprise-ready setup
                 • Everything from developer profile
                 • Additional security tools and configurations
                 • Enterprise compliance settings
                 • Advanced monitoring and logging
                 • Restricted external integrations

ENVIRONMENT TYPES:
    personal    - Personal workstation configuration
                 • Full feature set and experimental configs
                 • MCP packages enabled (@modelcontextprotocol/server-*)
                 • External integrations and personal dotfiles
                 • Flexible security settings

    enterprise  - Corporate/enterprise environment
                 • Security hardened configurations
                 • Restricted external integrations
                 • Audit logging and compliance
                 • Standardized tool versions

WINDOW MANAGERS (Linux only):
    i3          - Tiling window manager (X11)
                 • Includes: polybar, rofi, picom, dunst
                 • Lightweight and efficient

    hyprland    - Modern tiling compositor (Wayland)
                 • GPU-accelerated animations
                 • Includes: waybar, wofi, mako

    sway        - i3-compatible Wayland compositor
                 • Drop-in replacement for i3
                 • Includes: waybar, wofi, mako

    none        - No window manager (desktop environment)
                 • For GNOME, KDE, or other DEs

PLATFORM SUPPORT:
    macOS       - Homebrew packages, macOS-specific configurations
    Arch Linux  - Pacman + AUR packages, bleeding-edge configs
    Ubuntu      - APT packages, stable configurations
    Windows     - Chocolatey/Scoop/winget packages (planned)

BOOTSTRAP INTEGRATION:
    The script automatically detects if your system needs preparation and runs
    platform-specific bootstrap scripts to install:
    • Package managers (Homebrew, Chocolatey, etc.)
    • Python 3.8+ and Ansible
    • Essential development tools
    • Platform-specific dependencies

CONDITIONAL DEPLOYMENT:
    Dotfiles and applications are intelligently deployed based on:
    • Operating system and distribution
    • Window manager detection (Linux)
    • Profile selection (minimal/developer/enterprise)
    • Environment type (personal/enterprise)
    • Display server (X11/Wayland/none)

COMMON TAGS:
    platform_specific  - Platform-specific package installation and configuration
    applications       - Application installation and configuration
    fonts             - Font installation and management (Iosevka Nerd Font)
    dotfiles          - Dotfiles deployment with conditional logic
    neovim            - Neovim editor setup with dotfiles
    git               - Git configuration and dotfiles
    tmux              - Terminal multiplexer setup with dotfiles
    zsh               - Zsh shell configuration with oh-my-zsh and plugins
    window_manager    - Window manager configurations (Linux only)

CLEAN OUTPUT:
    The script uses a custom Ansible callback plugin for clean, readable output
    with visual status indicators (✅ INSTALLED, ❌ FAILED, ⏭️ SKIPPED, 🔄 CHANGED)

EOF
}

# Function to verify all expected Ansible commands are available
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
    local available_commands=()

    for cmd in "${expected_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            available_commands+=("$cmd")
        else
            missing_commands+=("$cmd")
        fi
    done

    # Consider it successful if we have the core commands
    local core_commands=("ansible" "ansible-playbook")
    local core_available=0

    for cmd in "${core_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            ((core_available++))
        fi
    done

    if [[ $core_available -eq ${#core_commands[@]} ]]; then
        if [[ ${#missing_commands[@]} -gt 0 ]]; then
            print_color "$YELLOW" "⚠️  Some optional Ansible commands missing: ${missing_commands[*]}"
        fi
        return 0
    else
        print_color "$RED" "❌ Missing critical Ansible commands: ${missing_commands[*]}"
        return 1
    fi
}

# Function to fix PATH for pipx installations
fix_pipx_path() {
    local pipx_bin_dir="$HOME/.local/bin"

    if [[ -d "$pipx_bin_dir" ]] && [[ ":$PATH:" != *":$pipx_bin_dir:"* ]]; then
        export PATH="$pipx_bin_dir:$PATH"
        print_color "$CYAN" "🔧 Added $pipx_bin_dir to PATH for current session"
    fi
}

# Function to attempt Ansible installation repair
repair_ansible_installation() {
    print_color "$YELLOW" "🔧 Attempting to repair Ansible installation..."

    # Fix PATH first
    fix_pipx_path

    # Check if pipx is available
    if ! command -v pipx &> /dev/null; then
        print_color "$RED" "❌ pipx not found. Cannot repair Ansible installation."
        return 1
    fi

    # Check if Ansible is installed in pipx but commands are missing
    if pipx list 2>/dev/null | grep -q ansible; then
        print_color "$CYAN" "🔄 Ansible found in pipx but commands missing. Force reinstalling..."

        # Force reinstall
        if pipx install --force ansible &> /dev/null; then
            print_color "$GREEN" "✅ Ansible force reinstallation completed"

            # Fix PATH again after reinstallation
            fix_pipx_path

            # Verify the repair worked
            if verify_ansible_commands; then
                print_color "$GREEN" "✅ Ansible installation repair successful"
                return 0
            fi
        fi
    fi

    print_color "$RED" "❌ Ansible installation repair failed"
    return 1
}

# Function to validate requirements
validate_requirements() {
    print_color "$CYAN" "🔍 Validating requirements..."

    # Fix PATH for pipx installations first
    fix_pipx_path

    # Check comprehensive Ansible installation
    if ! verify_ansible_commands; then
        print_color "$YELLOW" "⚠️  Ansible installation incomplete. Attempting repair..."

        if repair_ansible_installation; then
            print_color "$GREEN" "✅ Ansible installation repaired successfully"
        else
            print_color "$RED" "❌ Ansible installation repair failed."
            echo
            print_color "$CYAN" "💡 Manual troubleshooting steps:"
            echo "  1. Check pipx installation: pipx list"
            echo "  2. Force reinstall Ansible: pipx install --force ansible"
            echo "  3. Ensure PATH includes ~/.local/bin: export PATH=\"\$HOME/.local/bin:\$PATH\""
            echo "  4. Restart terminal and try again"
            echo "  5. Alternative: pip3 install --user ansible"
            exit 1
        fi
    fi

    # Check if inventory file exists
    if [[ ! -f "$INVENTORY" ]]; then
        print_color "$RED" "❌ Inventory file not found: $INVENTORY"
        exit 1
    fi

    # Check if site.yml exists
    if [[ ! -f "site.yml" ]]; then
        print_color "$RED" "❌ site.yml not found. Please run from the dotsible directory."
        exit 1
    fi

    # Test Ansible functionality
    if ansible localhost -m ping &> /dev/null; then
        print_color "$GREEN" "✅ Ansible functionality verified"
    else
        print_color "$YELLOW" "⚠️  Ansible ping test failed, but installation appears functional"
    fi

    print_color "$GREEN" "✅ Requirements validated"
}

# Function to build ansible command
build_ansible_command() {
    local cmd="ansible-playbook"

    # Add inventory
    cmd="$cmd -i $INVENTORY"

    # Add site.yml
    cmd="$cmd site.yml"

    # Add core extra variables
    cmd="$cmd -e profile=$PROFILE"
    cmd="$cmd -e environment_type=$ENVIRONMENT_TYPE"
    cmd="$cmd -e detected_platform=$DETECTED_PLATFORM"

    # Add window manager detection for Linux
    if [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "none" ]]; then
        cmd="$cmd -e dotsible_window_manager=$WINDOW_MANAGER"
    fi

    # Add conditional deployment variables
    cmd="$cmd -e enable_conditional_dotfiles=true"
    cmd="$cmd -e enable_mcp_packages=$([ "$ENVIRONMENT_TYPE" == "personal" ] && echo "true" || echo "false")"

    # Add platform-specific variables
    case "$DETECTED_PLATFORM" in
        "macos")
            cmd="$cmd -e enable_homebrew_casks=true"
            ;;
        "archlinux")
            cmd="$cmd -e enable_aur_packages=true"
            ;;
        "ubuntu")
            cmd="$cmd -e enable_snap_packages=false"  # Prefer apt
            ;;
    esac

    # Add any additional extra vars
    if [[ -n "$EXTRA_VARS" ]]; then
        cmd="$cmd $EXTRA_VARS"
    fi

    # Add tags if specified
    if [[ -n "$TAGS" ]]; then
        cmd="$cmd --tags $TAGS"
    fi

    # Add dry run if specified
    if [[ "$DRY_RUN" == "true" ]]; then
        cmd="$cmd --check"
    fi

    # Add sudo handling if needed
    if [[ -n "$ASK_BECOME_PASS" ]]; then
        cmd="$cmd $ASK_BECOME_PASS"
    fi

    # Add verbose if specified
    if [[ "$VERBOSE" == "true" ]]; then
        cmd="$cmd -vv"
        # Use default callback for verbose mode
        export ANSIBLE_STDOUT_CALLBACK=yaml
    else
        # Use clean callback for normal mode
        export ANSIBLE_STDOUT_CALLBACK=dotsible_clean
    fi

    echo "$cmd"
}

# Function to display execution summary
display_execution_info() {
    print_color "$BOLD$BLUE" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$BOLD$BLUE" "║                    DOTSIBLE EXECUTION                       ║"
    print_color "$BOLD$BLUE" "╠══════════════════════════════════════════════════════════════╣"
    print_color "$BLUE" "║ Platform: $(printf "%-50s" "$DETECTED_PLATFORM") ║"
    print_color "$BLUE" "║ Profile: $(printf "%-51s" "$PROFILE") ║"
    print_color "$BLUE" "║ Environment: $(printf "%-47s" "$ENVIRONMENT_TYPE") ║"
    if [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "none" ]]; then
        print_color "$BLUE" "║ Window Manager: $(printf "%-44s" "$WINDOW_MANAGER") ║"
    fi
    print_color "$BLUE" "║ Mode: $(printf "%-54s" "$([ "$DRY_RUN" == "true" ] && echo "DRY RUN" || echo "EXECUTION")") ║"
    print_color "$BLUE" "║ Bootstrap: $(printf "%-49s" "$([ "$BOOTSTRAP_REQUIRED" == "true" ] && echo "COMPLETED" || echo "NOT REQUIRED")") ║"
    print_color "$BLUE" "║ Verbose: $(printf "%-51s" "$([ "$VERBOSE" == "true" ] && echo "ENABLED" || echo "DISABLED")") ║"
    print_color "$BLUE" "║ Privileges: $(printf "%-48s" "$([ "$NEED_SUDO" == "true" ] && echo "ADMIN REQUIRED" || echo "USER LEVEL")") ║"
    if [[ -n "$TAGS" ]]; then
        print_color "$BLUE" "║ Tags: $(printf "%-54s" "$TAGS") ║"
    fi
    print_color "$BOLD$BLUE" "╚══════════════════════════════════════════════════════════════╝"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--profile)
            PROFILE="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT_TYPE="$2"
            shift 2
            ;;
        -w|--window-manager)
            WINDOW_MANAGER="$2"
            shift 2
            ;;
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        --extra-vars)
            EXTRA_VARS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-bootstrap)
            SKIP_BOOTSTRAP=true
            shift
            ;;
        --force-bootstrap)
            FORCE_BOOTSTRAP=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_color "$RED" "❌ Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Force bootstrap if requested
if [[ "$FORCE_BOOTSTRAP" == "true" ]]; then
    BOOTSTRAP_REQUIRED=true
fi

# Main execution
main() {
    # Display header
    print_color "$BOLD$CYAN" "🚀 Dotsible - Cross-Platform Environment Setup"
    print_color "$CYAN" "Enhanced execution script with full ecosystem integration"
    echo

    # Step 1: Platform and environment detection
    detect_platform_environment
    echo

    # Step 2: Check bootstrap requirements
    check_bootstrap_requirements
    echo

    # Step 3: Determine if we need interactive mode
    if [[ -z "$PROFILE" || -z "$ENVIRONMENT_TYPE" ]]; then
        INTERACTIVE_MODE=true
    fi

    # Step 4: Handle interactive prompts
    if [[ "$INTERACTIVE_MODE" == "true" ]]; then
        prompt_profile_selection
        prompt_environment_selection
        prompt_window_manager_selection
    fi

    # Step 5: Validate provided arguments
    if [[ ! "$PROFILE" =~ ^(minimal|developer|enterprise)$ ]]; then
        print_color "$RED" "❌ Invalid profile: $PROFILE. Must be minimal, developer, or enterprise."
        exit 1
    fi

    if [[ ! "$ENVIRONMENT_TYPE" =~ ^(personal|enterprise)$ ]]; then
        print_color "$RED" "❌ Invalid environment type: $ENVIRONMENT_TYPE. Must be personal or enterprise."
        exit 1
    fi

    # Step 6: Run bootstrap if needed
    run_bootstrap_if_needed

    # Step 7: Validate final requirements
    validate_requirements
    echo

    # Step 8: Detect sudo requirements
    detect_sudo_requirements

    # Step 9: Display selection summary if interactive
    display_selection_summary

    # Step 10: Prompt for sudo if needed
    prompt_sudo_if_needed

    # Step 11: Display execution info
    display_execution_info

    # Step 12: Build and execute ansible command
    local ansible_cmd
    ansible_cmd=$(build_ansible_command)

    print_color "$CYAN" "🔧 Executing: $ansible_cmd"
    echo

    # Final pre-execution validation
    print_color "$CYAN" "🔍 Final validation before execution..."
    if ! verify_ansible_commands &> /dev/null; then
        print_color "$RED" "❌ Critical error: Ansible commands not available before execution"
        print_color "$CYAN" "💡 This indicates a system integration issue. Please:"
        echo "  1. Restart your terminal"
        echo "  2. Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "  3. Verify: ansible-playbook --version"
        echo "  4. If still failing, run: pipx install --force ansible"
        exit 1
    fi

    # Execute the command
    if eval "$ansible_cmd"; then
        echo
        print_color "$BOLD$GREEN" "🎉 Dotsible execution completed successfully!"

        if [[ "$DRY_RUN" == "false" ]]; then
            print_color "$GREEN" "Your system has been configured with the $PROFILE profile on $DETECTED_PLATFORM."
            print_color "$YELLOW" "💡 Next steps:"
            print_color "$YELLOW" "   • Restart your shell or run: source ~/.zshrc"
            print_color "$YELLOW" "   • Check logs: ~/.dotsible/execution.log"
            if [[ "$PROFILE" != "minimal" ]]; then
                print_color "$YELLOW" "   • Test your development environment"
                [[ -n "$WINDOW_MANAGER" && "$WINDOW_MANAGER" != "none" ]] && print_color "$YELLOW" "   • Log out and back in to activate $WINDOW_MANAGER"
            fi
            if [[ "$ENVIRONMENT_TYPE" == "personal" ]]; then
                print_color "$YELLOW" "   • MCP packages are available for AI development"
            fi
        else
            print_color "$GREEN" "Dry run completed. No changes were made to your system."
            print_color "$YELLOW" "💡 Run without --dry-run to apply changes."
        fi
    else
        echo
        print_color "$BOLD$RED" "❌ Dotsible execution failed!"
        print_color "$RED" "Check the output above for error details."

        # Show detailed error log files if they exist
        echo
        print_color "$CYAN" "🔍 Detailed Error Information:"
        if ls ~/.dotsible/error_details_*.log >/dev/null 2>&1; then
            for error_log in ~/.dotsible/error_details_*.log; do
                if [[ -f "$error_log" ]]; then
                    print_color "$YELLOW" "   📝 $error_log"
                fi
            done | head -3
        else
            print_color "$YELLOW" "   No detailed error logs found"
        fi

        echo
        print_color "$YELLOW" "💡 Troubleshooting tips:"
        print_color "$YELLOW" "   • Run with --verbose for detailed output"
        print_color "$YELLOW" "   • Check ~/.dotsible/execution.log for basic logs"
        print_color "$YELLOW" "   • Check ~/.dotsible/error_details_*.log for detailed error information"
        print_color "$YELLOW" "   • Ensure you have proper permissions"
        print_color "$YELLOW" "   • Try running bootstrap manually: ./bootstrap.sh"
        print_color "$YELLOW" "   • Try running individual components:"
        print_color "$YELLOW" "     - Platform setup: ./run-dotsible.sh --tags platform_specific"
        print_color "$YELLOW" "     - Applications: ./run-dotsible.sh --tags applications"
        print_color "$YELLOW" "     - Dotfiles: ./run-dotsible.sh --tags dotfiles"
        exit 1
    fi
}

# Execute main function
main "$@"
