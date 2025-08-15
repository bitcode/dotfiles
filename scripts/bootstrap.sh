
#!/bin/bash
# Dotsible Bootstrap Script
# Initial system setup and dependency installation

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
PYTHON_MIN_VERSION="3.6"
ANSIBLE_MIN_VERSION="2.9"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS=$ID
            OS_VERSION=$VERSION_ID
        elif [ -f /etc/redhat-release ]; then
            OS="rhel"
        elif [ -f /etc/debian_version ]; then
            OS="debian"
        else
            OS="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        OS_VERSION=$(sw_vers -productVersion)
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
    else
        OS="unknown"
    fi
    
    log "Detected OS: $OS $OS_VERSION"
}

# Function to check Python version
check_python() {
    header "Checking Python Installation"
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        log "Found Python $PYTHON_VERSION"
        
        # Compare versions
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 6) else 1)"; then
            success "Python version is compatible"
            return 0
        else
            error "Python version $PYTHON_VERSION is too old. Minimum required: $PYTHON_MIN_VERSION"
            return 1
        fi
    else
        error "Python 3 not found"
        return 1
    fi
}

# Function to install Python (OS-specific)
install_python() {
    header "Installing Python"
    
    case $OS in
        ubuntu|debian)
            log "Installing Python via APT..."
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv
            ;;
        archlinux)
            log "Installing Python via Pacman..."
            sudo pacman -Sy --noconfirm python python-pip
            ;;
        macos)
            if command -v brew &> /dev/null; then
                log "Installing Python via Homebrew..."
                brew install python
            else
                error "Homebrew not found. Please install Homebrew first or install Python manually."
                return 1
            fi
            ;;
        rhel|centos|fedora)
            log "Installing Python via YUM/DNF..."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y python3 python3-pip
            else
                sudo yum install -y python3 python3-pip
            fi
            ;;
        *)
            error "Unsupported OS for automatic Python installation: $OS"
            log "Please install Python 3.6+ manually"
            return 1
            ;;
    esac
}

# Function to check Ansible installation
check_ansible() {
    header "Checking Ansible Installation"
    
    if command -v ansible &> /dev/null; then
        ANSIBLE_VERSION=$(ansible --version | head -n1 | cut -d' ' -f2)
        log "Found Ansible $ANSIBLE_VERSION"
        
        # Basic version check (simplified)
        if [[ "$ANSIBLE_VERSION" > "$ANSIBLE_MIN_VERSION" ]] || [[ "$ANSIBLE_VERSION" == "$ANSIBLE_MIN_VERSION" ]]; then
            success "Ansible version is compatible"
            return 0
        else
            warning "Ansible version $ANSIBLE_VERSION might be too old. Recommended: $ANSIBLE_MIN_VERSION+"
            return 0  # Don't fail, just warn
        fi
    else
        error "Ansible not found"
        return 1
    fi
}

# Function to install Ansible
install_ansible() {
    header "Installing Ansible"
    
    log "Installing Ansible via pip..."
    
    # Try to install in user space first
    if python3 -m pip install --user ansible; then
        success "Ansible installed successfully"
        
        # Add user bin to PATH if not already there
        USER_BIN="$HOME/.local/bin"
        if [[ ":$PATH:" != *":$USER_BIN:"* ]] && [ -d "$USER_BIN" ]; then
            warning "Adding $USER_BIN to PATH for this session"
            export PATH="$USER_BIN:$PATH"
            
            # Suggest adding to shell profile
            log "Consider adding this to your shell profile:"
            log "export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
    else
        warning "User installation failed, trying system-wide installation..."
        if sudo python3 -m pip install ansible; then
            success "Ansible installed system-wide"
        else
            error "Failed to install Ansible"
            return 1
        fi
    fi
}

# Function to install additional dependencies
install_dependencies() {
    header "Installing Additional Dependencies"
    
    # Install requirements from requirements.txt if it exists
    if [ -f "$DOTSIBLE_ROOT/requirements.txt" ]; then
        log "Installing Python requirements..."
        python3 -m pip install --user -r "$DOTSIBLE_ROOT/requirements.txt"
    fi
    
    # Install Ansible Galaxy requirements
    if [ -f "$DOTSIBLE_ROOT/requirements.yml" ]; then
        log "Installing Ansible Galaxy requirements..."
        ansible-galaxy collection install -r "$DOTSIBLE_ROOT/requirements.yml"
        # If you later add roles to the same file:
        # ansible-galaxy role install -r "$DOTSIBLE_ROOT/requirements.yml"
    fi
    
    # Install OS-specific dependencies
    case $OS in
        ubuntu|debian)
            log "Installing system dependencies for Debian/Ubuntu..."
            sudo apt install -y git curl wget openssh-client
            ;;
        archlinux)
            log "Installing system dependencies for Arch Linux..."
            sudo pacman -S --noconfirm git curl wget openssh
            ;;
        macos)
            log "Installing system dependencies for macOS..."
            # Most dependencies should be available or installable via Homebrew
            if command -v brew &> /dev/null; then
                brew install git curl wget
            fi
            ;;
        *)
            log "Skipping OS-specific dependencies for $OS"
            ;;
    esac
}

# Function to setup SSH key (optional)
setup_ssh_key() {
    header "SSH Key Setup (Optional)"
    
    if [ ! -f "$HOME/.ssh/id_rsa" ] && [ ! -f "$HOME/.ssh/id_ed25519" ]; then
        read -p "No SSH key found. Generate one? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log "Generating SSH key..."
            ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$HOME/.ssh/id_ed25519" -N ""
            success "SSH key generated: $HOME/.ssh/id_ed25519"
            log "Public key:"
            cat "$HOME/.ssh/id_ed25519.pub"
        fi
    else
        success "SSH key already exists"
    fi
}

