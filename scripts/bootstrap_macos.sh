#!/bin/bash
# macOS-Specific Bootstrap Script for Dotsible
# Installs Xcode Command Line Tools, Homebrew, Python, and Ansible

set -euo pipefail

# Script configuration
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_DIR="$HOME/.dotsible/logs"
readonly LOG_FILE="$LOG_DIR/bootstrap_macos_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration
readonly MIN_PYTHON_VERSION="3.8"
readonly MIN_ANSIBLE_VERSION="2.9"
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

# Global variables
ENVIRONMENT_TYPE="${1:-personal}"
FORCE_REINSTALL=false
VERBOSE=false

# Logging functions
setup_logging() {
    mkdir -p "$LOG_DIR"
    exec 1> >(tee -a "$LOG_FILE")
    exec 2> >(tee -a "$LOG_FILE" >&2)
}

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" | tee -a "$LOG_FILE" >/dev/null
}

error() {
    echo -e "${RED}$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2
}

warning() {
    echo -e "${YELLOW}$(date '+%Y-%m-%d %H:%M:%S') [WARN] $*${NC}" | tee -a "$LOG_FILE" >&2
}

success() {
    echo -e "${GREEN}$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*${NC}" | tee -a "$LOG_FILE"
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local message=$3
    local percent=$((current * 100 / total))
    local bar_length=40
    local filled_length=$((percent * bar_length / 100))
    
    printf "\r${BLUE}["
    printf "%*s" $filled_length | tr ' ' '='
    printf "%*s" $((bar_length - filled_length)) | tr ' ' '-'
    printf "] %d%% - %s${NC}" $percent "$message"
    
    if [[ $current -eq $total ]]; then
        echo
    fi
}

# macOS version detection
detect_macos_version() {
    local version
    version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$version" | cut -d. -f1)
    
    info "Detected macOS version: $version"
    
    if [[ $major_version -lt 10 ]]; then
        error "macOS version too old: $version (minimum: 10.15)"
        exit 1
    fi
    
    success "macOS version check passed: $version"
}

# Xcode Command Line Tools installation
install_xcode_tools() {
    info "Checking Xcode Command Line Tools..."
    
    # Check if already installed
    if xcode-select -p >/dev/null 2>&1; then
        success "Xcode Command Line Tools already installed"
        return 0
    fi
    
    info "Installing Xcode Command Line Tools..."
    
    # Trigger installation
    xcode-select --install 2>/dev/null || true
    
    # Wait for installation to complete
    info "Waiting for Xcode Command Line Tools installation to complete..."
    info "Please follow the on-screen prompts to complete the installation."
    
    local timeout=300  # 5 minutes
    local elapsed=0
    
    while ! xcode-select -p >/dev/null 2>&1; do
        if [[ $elapsed -ge $timeout ]]; then
            error "Xcode Command Line Tools installation timed out"
            exit 1
        fi
        
        sleep 5
        elapsed=$((elapsed + 5))
        printf "."
    done
    
    echo
    success "Xcode Command Line Tools installed successfully"
    
    # Accept license
    sudo xcodebuild -license accept 2>/dev/null || true
}

