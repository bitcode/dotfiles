#!/bin/bash
# Dotsible Pre-Run Validation Script
# Validates system readiness before running Dotsible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTSIBLE_ROOT="$(dirname "$SCRIPT_DIR")"
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_CHECKS=0

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    VALIDATION_WARNINGS=$((VALIDATION_WARNINGS + 1))
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

check() {
    local name="$1"
    local command="$2"
    local required="${3:-true}"
    
    VALIDATION_CHECKS=$((VALIDATION_CHECKS + 1))
    
    if eval "$command" >/dev/null 2>&1; then
        success "✓ $name"
        return 0
    else
        if [ "$required" = "true" ]; then
            error "✗ $name (Required)"
            return 1
        else
            warning "⚠ $name (Optional)"
            return 0
        fi
    fi
}

# Function to detect OS and architecture
detect_system() {
    header "System Detection"
    
    log "Operating System: $(uname -s)"
    log "Architecture: $(uname -m)"
    log "Kernel: $(uname -r)"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            log "Distribution: $PRETTY_NAME"
            log "Version: $VERSION_ID"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log "macOS Version: $(sw_vers -productVersion)"
    fi
    
    log "Shell: $SHELL"
    log "User: $(whoami)"
    log "Home: $HOME"
}

# Function to validate prerequisites
validate_prerequisites() {
    header "Prerequisites Validation"
    
    # Check Python
    check "Python 3" "command -v python3"
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        log "Python version: $PYTHON_VERSION"
        check "Python 3.6+" "python3 -c 'import sys; exit(0 if sys.version_info >= (3, 6) else 1)'"
    fi
    
    # Check Ansible
    check "Ansible" "command -v ansible"
    check "Ansible Playbook" "command -v ansible-playbook"
    if command -v ansible >/dev/null 2>&1; then
        ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
        log "Ansible version: $ANSIBLE_VERSION"
    fi
    
    # Check Git
    check "Git" "command -v git"
    if command -v git >/dev/null 2>&1; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        log "Git version: $GIT_VERSION"
    fi
    
    # Check SSH
    check "SSH Client" "command -v ssh" false
    
    # Check sudo/admin privileges
    if [[ "$OSTYPE" != "darwin"* ]]; then
        check "Sudo access" "sudo -n true" false
    fi
}

# Function to validate Dotsible structure
validate_structure() {
    header "Dotsible Structure Validation"
    
    # Check main files
    check "Main playbook (site.yml)" "[ -f '$DOTSIBLE_ROOT/site.yml' ]"
    check "Ansible configuration" "[ -f '$DOTSIBLE_ROOT/ansible.cfg' ]"
    check "Requirements file" "[ -f '$DOTSIBLE_ROOT/requirements.yml' ]" false
    
    # Check directories
    check "Inventories directory" "[ -d '$DOTSIBLE_ROOT/inventories' ]"
    check "Roles directory" "[ -d '$DOTSIBLE_ROOT/roles' ]"
    check "Group vars directory" "[ -d '$DOTSIBLE_ROOT/group_vars' ]"
    check "Playbooks directory" "[ -d '$DOTSIBLE_ROOT/playbooks' ]" false
    
    # Check key files
    check "Local inventory" "[ -f '$DOTSIBLE_ROOT/inventories/local/hosts.yml' ]"
    check "Package definitions" "[ -f '$DOTSIBLE_ROOT/group_vars/all/packages.yml' ]"
    check "Profile definitions" "[ -f '$DOTSIBLE_ROOT/group_vars/all/profiles.yml' ]"
    
    # Check roles
    for role in common package_manager dotfiles; do
        check "Role: $role" "[ -d '$DOTSIBLE_ROOT/roles/$role' ]"
    done
}

