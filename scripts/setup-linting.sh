#!/bin/bash

# Setup Script for Ansible Linting Workflow
# This script installs and configures all linting tools for Dotsible development

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python_version() {
    print_status "$BLUE" "🐍 Checking Python version..."
    
    if command_exists python3; then
        local python_version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        local required_version="3.8"
        
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
            print_status "$GREEN" "✅ Python $python_version (meets requirement: $required_version+)"
            return 0
        else
            print_status "$RED" "❌ Python $python_version is too old (required: $required_version+)"
            return 1
        fi
    else
        print_status "$RED" "❌ Python 3 not found"
        print_status "$YELLOW" "💡 Install Python 3.8+ before continuing"
        return 1
    fi
}

# Function to install Python dependencies
install_python_deps() {
    print_status "$BLUE" "📦 Installing Python dependencies..."
    
    cd "$REPO_ROOT"
    
    # Check if requirements files exist
    if [[ ! -f "requirements.txt" ]]; then
        print_status "$RED" "❌ requirements.txt not found"
        return 1
    fi
    
    if [[ ! -f "requirements-dev.txt" ]]; then
        print_status "$RED" "❌ requirements-dev.txt not found"
        return 1
    fi
    
    # Install base requirements
    print_status "$BLUE" "  📋 Installing base requirements..."
    if pip3 install -r requirements.txt; then
        print_status "$GREEN" "    ✅ Base requirements installed"
    else
        print_status "$RED" "    ❌ Failed to install base requirements"
        return 1
    fi
    
    # Install development requirements
    print_status "$BLUE" "  🔧 Installing development requirements..."
    if pip3 install -r requirements-dev.txt; then
        print_status "$GREEN" "    ✅ Development requirements installed"
    else
        print_status "$RED" "    ❌ Failed to install development requirements"
        return 1
    fi
}

# Function to install pre-commit hooks
install_precommit_hooks() {
    print_status "$BLUE" "🪝 Installing pre-commit hooks..."
    
    cd "$REPO_ROOT"
    
    if command_exists pre-commit; then
        if pre-commit install; then
            print_status "$GREEN" "✅ Pre-commit hooks installed"
            
            # Install additional hook types
            if pre-commit install --hook-type commit-msg; then
                print_status "$GREEN" "✅ Commit message hooks installed"
            fi
            
            if pre-commit install --hook-type pre-push; then
                print_status "$GREEN" "✅ Pre-push hooks installed"
            fi
        else
            print_status "$RED" "❌ Failed to install pre-commit hooks"
            return 1
        fi
    else
        print_status "$RED" "❌ pre-commit not found (should be installed with requirements-dev.txt)"
        return 1
    fi
}

# Function to validate installation
validate_installation() {
    print_status "$BLUE" "🔍 Validating installation..."
    
    local validation_failed=false
    
    # Check ansible-lint
    if command_exists ansible-lint; then
        local version=$(ansible-lint --version | head -n1)
        print_status "$GREEN" "✅ ansible-lint: $version"
    else
        print_status "$RED" "❌ ansible-lint not found"
        validation_failed=true
    fi
    
    # Check yamllint
    if command_exists yamllint; then
        local version=$(yamllint --version)
        print_status "$GREEN" "✅ yamllint: $version"
    else
        print_status "$RED" "❌ yamllint not found"
        validation_failed=true
    fi
    
    # Check pre-commit
    if command_exists pre-commit; then
        local version=$(pre-commit --version)
        print_status "$GREEN" "✅ pre-commit: $version"
    else
        print_status "$RED" "❌ pre-commit not found"
        validation_failed=true
    fi
    
    # Check shellcheck
    if command_exists shellcheck; then
        local version=$(shellcheck --version | grep version | awk '{print $2}')
        print_status "$GREEN" "✅ shellcheck: $version"
    else
        print_status "$YELLOW" "⚠️  shellcheck not found (optional, but recommended)"
    fi
    
    # Check configuration files
    if [[ -f "$REPO_ROOT/.ansible-lint.yml" ]]; then
        print_status "$GREEN" "✅ .ansible-lint.yml configuration found"
    else
        print_status "$RED" "❌ .ansible-lint.yml configuration missing"
        validation_failed=true
    fi
    
    if [[ -f "$REPO_ROOT/.pre-commit-config.yaml" ]]; then
        print_status "$GREEN" "✅ .pre-commit-config.yaml configuration found"
    else
        print_status "$RED" "❌ .pre-commit-config.yaml configuration missing"
        validation_failed=true
    fi
    
    if [[ "$validation_failed" == "true" ]]; then
        return 1
    else
        return 0
    fi
}

