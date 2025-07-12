#!/bin/bash

# Ansible Lint Script for Dotfiles Repository
# This script runs ansible-lint on all playbooks and roles to ensure code quality

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
LINT_CONFIG="$REPO_ROOT/.ansible-lint.yml"
EXIT_CODE=0
FIX_MODE=false
RUN_PRECOMMIT=false
SPECIFIC_RULES=""
EXCLUDE_FILES=""

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if ansible-lint is available
check_ansible_lint() {
    print_status "$BLUE" "🔍 Checking for ansible-lint..."
    
    if command -v ansible-lint >/dev/null 2>&1; then
        local version=$(ansible-lint --version | head -n1)
        print_status "$GREEN" "✅ Found: $version"
        return 0
    else
        print_status "$RED" "❌ ansible-lint not found!"
        print_status "$YELLOW" "💡 Install with: pipx install ansible-lint"
        print_status "$YELLOW" "💡 Or run: pip install --user ansible-lint"
        return 1
    fi
}

# Function to check if .ansible-lint.yml exists
check_lint_config() {
    print_status "$BLUE" "🔍 Checking for ansible-lint configuration..."
    
    if [[ -f "$LINT_CONFIG" ]]; then
        print_status "$GREEN" "✅ Found configuration: .ansible-lint.yml"
        return 0
    else
        print_status "$YELLOW" "⚠️  No .ansible-lint.yml found, using default rules"
        return 0
    fi
}

# Function to find and lint playbooks
lint_playbooks() {
    print_status "$BLUE" "🎭 Linting playbooks..."
    
    local playbook_count=0
    local failed_playbooks=0
    
    # Find all YAML files in playbooks directory
    if [[ -d "$REPO_ROOT/playbooks" ]]; then
        while IFS= read -r -d '' playbook; do
            ((playbook_count++))
            local relative_path="${playbook#$REPO_ROOT/}"
            
            print_status "$BLUE" "  📋 Linting: $relative_path"
            
            local lint_args=()
            if [[ "$FIX_MODE" == "true" ]]; then
                lint_args+=(--fix)
            fi
            if [[ -n "$SPECIFIC_RULES" ]]; then
                lint_args+=(--enable-list="$SPECIFIC_RULES")
            fi
            
            if ansible-lint "${lint_args[@]}" "$playbook" 2>/dev/null; then
                print_status "$GREEN" "    ✅ PASSED"
            else
                print_status "$RED" "    ❌ FAILED"
                ((failed_playbooks++))
                EXIT_CODE=1
            fi
        done < <(find "$REPO_ROOT/playbooks" -name "*.yml" -o -name "*.yaml" -print0)
    fi
    
    if [[ $playbook_count -eq 0 ]]; then
        print_status "$YELLOW" "  ⚠️  No playbooks found in playbooks/ directory"
    else
        print_status "$BLUE" "📊 Playbook Results: $((playbook_count - failed_playbooks))/$playbook_count passed"
    fi
}

# Function to find and lint roles
lint_roles() {
    print_status "$BLUE" "🎭 Linting roles..."
    
    local role_count=0
    local failed_roles=0
    
    # Find all role directories
    if [[ -d "$REPO_ROOT/roles" ]]; then
        while IFS= read -r -d '' role_dir; do
            ((role_count++))
            local role_name=$(basename "$role_dir")
            local relative_path="${role_dir#$REPO_ROOT/}"
            
            print_status "$BLUE" "  🎭 Linting role: $role_name"
            
            local lint_args=()
            if [[ "$FIX_MODE" == "true" ]]; then
                lint_args+=(--fix)
            fi
            if [[ -n "$SPECIFIC_RULES" ]]; then
                lint_args+=(--enable-list="$SPECIFIC_RULES")
            fi
            
            if ansible-lint "${lint_args[@]}" "$role_dir" 2>/dev/null; then
                print_status "$GREEN" "    ✅ PASSED"
            else
                print_status "$RED" "    ❌ FAILED"
                ((failed_roles++))
                EXIT_CODE=1
            fi
        done < <(find "$REPO_ROOT/roles" -mindepth 1 -maxdepth 1 -type d -print0)
    fi
    
    if [[ $role_count -eq 0 ]]; then
        print_status "$YELLOW" "  ⚠️  No roles found in roles/ directory"
    else
        print_status "$BLUE" "📊 Role Results: $((role_count - failed_roles))/$role_count passed"
    fi
}