# Function to validate configuration syntax
validate_syntax() {
    header "Configuration Syntax Validation"
    
    # Check main playbook syntax
    check "Main playbook syntax" "ansible-playbook --syntax-check '$DOTSIBLE_ROOT/site.yml'"
    
    # Check inventory syntax
    check "Local inventory syntax" "ansible-inventory -i '$DOTSIBLE_ROOT/inventories/local/hosts.yml' --list >/dev/null"
    
    # Check YAML files
    for yaml_file in "$DOTSIBLE_ROOT/group_vars/all"/*.yml; do
        if [ -f "$yaml_file" ]; then
            filename=$(basename "$yaml_file")
            check "YAML: $filename" "python3 -c 'import yaml; yaml.safe_load(open(\"$yaml_file\"))'"
        fi
    done
    
    # Check role syntax
    for role_dir in "$DOTSIBLE_ROOT/roles"/*; do
        if [ -d "$role_dir" ]; then
            role_name=$(basename "$role_dir")
            if [ -f "$role_dir/tasks/main.yml" ]; then
                check "Role syntax: $role_name" "python3 -c 'import yaml; yaml.safe_load(open(\"$role_dir/tasks/main.yml\"))'"
            fi
        fi
    done
}

# Function to validate system compatibility
validate_compatibility() {
    header "System Compatibility Validation"
    
    # Detect OS for compatibility check
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS_ID=$ID
        else
            OS_ID="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_ID="macos"
    else
        OS_ID="unknown"
    fi
    
    log "Detected OS ID: $OS_ID"
    
    # Check if OS is supported
    case $OS_ID in
        ubuntu|debian|archlinux|macos)
            success "✓ Operating system is supported"
            ;;
        *)
            warning "⚠ Operating system may not be fully supported"
            ;;
    esac
    
    # Check package manager availability
    case $OS_ID in
        ubuntu|debian)
            check "APT package manager" "command -v apt"
            ;;
        archlinux)
            check "Pacman package manager" "command -v pacman"
            ;;
        macos)
            check "Homebrew package manager" "command -v brew" false
            if ! command -v brew >/dev/null 2>&1; then
                warning "Homebrew not found. Some packages may not install correctly."
            fi
            ;;
    esac
    
    # Check disk space
    AVAILABLE_SPACE=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE_SPACE" -gt 1048576 ]; then  # 1GB in KB
        success "✓ Sufficient disk space available"
    else
        warning "⚠ Low disk space. Consider freeing up space before running Dotsible."
    fi
    
    # Check network connectivity
    check "Network connectivity" "ping -c 1 8.8.8.8" false
}

# Function to validate permissions
validate_permissions() {
    header "Permissions Validation"
    
    # Check home directory permissions
    check "Home directory writable" "[ -w '$HOME' ]"
    
    # Check if we can create directories
    check "Can create directories" "mkdir -p '$HOME/.dotsible/test' && rmdir '$HOME/.dotsible/test'"
    
    # Check SSH directory permissions
    if [ -d "$HOME/.ssh" ]; then
        SSH_PERMS=$(stat -c "%a" "$HOME/.ssh" 2>/dev/null || stat -f "%A" "$HOME/.ssh" 2>/dev/null)
        if [ "$SSH_PERMS" = "700" ]; then
            success "✓ SSH directory permissions correct"
        else
            warning "⚠ SSH directory permissions should be 700 (currently $SSH_PERMS)"
        fi
    fi
    
    # Check if we need sudo for package installation
    if [[ "$OSTYPE" != "darwin"* ]]; then
        if sudo -n true 2>/dev/null; then
            success "✓ Sudo access available"
        else
            warning "⚠ Sudo access may be required for package installation"
            log "You may be prompted for your password during installation"
        fi
    fi
}

# Function to validate environment
validate_environment() {
    header "Environment Validation"
    
    # Check environment variables
    check "HOME variable set" "[ -n '$HOME' ]"
    check "PATH variable set" "[ -n '$PATH' ]"
    check "USER variable set" "[ -n '$USER' ]" false
    
    # Check shell
    if [ -n "$SHELL" ]; then
        success "✓ Shell: $SHELL"
        check "Shell executable" "[ -x '$SHELL' ]"
    else
        warning "⚠ SHELL variable not set"
    fi
    
    # Check locale
    if command -v locale >/dev/null 2>&1; then
        LOCALE=$(locale | grep LANG= | cut -d= -f2)
        if [ -n "$LOCALE" ]; then
            success "✓ Locale: $LOCALE"
        else
            warning "⚠ Locale not properly set"
        fi
    fi
    
    # Check timezone
    if [ -f /etc/timezone ]; then
        TIMEZONE=$(cat /etc/timezone)
        success "✓ Timezone: $TIMEZONE"
    elif command -v timedatectl >/dev/null 2>&1; then
        TIMEZONE=$(timedatectl show --property=Timezone --value)
        success "✓ Timezone: $TIMEZONE"
    fi
}

# Function to generate validation report
generate_report() {
    local report_file="$DOTSIBLE_ROOT/validation_report.txt"
    
    cat > "$report_file" << EOF
Dotsible Pre-Run Validation Report
=================================

Validation Date: $(date)
Host: $(hostname)
User: $(whoami)
OS: $(uname -s) $(uname -r)
Architecture: $(uname -m)

VALIDATION SUMMARY:
==================
Total Checks: $VALIDATION_CHECKS
Errors: $VALIDATION_ERRORS
Warnings: $VALIDATION_WARNINGS
Success Rate: $(( (VALIDATION_CHECKS - VALIDATION_ERRORS) * 100 / VALIDATION_CHECKS ))%

STATUS: $([ $VALIDATION_ERRORS -eq 0 ] && echo "✅ READY FOR DEPLOYMENT" || echo "❌ ISSUES REQUIRE ATTENTION")

$([ $VALIDATION_ERRORS -gt 0 ] && echo "
CRITICAL ISSUES:
===============
$VALIDATION_ERRORS error(s) found that must be resolved before running Dotsible.
Please check the validation output above for specific issues.
")

$([ $VALIDATION_WARNINGS -gt 0 ] && echo "
WARNINGS:
========
$VALIDATION_WARNINGS warning(s) found. These are not critical but should be reviewed.
")

RECOMMENDATIONS:
===============
$([ $VALIDATION_ERRORS -eq 0 ] && echo "✅ System is ready for Dotsible deployment
✅ All critical requirements are met
✅ You can proceed with running Dotsible" || echo "🔧 Fix the critical errors listed above
🔧 Re-run validation after fixes
🔧 Consider running ./scripts/bootstrap.sh if dependencies are missing")

$([ $VALIDATION_WARNINGS -gt 0 ] && echo "
📋 Review warnings and consider addressing them
📋 Some features may not work optimally with warnings present
")

NEXT STEPS:
==========
$([ $VALIDATION_ERRORS -eq 0 ] && echo "1. ✅ Run Dotsible with your preferred profile:
   ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=minimal

2. ✅ Or test with dry-run first:
   ansible-playbook -i inventories/local/hosts.yml site.yml --check

3. ✅ Monitor the execution and check logs in /var/log/ansible/" || echo "1. 🔧 Address the critical errors listed above
2. 🔧 Run ./scripts/bootstrap.sh if dependencies are missing
3. 🔧 Re-run this validation script
4. 🔧 Proceed with Dotsible once validation passes")

Generated by Dotsible Validation Framework
EOF

    log "Validation report saved to: $report_file"
}

# Main validation function
main() {
    header "Dotsible Pre-Run Validation"
    log "Starting comprehensive system validation..."
    log "Working directory: $DOTSIBLE_ROOT"
    
    # Run all validation checks
    detect_system
    validate_prerequisites
    validate_structure
    validate_syntax
    validate_compatibility
    validate_permissions
    validate_environment
    
    # Generate report
    generate_report
    
    # Final summary
    header "Validation Summary"
    log "Total checks: $VALIDATION_CHECKS"
    log "Errors: $VALIDATION_ERRORS"
    log "Warnings: $VALIDATION_WARNINGS"
    
    if [ $VALIDATION_ERRORS -eq 0 ]; then
        success "🎉 Validation passed! System is ready for Dotsible."
        if [ $VALIDATION_WARNINGS -gt 0 ]; then
            warning "Note: $VALIDATION_WARNINGS warning(s) found. Review recommended."
        fi
        log "You can now run: ansible-playbook -i inventories/local/hosts.yml site.yml"
        exit 0
    else
        error "❌ Validation failed with $VALIDATION_ERRORS error(s)."
        log "Please fix the issues above and re-run validation."
        log "Consider running ./scripts/bootstrap.sh to install missing dependencies."
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Dotsible Pre-Run Validation Script"
        echo ""
        echo "This script validates your system before running Dotsible by checking:"
        echo "  - Prerequisites (Python, Ansible, Git)"
        echo "  - Dotsible structure and configuration"
        echo "  - System compatibility and permissions"
        echo "  - Environment setup"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --quick             Run only essential checks"
        echo "  --prerequisites     Check only prerequisites"
        echo "  --structure         Check only Dotsible structure"
        echo "  --syntax            Check only configuration syntax"
        echo "  --compatibility     Check only system compatibility"
        echo ""
        exit 0
        ;;
    --quick)
        log "Running quick validation..."
        detect_system
        validate_prerequisites
        validate_structure
        generate_report
        ;;
    --prerequisites)
        validate_prerequisites
        ;;
    --structure)
        validate_structure
        ;;
    --syntax)
        validate_syntax
        ;;
    --compatibility)
        validate_compatibility
        ;;
    "")
        main
        ;;
    *)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac