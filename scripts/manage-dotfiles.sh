#!/bin/bash

# Dotsible Dotfiles Management Script
# Comprehensive tool for managing dotfiles in the conditional deployment system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTSIBLE_ROOT="$(dirname "$SCRIPT_DIR")"
DOTFILES_DIR="$DOTSIBLE_ROOT/files/dotfiles"

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to print section headers
print_header() {
    echo
    print_color "$BOLD$CYAN" "╔══════════════════════════════════════════════════════════════╗"
    print_color "$BOLD$CYAN" "║ $1"
    print_color "$BOLD$CYAN" "╚══════════════════════════════════════════════════════════════╝"
    echo
}

# Function to backup existing dotfiles
backup_existing_dotfiles() {
    local backup_dir="$HOME/.dotsible_backup_$(date +%Y%m%d_%H%M%S)"
    
    print_header "BACKING UP EXISTING DOTFILES"
    
    mkdir -p "$backup_dir"
    
    # Common dotfiles to backup
    local files_to_backup=(
        ".gitconfig"
        ".zshrc"
        ".bashrc"
        ".tmux.conf"
        ".vimrc"
        ".config/nvim"
        ".config/alacritty"
        ".config/starship.toml"
        ".config/i3"
        ".config/hypr"
        ".config/sway"
    )
    
    for file in "${files_to_backup[@]}"; do
        local source_path="$HOME/$file"
        if [[ -e "$source_path" ]]; then
            local backup_path="$backup_dir/$file"
            mkdir -p "$(dirname "$backup_path")"
            cp -r "$source_path" "$backup_path"
            print_color "$GREEN" "✅ Backed up: $file"
        else
            print_color "$YELLOW" "⏭️  Not found: $file"
        fi
    done
    
    print_color "$BOLD$GREEN" "📦 Backup completed: $backup_dir"
}

# Function to validate dotfiles structure
validate_dotfiles_structure() {
    print_header "VALIDATING DOTFILES STRUCTURE"
    
    local validation_passed=true
    
    # Check if dotfiles directory exists
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_color "$RED" "❌ Dotfiles directory not found: $DOTFILES_DIR"
        return 1
    fi
    
    # Check for required application directories
    local required_apps=("nvim" "git" "zsh" "tmux")
    for app in "${required_apps[@]}"; do
        if [[ -d "$DOTFILES_DIR/$app" ]]; then
            print_color "$GREEN" "✅ Found: $app"
            
            # Check for key files
            case $app in
                "nvim")
                    [[ -f "$DOTFILES_DIR/$app/init.lua" ]] && print_color "$GREEN" "  ✅ init.lua" || print_color "$YELLOW" "  ⚠️  Missing init.lua"
                    ;;
                "git")
                    [[ -f "$DOTFILES_DIR/$app/.gitconfig" ]] && print_color "$GREEN" "  ✅ .gitconfig" || print_color "$YELLOW" "  ⚠️  Missing .gitconfig"
                    ;;
                "zsh")
                    [[ -f "$DOTFILES_DIR/$app/.zshrc" ]] && print_color "$GREEN" "  ✅ .zshrc" || print_color "$YELLOW" "  ⚠️  Missing .zshrc"
                    ;;
                "tmux")
                    [[ -f "$DOTFILES_DIR/$app/.tmux.conf" ]] && print_color "$GREEN" "  ✅ .tmux.conf" || print_color "$YELLOW" "  ⚠️  Missing .tmux.conf"
                    ;;
            esac
        else
            print_color "$YELLOW" "⚠️  Missing: $app"
            validation_passed=false
        fi
    done
    
    if $validation_passed; then
        print_color "$BOLD$GREEN" "✅ Dotfiles structure validation passed"
    else
        print_color "$BOLD$YELLOW" "⚠️  Dotfiles structure has some issues"
    fi
}