# Function to lint individual YAML files in root
lint_root_files() {
    print_status "$BLUE" "🎭 Linting root YAML files..."
    
    local file_count=0
    local failed_files=0
    
    # Find YAML files in root directory
    while IFS= read -r -d '' yaml_file; do
        ((file_count++))
        local filename=$(basename "$yaml_file")
        
        # Skip certain files that might not be Ansible content
        case "$filename" in
            ".ansible-lint.yml"|"docker-compose.yml"|"docker-compose.yaml")
                print_status "$YELLOW" "  ⏭️  Skipping: $filename (not Ansible content)"
                ((file_count--))
                continue
                ;;
        esac
        
        print_status "$BLUE" "  📄 Linting: $filename"
        
        local lint_args=()
        if [[ "$FIX_MODE" == "true" ]]; then
            lint_args+=(--fix)
        fi
        if [[ -n "$SPECIFIC_RULES" ]]; then
            lint_args+=(--enable-list="$SPECIFIC_RULES")
        fi
        
        if ansible-lint "${lint_args[@]}" "$yaml_file" 2>/dev/null; then
            print_status "$GREEN" "    ✅ PASSED"
        else
            print_status "$RED" "    ❌ FAILED"
            ((failed_files++))
            EXIT_CODE=1
        fi
    done < <(find "$REPO_ROOT" -maxdepth 1 -name "*.yml" -o -name "*.yaml" -print0)
    
    if [[ $file_count -eq 0 ]]; then
        print_status "$YELLOW" "  ⚠️  No YAML files found in root directory"
    else
        print_status "$BLUE" "📊 Root File Results: $((file_count - failed_files))/$file_count passed"
    fi
}

# Function to show detailed output on failure
show_detailed_output() {
    if [[ $EXIT_CODE -ne 0 ]]; then
        print_status "$RED" "🔍 Running detailed lint check for debugging..."
        print_status "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Run ansible-lint on the entire repository for detailed output
        ansible-lint "$REPO_ROOT" || true
        
        print_status "$YELLOW" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}

# Function to run pre-commit hooks
run_precommit_hooks() {
    print_status "$BLUE" "🔧 Running pre-commit hooks..."
    
    if command -v pre-commit >/dev/null 2>&1; then
        if pre-commit run --all-files; then
            print_status "$GREEN" "✅ Pre-commit hooks passed"
        else
            print_status "$RED" "❌ Pre-commit hooks failed"
            EXIT_CODE=1
        fi
    else
        print_status "$YELLOW" "⚠️  pre-commit not installed, skipping hooks"
        print_status "$YELLOW" "💡 Install with: pip install pre-commit"
    fi
}

# Function to attempt auto-fixes
attempt_auto_fixes() {
    print_status "$BLUE" "🔧 Attempting automatic fixes..."
    
    # Run ansible-lint with --fix
    print_status "$BLUE" "  🎭 Running ansible-lint --fix..."
    if ansible-lint --fix "$REPO_ROOT" 2>/dev/null; then
        print_status "$GREEN" "    ✅ Auto-fixes applied successfully"
    else
        print_status "$YELLOW" "    ⚠️  Some issues require manual intervention"
    fi
    
    # Run yamllint fixes if available
    if command -v yamllint >/dev/null 2>&1; then
        print_status "$BLUE" "  📄 Checking YAML formatting..."
        # yamllint doesn't have auto-fix, but we can suggest fixes
        if ! yamllint "$REPO_ROOT" >/dev/null 2>&1; then
            print_status "$YELLOW" "    ⚠️  YAML formatting issues found (manual fix required)"
        else
            print_status "$GREEN" "    ✅ YAML formatting is correct"
        fi
    fi
}