# Function to run initial linting test
run_initial_test() {
    print_status "$BLUE" "🧪 Running initial linting test..."
    
    cd "$REPO_ROOT"
    
    # Test ansible-lint
    print_status "$BLUE" "  🎭 Testing ansible-lint..."
    if ansible-lint --version >/dev/null 2>&1; then
        print_status "$GREEN" "    ✅ ansible-lint working"
    else
        print_status "$RED" "    ❌ ansible-lint test failed"
        return 1
    fi
    
    # Test pre-commit
    print_status "$BLUE" "  🪝 Testing pre-commit hooks..."
    if pre-commit run --all-files --show-diff-on-failure; then
        print_status "$GREEN" "    ✅ Pre-commit hooks working"
    else
        print_status "$YELLOW" "    ⚠️  Pre-commit hooks found issues (this is normal for initial setup)"
        print_status "$YELLOW" "    💡 Run 'pre-commit run --all-files' to see and fix issues"
    fi
}

# Function to show post-installation instructions
show_instructions() {
    print_status "$GREEN" "🎉 Linting workflow setup complete!"
    echo
    print_status "$BLUE" "📋 Next Steps:"
    echo
    print_status "$YELLOW" "1. Test the linting workflow:"
    echo "   ./scripts/lint-ansible.sh"
    echo
    print_status "$YELLOW" "2. Run pre-commit on all files:"
    echo "   pre-commit run --all-files"
    echo
    print_status "$YELLOW" "3. Make a test commit to verify hooks:"
    echo "   git add ."
    echo "   git commit -m 'Test commit for linting setup'"
    echo
    print_status "$YELLOW" "4. Read the documentation:"
    echo "   docs/ANSIBLE_LINTING.md"
    echo
    print_status "$BLUE" "🔧 Available Commands:"
    echo
    print_status "$YELLOW" "Linting:"
    echo "   ./scripts/lint-ansible.sh           # Run all linting checks"
    echo "   ./scripts/lint-ansible.sh --fix     # Run with auto-fix"
    echo "   ./scripts/lint-ansible.sh --help    # Show all options"
    echo
    print_status "$YELLOW" "Pre-commit:"
    echo "   pre-commit run                      # Run on staged files"
    echo "   pre-commit run --all-files          # Run on all files"
    echo "   pre-commit autoupdate               # Update hook versions"
    echo
    print_status "$YELLOW" "Individual tools:"
    echo "   ansible-lint .                      # Ansible linting only"
    echo "   yamllint .                          # YAML linting only"
    echo "   shellcheck scripts/*.sh             # Shell script linting"
    echo
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Setup Script for Ansible Linting Workflow
Installs and configures all linting tools for Dotsible development

OPTIONS:
  --help, -h          Show this help message
  --check-only        Only check prerequisites, don't install
  --skip-test         Skip initial linting test
  --force             Force reinstallation of all components

EXAMPLES:
  $0                  # Full setup
  $0 --check-only     # Check prerequisites only
  $0 --skip-test      # Setup without running tests

This script will:
1. Check Python version (3.8+ required)
2. Install Python dependencies from requirements.txt and requirements-dev.txt
3. Install pre-commit hooks
4. Validate the installation
5. Run initial linting tests
6. Show usage instructions

For detailed documentation, see docs/ANSIBLE_LINTING.md
EOF
}

# Main execution function
main() {
    print_status "$BLUE" "🚀 Setting up Ansible Linting Workflow for Dotsible"
    print_status "$BLUE" "📁 Repository: $REPO_ROOT"
    echo
    
    # Check prerequisites
    if ! check_python_version; then
        print_status "$RED" "💥 Prerequisites not met"
        exit 1
    fi
    echo
    
    # Install dependencies
    if ! install_python_deps; then
        print_status "$RED" "💥 Failed to install Python dependencies"
        exit 1
    fi
    echo
    
    # Install pre-commit hooks
    if ! install_precommit_hooks; then
        print_status "$RED" "💥 Failed to install pre-commit hooks"
        exit 1
    fi
    echo
    
    # Validate installation
    if ! validate_installation; then
        print_status "$RED" "💥 Installation validation failed"
        exit 1
    fi
    echo
    
    # Run initial test (unless skipped)
    if [[ "${SKIP_TEST:-false}" != "true" ]]; then
        if ! run_initial_test; then
            print_status "$YELLOW" "⚠️  Initial test had issues, but setup is complete"
        fi
        echo
    fi
    
    # Show instructions
    show_instructions
}

# Parse command line arguments
CHECK_ONLY=false
SKIP_TEST=false
FORCE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --check-only)
            CHECK_ONLY=true
            shift
            ;;
        --skip-test)
            SKIP_TEST=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            print_status "$RED" "❌ Unknown argument: $1"
            print_status "$YELLOW" "💡 Use --help for usage information"
            exit 1
            ;;
    esac
done

# Handle check-only mode
if [[ "$CHECK_ONLY" == "true" ]]; then
    print_status "$BLUE" "🔍 Checking prerequisites only..."
    echo
    
    if check_python_version; then
        print_status "$GREEN" "✅ All prerequisites met"
        exit 0
    else
        print_status "$RED" "❌ Prerequisites not met"
        exit 1
    fi
fi

# Run main function
main