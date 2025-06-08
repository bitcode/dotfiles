#!/bin/bash

# Dotsible Clean Execution Script
# Provides clean, readable output for dotsible deployments with interactive prompts

set -euo pipefail

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

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to prompt for profile selection
prompt_profile_selection() {
    print_color "$BOLD$CYAN" "📋 Profile Selection"
    print_color "$CYAN" "Choose your dotsible profile:"
    echo
    print_color "$GREEN" "1) minimal     - Basic system setup with essential tools"
    print_color "$GREEN" "   • Git configuration"
    print_color "$GREEN" "   • Basic shell setup"
    print_color "$GREEN" "   • Essential system tools"
    echo
    print_color "$YELLOW" "2) developer   - Full development environment"
    print_color "$YELLOW" "   • Everything from minimal profile"
    print_color "$YELLOW" "   • Neovim with full configuration"
    print_color "$YELLOW" "   • Tmux terminal multiplexer"
    print_color "$YELLOW" "   • Zsh shell with enhancements"
    print_color "$YELLOW" "   • Development tools and languages"
    echo
    print_color "$BLUE" "3) enterprise  - Enterprise-ready setup"
    print_color "$BLUE" "   • Everything from developer profile"
    print_color "$BLUE" "   • Additional security tools"
    print_color "$BLUE" "   • Enterprise compliance settings"
    print_color "$BLUE" "   • Advanced monitoring and logging"
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
    print_color "$BOLD$CYAN" "🏢 Environment Type Selection"
    print_color "$CYAN" "Choose your environment type:"
    echo
    print_color "$GREEN" "1) personal    - Personal workstation configuration"
    print_color "$GREEN" "   • Optimized for individual productivity"
    print_color "$GREEN" "   • Personal dotfiles and preferences"
    print_color "$GREEN" "   • Flexible security settings"
    print_color "$GREEN" "   • Full customization freedom"
    echo
    print_color "$BLUE" "2) enterprise  - Corporate/enterprise environment"
    print_color "$BLUE" "   • Compliance with corporate policies"
    print_color "$BLUE" "   • Enhanced security configurations"
    print_color "$BLUE" "   • Standardized tool versions"
    print_color "$BLUE" "   • Audit logging and monitoring"
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
        print_color "$GREEN" "Profile: $PROFILE"
        print_color "$GREEN" "Environment: $ENVIRONMENT_TYPE"
        if [[ "$NEED_SUDO" == "true" ]]; then
            print_color "$YELLOW" "Privileges: Administrator access required"
        else
            print_color "$GREEN" "Privileges: No administrator access needed"
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
🚀 Dotsible - Cross-Platform Environment Setup

Usage: $0 [OPTIONS]

INTERACTIVE MODE:
    $0                         Run with interactive prompts for profile and environment selection

OPTIONS:
    -p, --profile PROFILE       Set profile (minimal|developer|enterprise)
    -e, --environment ENV       Set environment type (personal|enterprise)
    -i, --inventory FILE        Set inventory file [default: inventories/local/hosts.yml]
    -t, --tags TAGS            Run only tasks with specified tags
    -v, --verbose              Enable verbose output (show all Ansible details)
    -n, --dry-run              Run in check mode (no changes made)
    -h, --help                 Show this help message

EXAMPLES:
    # Interactive mode with prompts
    $0

    # Direct execution with specified options
    $0 --profile developer --environment enterprise

    # Dry run to preview changes
    $0 --dry-run

    # Install only platform-specific packages
    $0 --tags platform_specific

    # Verbose output for debugging
    $0 --verbose

    # Install specific applications
    $0 --tags neovim,git,tmux

PROFILES:
    minimal     - Basic system setup with essential tools
    developer   - Full development environment with editors, languages, etc.
    enterprise  - Enterprise-ready setup with additional security and tools

ENVIRONMENT TYPES:
    personal    - Personal workstation configuration
    enterprise  - Enterprise/corporate environment settings

COMMON TAGS:
    platform_specific  - Platform-specific package installation
    applications       - Application installation and configuration
    neovim            - Neovim editor setup
    git               - Git configuration
    tmux              - Terminal multiplexer setup
    zsh               - Zsh shell configuration

EOF
}