# Function to show usage help
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Ansible Lint Script for Dotsible Repository
Runs ansible-lint on all playbooks, roles, and YAML files

OPTIONS:
  --help, -h              Show this help message
  --version, -v           Show version information
  --fix                   Attempt to automatically fix linting issues
  --pre-commit            Run pre-commit hooks after linting
  --rules RULES           Enable specific linting rules (comma-separated)
  --exclude PATTERN       Exclude files matching pattern
  --verbose               Enable verbose output
  --strict                Exit with error on any warnings

EXAMPLES:
  $0                      # Run standard linting
  $0 --fix                # Run linting and attempt auto-fixes
  $0 --pre-commit         # Run linting followed by pre-commit hooks
  $0 --rules name[prefix] # Enable specific rules
  $0 --exclude "test_*"   # Exclude test files

ENVIRONMENT VARIABLES:
  ANSIBLE_LINT_CONFIG     Path to custom ansible-lint config
  LINT_VERBOSE           Enable verbose output (true/false)
  LINT_STRICT            Enable strict mode (true/false)

For detailed documentation, see docs/ANSIBLE_LINTING.md
EOF
}

# Main execution
main() {
    print_status "$BLUE" "🚀 Starting Ansible Lint Check"
    print_status "$BLUE" "📁 Repository: $REPO_ROOT"
    echo
    
    # Check prerequisites
    if ! check_ansible_lint; then
        exit 1
    fi
    
    check_lint_config
    echo
    
    # Change to repository root
    cd "$REPO_ROOT"
    
    # Run linting
    lint_playbooks
    echo
    lint_roles
    echo
    lint_root_files
    echo
    
    # Run pre-commit hooks if requested
    if [[ "$RUN_PRECOMMIT" == "true" ]]; then
        echo
        run_precommit_hooks
        echo
    fi
    
    # Attempt auto-fixes if in fix mode and there were errors
    if [[ "$FIX_MODE" == "true" && $EXIT_CODE -ne 0 ]]; then
        echo
        attempt_auto_fixes
        echo
        
        # Re-run linting to check if fixes worked
        print_status "$BLUE" "🔄 Re-running linting after auto-fixes..."
        EXIT_CODE=0  # Reset exit code
        lint_playbooks
        lint_roles
        lint_root_files
        echo
    fi
    
    # Show results
    if [[ $EXIT_CODE -eq 0 ]]; then
        print_status "$GREEN" "🎉 All Ansible content passed linting!"
    else
        print_status "$RED" "💥 Some Ansible content failed linting"
        show_detailed_output
    fi
    
    print_status "$BLUE" "🏁 Ansible lint check completed"
    exit $EXIT_CODE
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_usage
            exit 0
            ;;
        --version|-v)
            echo "lint-ansible.sh v2.0.0"
            echo "Part of Dotsible Ansible automation"
            if command -v ansible-lint >/dev/null 2>&1; then
                echo
                ansible-lint --version
            fi
            if command -v pre-commit >/dev/null 2>&1; then
                echo
                pre-commit --version
            fi
            exit 0
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --pre-commit)
            RUN_PRECOMMIT=true
            shift
            ;;
        --rules)
            SPECIFIC_RULES="$2"
            shift 2
            ;;
        --exclude)
            EXCLUDE_FILES="$2"
            shift 2
            ;;
        --verbose)
            set -x
            shift
            ;;
        --strict)
            # In strict mode, warnings become errors
            export ANSIBLE_LINT_STRICT=true
            shift
            ;;
        "")
            # No arguments, continue to main
            break
            ;;
        *)
            print_status "$RED" "❌ Unknown argument: $1"
            print_status "$YELLOW" "💡 Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main