# Function to create initial configuration
create_initial_config() {
    header "Creating Initial Configuration"
    
    # Create local inventory if it doesn't exist
    LOCAL_INVENTORY="$DOTSIBLE_ROOT/inventories/local/hosts.yml"
    if [ ! -f "$LOCAL_INVENTORY" ]; then
        log "Creating local inventory..."
        mkdir -p "$(dirname "$LOCAL_INVENTORY")"
        cat > "$LOCAL_INVENTORY" << EOF
---
# Local machine inventory
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
  vars:
    # Default profile
    profile: minimal
    
    # Enable dotfiles management
    dotfiles_enabled: true
    
    # Backup existing configurations
    backup_existing: true
    
    # Skip interactive prompts
    skip_interactive: false
EOF
        success "Created local inventory: $LOCAL_INVENTORY"
    else
        log "Local inventory already exists"
    fi
    
    # Create logs directory
    mkdir -p "$DOTSIBLE_ROOT/logs"
    
    # Create backup directory
    mkdir -p "$HOME/.dotsible/backups"
}

# Function to run basic validation
run_validation() {
    header "Running Basic Validation"
    
    # Test Ansible installation
    log "Testing Ansible installation..."
    if ansible --version > /dev/null; then
        success "Ansible is working"
    else
        error "Ansible test failed"
        return 1
    fi
    
    # Test playbook syntax
    log "Testing main playbook syntax..."
    if ansible-playbook --syntax-check "$DOTSIBLE_ROOT/site.yml" > /dev/null; then
        success "Main playbook syntax is valid"
    else
        error "Main playbook has syntax errors"
        return 1
    fi
    
    # Test inventory
    log "Testing local inventory..."
    if ansible-inventory -i "$DOTSIBLE_ROOT/inventories/local/hosts.yml" --list > /dev/null; then
        success "Local inventory is valid"
    else
        error "Local inventory has errors"
        return 1
    fi
}

# Function to display next steps
show_next_steps() {
    header "Bootstrap Complete!"
    
    success "Dotsible is ready to use!"
    echo
    log "Next steps:"
    echo "  1. Review and customize your configuration:"
    echo "     - Edit inventories/local/hosts.yml"
    echo "     - Customize group_vars/all/profiles.yml"
    echo "     - Review group_vars/all/packages.yml"
    echo
    echo "  2. Run Dotsible with your preferred profile:"
    echo "     ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=minimal"
    echo "     ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer"
    echo
    echo "  3. Test your setup:"
    echo "     ansible-playbook -i inventories/local/hosts.yml site.yml --check"
    echo
    echo "  4. Run validation tests:"
    echo "     ./tests/scripts/validate_syntax.sh"
    echo "     ./tests/scripts/run_all_tests.sh"
    echo
    log "For more information, see:"
    echo "  - README.md"
    echo "  - docs/SETUP.md"
    echo "  - docs/USAGE.md"
}

# Main bootstrap function
main() {
    header "Dotsible Bootstrap"
    log "Starting system bootstrap..."
    log "Working directory: $DOTSIBLE_ROOT"
    
    # Detect operating system
    detect_os
    
    # Check and install Python
    if ! check_python; then
        log "Python installation required"
        install_python
        check_python || { error "Python installation failed"; exit 1; }
    fi
    
    # Check and install Ansible
    if ! check_ansible; then
        log "Ansible installation required"
        install_ansible
        check_ansible || { error "Ansible installation failed"; exit 1; }
    fi
    
    # Install additional dependencies
    install_dependencies
    
    # Setup SSH key (optional)
    setup_ssh_key
    
    # Create initial configuration
    create_initial_config
    
    # Run validation
    run_validation
    
    # Show next steps
    show_next_steps
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Dotsible Bootstrap Script"
        echo ""
        echo "This script prepares your system for Dotsible by:"
        echo "  - Installing Python and Ansible"
        echo "  - Installing required dependencies"
        echo "  - Creating initial configuration"
        echo "  - Running basic validation"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h        Show this help message"
        echo "  --check-only      Only check prerequisites, don't install"
        echo "  --skip-ssh        Skip SSH key setup"
        echo "  --minimal         Minimal installation (skip optional components)"
        echo ""
        exit 0
        ;;
    --check-only)
        header "Prerequisites Check"
        detect_os
        check_python && success "Python: OK" || error "Python: Missing"
        check_ansible && success "Ansible: OK" || error "Ansible: Missing"
        exit 0
        ;;
    --skip-ssh)
        log "Skipping SSH key setup"
        setup_ssh_key() { log "SSH key setup skipped"; }
        main
        ;;
    --minimal)
        log "Minimal installation mode"
        install_dependencies() { log "Skipping additional dependencies"; }
        setup_ssh_key() { log "Skipping SSH key setup"; }
        main
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

# Add pip user scripts dir to PATH for this session
USER_BASE="$(python3 -m site --user-base 2>/dev/null)"
USER_BIN="$USER_BASE/bin"
if [ -n "$USER_BIN" ] && [ -d "$USER_BIN" ] && [[ ":$PATH:" != *":$USER_BIN:"* ]]; then
    warning "Adding $USER_BIN to PATH for this session"
    export PATH="$USER_BIN:$PATH"
    log "Consider adding this to your shell profile (e.g. ~/.zprofile or ~/.zshrc):"
    log "export PATH=\"$USER_BIN:\$PATH\""
fi