# Function to validate requirements
validate_requirements() {
    print_color "$CYAN" "🔍 Validating requirements..."
    
    # Check if ansible-playbook is available
    if ! command -v ansible-playbook &> /dev/null; then
        print_color "$RED" "❌ ansible-playbook not found. Please install Ansible first."
        exit 1
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
    
    print_color "$GREEN" "✅ Requirements validated"
}

# Function to build ansible command
build_ansible_command() {
    local cmd="ansible-playbook"

    # Add inventory
    cmd="$cmd -i $INVENTORY"

    # Add site.yml
    cmd="$cmd site.yml"

    # Add extra variables
    cmd="$cmd -e profile=$PROFILE"
    cmd="$cmd -e environment_type=$ENVIRONMENT_TYPE"

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
    print_color "$BLUE" "║ Profile: $(printf "%-51s" "$PROFILE") ║"
    print_color "$BLUE" "║ Environment: $(printf "%-47s" "$ENVIRONMENT_TYPE") ║"
    print_color "$BLUE" "║ Mode: $(printf "%-54s" "$([ "$DRY_RUN" == "true" ] && echo "DRY RUN" || echo "EXECUTION")") ║"
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
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -t|--tags)
            TAGS="$2"
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

# Determine if we need interactive mode
if [[ -z "$PROFILE" || -z "$ENVIRONMENT_TYPE" ]]; then
    INTERACTIVE_MODE=true
fi

# Handle interactive mode or validate provided arguments
if [[ "$INTERACTIVE_MODE" == "true" ]]; then
    # Interactive prompts for missing parameters
    if [[ -z "$PROFILE" ]]; then
        prompt_profile_selection
    fi
    if [[ -z "$ENVIRONMENT_TYPE" ]]; then
        prompt_environment_selection
    fi
else
    # Validate provided arguments
    if [[ ! "$PROFILE" =~ ^(minimal|developer|enterprise)$ ]]; then
        print_color "$RED" "❌ Invalid profile: $PROFILE. Must be minimal, developer, or enterprise."
        exit 1
    fi

    if [[ ! "$ENVIRONMENT_TYPE" =~ ^(personal|enterprise)$ ]]; then
        print_color "$RED" "❌ Invalid environment type: $ENVIRONMENT_TYPE. Must be personal or enterprise."
        exit 1
    fi
fi

# Main execution
main() {
    # Display header
    print_color "$BOLD$CYAN" "🚀 Dotsible - Cross-Platform Environment Setup"
    echo

    # Validate requirements
    validate_requirements
    echo

    # Detect sudo requirements
    detect_sudo_requirements

    # Display selection summary if interactive
    display_selection_summary

    # Prompt for sudo if needed
    prompt_sudo_if_needed

    # Display execution info
    display_execution_info

    # Build and execute ansible command
    local ansible_cmd
    ansible_cmd=$(build_ansible_command)

    print_color "$CYAN" "🔧 Executing: $ansible_cmd"
    echo

    # Execute the command
    if eval "$ansible_cmd"; then
        echo
        print_color "$BOLD$GREEN" "🎉 Dotsible execution completed successfully!"
        
        if [[ "$DRY_RUN" == "false" ]]; then
            print_color "$GREEN" "Your system has been configured with the $PROFILE profile."
            print_color "$YELLOW" "💡 Next steps:"
            print_color "$YELLOW" "   • Restart your shell or run: source ~/.zshrc"
            print_color "$YELLOW" "   • Check logs: ~/.dotsible/execution.log"
            if [[ "$PROFILE" != "minimal" ]]; then
                print_color "$YELLOW" "   • Test your development environment"
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
        print_color "$YELLOW" "   • Try running individual components:"
        print_color "$YELLOW" "     - Platform setup: ansible-playbook site.yml --tags platform_specific"
        print_color "$YELLOW" "     - Package installation: ansible-playbook site.yml --tags packages"
        print_color "$YELLOW" "     - Dotfiles deployment: ansible-playbook site.yml --tags dotfiles"
        exit 1
    fi
}

# Execute main function
main "$@"