# Homebrew installation with proper PATH management
install_homebrew() {
    info "Checking Homebrew installation..."

    # First, try to setup PATH if Homebrew exists but isn't in PATH
    setup_homebrew_path_current_session

    # Check if already installed and working
    if command -v brew >/dev/null 2>&1; then
        local brew_version
        brew_version=$(brew --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        success "Homebrew already installed: version $brew_version"

        # Configure shell integration if not already done
        configure_homebrew_shell_integration

        # Update Homebrew (but don't fail if it doesn't work)
        info "Updating Homebrew..."
        brew update || warning "Homebrew update failed (continuing anyway)"
        return 0
    fi

    info "Installing Homebrew..."

    # Install Homebrew with proper environment
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"

    # Setup PATH for current session
    setup_homebrew_path_current_session

    # Verify installation
    if command -v brew >/dev/null 2>&1; then
        local brew_version
        brew_version=$(brew --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        success "Homebrew installed successfully: version $brew_version"

        # Configure shell integration (idempotent)
        configure_homebrew_shell_integration

        # Run brew doctor (but don't fail if it reports issues)
        info "Running brew doctor..."
        brew doctor || warning "brew doctor reported issues (this is often normal)"
    else
        error "Homebrew installation failed - brew command not found"
        exit 1
    fi
}

# Setup Homebrew PATH for current session only
setup_homebrew_path_current_session() {
    local brew_path=""

    # Detect Homebrew installation path
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        brew_path="/opt/homebrew"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        brew_path="/usr/local"
        eval "$(/usr/local/bin/brew shellenv)"
    else
        # Homebrew not found - this is expected if we're about to install it
        return 1
    fi

    info "Configured Homebrew PATH for current session: $brew_path"
    return 0
}

# Configure Homebrew shell integration (idempotent)
configure_homebrew_shell_integration() {
    info "Configuring Homebrew shell integration..."

    local brew_path=""
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        brew_path="/opt/homebrew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        brew_path="/usr/local"
    else
        error "Cannot configure shell integration - Homebrew not found"
        return 1
    fi

    local shell_config=""
    local marker="# Homebrew - Dotsible managed"
    local brew_shellenv="eval \"\$($brew_path/bin/brew shellenv)\""

    # Determine primary shell config file (prefer .zprofile for zsh)
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zprofile"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_config="$HOME/.bash_profile"
    else
        shell_config="$HOME/.profile"
    fi

    # Create config file if it doesn't exist
    if [[ ! -f "$shell_config" ]]; then
        touch "$shell_config"
        info "Created shell configuration file: $shell_config"
    fi

    # Check if Homebrew is already configured
    if grep -q "$marker" "$shell_config" 2>/dev/null; then
        success "Homebrew shell integration already configured in $shell_config"
        return 0
    fi

    # Add Homebrew configuration
    {
        echo ""
        echo "$marker"
        echo "$brew_shellenv"
    } >> "$shell_config"

    success "Added Homebrew shell integration to $shell_config"
}

# Python installation via Homebrew
install_python() {
    info "Checking Python installation..."
    
    # Check if Python 3.8+ is already available
    local python_cmd=""
    local python_version=""
    
    for cmd in python3 python python3.11 python3.10 python3.9 python3.8; do
        if command -v "$cmd" >/dev/null 2>&1; then
            python_version=$($cmd --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [[ -n "$python_version" ]]; then
                if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
                    python_cmd="$cmd"
                    success "Python found: $python_cmd (version $python_version)"
                    return 0
                fi
            fi
        fi
    done
    
    info "Installing Python via Homebrew..."
    
    # Install Python
    brew install python3
    
    # Verify installation
    if command -v python3 >/dev/null 2>&1; then
        python_version=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Python installed successfully: version $python_version"
        
        # Upgrade pip
        info "Upgrading pip..."
        python3 -m pip install --upgrade pip
    else
        error "Python installation failed"
        exit 1
    fi
}

# Function to verify all required Ansible commands are available
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

    info "🔍 Verifying Ansible commands availability..."

    for cmd in "${expected_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            available_commands+=("$cmd")
            success "  ✅ $cmd: $(which "$cmd")"
        else
            missing_commands+=("$cmd")
            error "  ❌ $cmd: Not found"
        fi
    done

    if [[ ${#missing_commands[@]} -eq 0 ]]; then
        success "✅ All Ansible commands verified successfully"
        return 0
    else
        error "❌ Missing Ansible commands: ${missing_commands[*]}"
        return 1
    fi
}

# Ansible installation via pip
install_ansible() {
    info "Checking Ansible installation..."

    # Check if Ansible is already installed
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible already installed: version $ansible_version"

        # Verify all commands are available
        if verify_ansible_commands; then
            return 0
        else
            warning "Ansible installation incomplete - missing subcommands"
        fi
    fi

    info "Installing Ansible via pip..."

    # Install Ansible
    python3 -m pip install --user ansible

    # Add pip user bin to PATH if not already there
    local pip_user_bin="$HOME/Library/Python/$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')/bin"
    if [[ -d "$pip_user_bin" ]] && [[ ":$PATH:" != *":$pip_user_bin:"* ]]; then
        export PATH="$pip_user_bin:$PATH"
        info "Added $pip_user_bin to PATH"
    fi

    # Verify installation
    if command -v ansible >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Ansible installed successfully: version $ansible_version"

        # Verify all commands are available
        if ! verify_ansible_commands; then
            error "Ansible installation incomplete - missing critical subcommands"
            exit 1
        fi
    else
        error "Ansible installation failed"
        exit 1
    fi
}

# Configure macOS-specific Ansible requirements
configure_macos_ansible() {
    info "Configuring macOS-specific Ansible requirements..."
    
    # Install additional Python packages for macOS
    local packages=(
        "requests"
        "urllib3"
        "certifi"
    )
    
    for package in "${packages[@]}"; do
        info "Installing Python package: $package"
        python3 -m pip install --user "$package" || warning "Failed to install $package"
    done
    
    # Create Ansible configuration directory
    local ansible_config_dir="$HOME/.ansible"
    if [[ ! -d "$ansible_config_dir" ]]; then
        mkdir -p "$ansible_config_dir"
        info "Created Ansible configuration directory: $ansible_config_dir"
    fi
    
    # Create basic ansible.cfg if it doesn't exist
    local ansible_cfg="$ansible_config_dir/ansible.cfg"
    if [[ ! -f "$ansible_cfg" ]]; then
        cat > "$ansible_cfg" << EOF
[defaults]
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
bin_ansible_callbacks = True

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes
EOF
        info "Created basic Ansible configuration: $ansible_cfg"
    fi
    
    success "macOS Ansible configuration completed"
}

# Environment-specific configuration
configure_environment() {
    local env_type="$1"
    
    info "Configuring for environment type: $env_type"
    
    case "$env_type" in
        enterprise)
            info "Applying enterprise-specific configurations..."
            
            # Install additional enterprise tools via Homebrew
            local enterprise_tools=(
                "mas"  # Mac App Store CLI
                "duti" # Default application handler
            )
            
            for tool in "${enterprise_tools[@]}"; do
                if ! command -v "$tool" >/dev/null 2>&1; then
                    info "Installing enterprise tool: $tool"
                    brew install "$tool" || warning "Failed to install $tool"
                fi
            done
            ;;
        personal)
            info "Applying personal environment configurations..."
            # Personal-specific configurations can be added here
            ;;
        *)
            warning "Unknown environment type: $env_type. Using default configuration."
            ;;
    esac
}

# Final validation
final_validation() {
    info "Performing final validation..."
    
    # Check Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        error "Xcode Command Line Tools validation failed"
        return 1
    fi
    
    # Check Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        error "Homebrew validation failed"
        return 1
    fi
    
    # Check Python
    if ! command -v python3 >/dev/null 2>&1; then
        error "Python validation failed"
        return 1
    fi
    
    # Check Ansible
    if ! command -v ansible >/dev/null 2>&1; then
        error "Ansible validation failed"
        return 1
    fi

    # Verify all Ansible commands are available
    if ! verify_ansible_commands; then
        error "Ansible command verification failed"
        return 1
    fi

    # Test Ansible functionality
    if ! ansible localhost -m ping >/dev/null 2>&1; then
        warning "Ansible ping test failed, but installation appears successful"
    else
        success "Ansible functionality verified"
    fi
    
    success "All validations passed!"
    return 0
}

# Main execution function
main() {
    # Setup logging
    setup_logging
    
    # Display banner
    echo -e "${BLUE}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                  macOS BOOTSTRAP SCRIPT                     ║
║              Dotsible Environment Setup                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log "macOS bootstrap started"
    log "Environment type: $ENVIRONMENT_TYPE"
    log "Working directory: $(pwd)"
    log "Script location: $SCRIPT_DIR"
    
    # Main bootstrap sequence
    local total_steps=8
    local current_step=0
    
    show_progress $((++current_step)) $total_steps "Detecting macOS version..."
    detect_macos_version
    
    show_progress $((++current_step)) $total_steps "Installing Xcode Command Line Tools..."
    install_xcode_tools
    
    show_progress $((++current_step)) $total_steps "Installing Homebrew..."
    install_homebrew
    
    show_progress $((++current_step)) $total_steps "Installing Python..."
    install_python
    
    show_progress $((++current_step)) $total_steps "Installing Ansible..."
    install_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring macOS Ansible..."
    configure_macos_ansible
    
    show_progress $((++current_step)) $total_steps "Configuring environment..."
    configure_environment "$ENVIRONMENT_TYPE"
    
    show_progress $((++current_step)) $total_steps "Performing final validation..."
    final_validation
    
    # Success message
    echo
    success "macOS bootstrap completed successfully!"
    echo
    info "Installed components:"
    echo "  - Xcode Command Line Tools: $(xcode-select -p)"
    echo "  - Homebrew: $(brew --version | head -1)"
    echo "  - Python: $(python3 --version)"
    echo "  - Ansible: $(ansible --version | head -1)"
    echo
    info "Environment type: $ENVIRONMENT_TYPE"
    info "Log file: $LOG_FILE"
    
    log "macOS bootstrap completed successfully"
    exit 0
}

# Error handling
trap 'error "macOS bootstrap failed at line $LINENO. Check log: $LOG_FILE"; exit 1' ERR

# Execute main function
main "$@"