# Function to show deployment mapping
show_deployment_mapping() {
    print_header "DEPLOYMENT MAPPING"
    
    print_color "$BOLD$BLUE" "📁 Directory Mappings (Unix/Linux/macOS):"
    echo "  nvim/           → ~/.config/nvim/"
    echo "  i3/             → ~/.config/i3/"
    echo "  hyprland/       → ~/.config/hypr/"
    echo "  alacritty/      → ~/.config/alacritty/"
    echo "  sway/           → ~/.config/sway/"
    
    echo
    print_color "$BOLD$BLUE" "📄 File Mappings (Unix/Linux/macOS):"
    echo "  git/.gitconfig  → ~/.gitconfig"
    echo "  zsh/.zshrc      → ~/.zshrc"
    echo "  tmux/.tmux.conf → ~/.tmux.conf"
    echo "  starship/starship.toml → ~/.config/starship.toml"
    
    echo
    print_color "$BOLD$BLUE" "🪟 Windows Mappings:"
    echo "  nvim/           → %LOCALAPPDATA%/nvim/"
    echo "  git/.gitconfig  → %USERPROFILE%/.gitconfig"
    echo "  alacritty/      → %APPDATA%/alacritty/"
}

# Function to test conditional deployment
test_conditional_deployment() {
    print_header "TESTING CONDITIONAL DEPLOYMENT"
    
    print_color "$BLUE" "🧪 Running conditional deployment test..."
    
    if [[ -f "$DOTSIBLE_ROOT/test-conditional-dotfiles.sh" ]]; then
        cd "$DOTSIBLE_ROOT"
        ./test-conditional-dotfiles.sh
    else
        print_color "$YELLOW" "⚠️  Test script not found. Running basic validation..."
        
        # Basic test using ansible
        if command -v ansible-playbook >/dev/null 2>&1; then
            ansible-playbook test-conditional-only.yml --check 2>/dev/null || print_color "$YELLOW" "⚠️  Conditional test had issues"
        else
            print_color "$RED" "❌ Ansible not available for testing"
        fi
    fi
}

# Function to deploy dotfiles
deploy_dotfiles() {
    local profile=${1:-"developer"}
    local dry_run=${2:-false}
    
    print_header "DEPLOYING DOTFILES"
    
    print_color "$BLUE" "🚀 Deploying with profile: $profile"
    
    local deploy_cmd="./run-dotsible.sh --profile $profile --tags dotfiles"
    
    if $dry_run; then
        deploy_cmd="$deploy_cmd --check"
        print_color "$YELLOW" "🔍 Running in dry-run mode (--check)"
    fi
    
    print_color "$CYAN" "Command: $deploy_cmd"
    
    if [[ -f "$DOTSIBLE_ROOT/run-dotsible.sh" ]]; then
        cd "$DOTSIBLE_ROOT"
        eval "$deploy_cmd"
    else
        print_color "$RED" "❌ run-dotsible.sh not found"
        return 1
    fi
}

# Function to show usage
show_usage() {
    print_color "$BOLD$CYAN" "Dotsible Dotfiles Management Script"
    echo
    print_color "$BOLD" "USAGE:"
    echo "  $0 [COMMAND] [OPTIONS]"
    echo
    print_color "$BOLD" "COMMANDS:"
    echo "  backup              Backup existing dotfiles"
    echo "  validate            Validate dotfiles structure"
    echo "  mapping             Show deployment mapping"
    echo "  test                Test conditional deployment"
    echo "  deploy [PROFILE]    Deploy dotfiles (default: developer)"
    echo "  dry-run [PROFILE]   Test deployment without changes"
    echo "  help                Show this help message"
    echo
    print_color "$BOLD" "PROFILES:"
    echo "  minimal             Essential tools only"
    echo "  developer           Full development environment"
    echo "  enterprise          Security-focused configuration"
    echo "  server              Headless server setup"
    echo
    print_color "$BOLD" "EXAMPLES:"
    echo "  $0 backup                    # Backup existing dotfiles"
    echo "  $0 validate                  # Check dotfiles structure"
    echo "  $0 deploy developer          # Deploy with developer profile"
    echo "  $0 dry-run minimal           # Test minimal profile deployment"
    echo "  $0 test                      # Test conditional logic"
}

# Main function
main() {
    local command=${1:-"help"}
    
    case $command in
        "backup")
            backup_existing_dotfiles
            ;;
        "validate")
            validate_dotfiles_structure
            ;;
        "mapping")
            show_deployment_mapping
            ;;
        "test")
            test_conditional_deployment
            ;;
        "deploy")
            deploy_dotfiles "${2:-developer}" false
            ;;
        "dry-run")
            deploy_dotfiles "${2:-developer}" true
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_color "$RED" "❌ Unknown command: $command"
            echo
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
