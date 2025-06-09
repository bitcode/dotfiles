#!/bin/bash
# macOS-Specific Bootstrap Script for Dotsible
set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

# Logging
LOG_DIR="$HOME/.dotsible/logs"
LOG_FILE="$LOG_DIR/bootstrap_macos_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$LOG_DIR"

log() { echo "$(date) [INFO] $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}$(date) [ERROR] $*${NC}" | tee -a "$LOG_FILE" >&2; }
success() { echo -e "${GREEN}$(date) [SUCCESS] $*${NC}" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}$(date) [INFO] $*${NC}" | tee -a "$LOG_FILE"; }
warning() { echo -e "\033[0;33m$(date) [WARNING] $*${NC}" | tee -a "$LOG_FILE"; }

ENVIRONMENT_TYPE="${1:-personal}"
TARGET_PYTHON_VERSION="3.13.4"
REQUIRED_PYTHON_MAJOR_MINOR="3.13"

# Function to manage Python version - upgrade to Python 3.13.4
manage_python_version() {
    info "🐍 Managing Python version..."

    # Check current Python versions
    local system_python_version=""
    local homebrew_python_version=""
    local current_python_path=""

    if command -v python3 >/dev/null 2>&1; then
        system_python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        current_python_path=$(which python3)
        info "Current Python: $system_python_version at $current_python_path"
    fi

    # Check if we already have the target version
    if [[ "$system_python_version" == "$TARGET_PYTHON_VERSION"* ]]; then
        success "Python $TARGET_PYTHON_VERSION already installed and active"
        return 0
    fi

    # Install Python 3.13 via Homebrew if not present
    if ! brew list python@3.13 >/dev/null 2>&1; then
        info "Installing Python 3.13 via Homebrew..."
        brew install python@3.13
    else
        info "Python 3.13 already installed via Homebrew"
        # Ensure it's up to date
        brew upgrade python@3.13 2>/dev/null || true
    fi

    # Get Homebrew Python path
    local homebrew_python_path=""
    if [[ -f "/opt/homebrew/bin/python3.13" ]]; then
        # Apple Silicon
        homebrew_python_path="/opt/homebrew/bin/python3.13"
    elif [[ -f "/usr/local/bin/python3.13" ]]; then
        # Intel Mac
        homebrew_python_path="/usr/local/bin/python3.13"
    else
        error "Could not find Homebrew Python 3.13 installation"
        return 1
    fi

    homebrew_python_version=$($homebrew_python_path --version 2>&1 | cut -d' ' -f2)
    info "Homebrew Python: $homebrew_python_version at $homebrew_python_path"

    # Update shell configuration to prioritize Homebrew Python
    update_python_path_configuration "$homebrew_python_path"

    # Create/update symlinks for python3 and pip3
    create_python_symlinks "$homebrew_python_path"

    # Verify the installation
    verify_python_installation

    # Migrate existing packages if needed
    migrate_python_packages "$current_python_path" "$homebrew_python_path"

    success "Python version management completed"
}

# Function to update shell configuration for Python PATH
update_python_path_configuration() {
    local python_path="$1"
    local python_bin_dir=$(dirname "$python_path")

    info "Updating shell configuration for Python PATH..."

    # Determine the correct Homebrew path based on architecture
    local homebrew_path=""
    if [[ -d "/opt/homebrew" ]]; then
        homebrew_path="/opt/homebrew"
    else
        homebrew_path="/usr/local"
    fi

    # Update .zshrc
    local zshrc="$HOME/.zshrc"
    if [[ ! -f "$zshrc" ]]; then
        touch "$zshrc"
    fi

    # Remove old Python PATH entries
    sed -i.bak '/# Python PATH - Dotsible managed/,/# End Python PATH/d' "$zshrc" 2>/dev/null || true

    # Add new Python PATH configuration
    cat >> "$zshrc" << EOF

# Python PATH - Dotsible managed
export PATH="$homebrew_path/opt/python@3.13/bin:\$PATH"
export PATH="$homebrew_path/bin:\$PATH"
# End Python PATH
EOF

    # Update .bashrc if it exists
    local bashrc="$HOME/.bashrc"
    if [[ -f "$bashrc" ]]; then
        sed -i.bak '/# Python PATH - Dotsible managed/,/# End Python PATH/d' "$bashrc" 2>/dev/null || true
        cat >> "$bashrc" << EOF

# Python PATH - Dotsible managed
export PATH="$homebrew_path/opt/python@3.13/bin:\$PATH"
export PATH="$homebrew_path/bin:\$PATH"
# End Python PATH
EOF
    fi

    # Update current session PATH
    export PATH="$homebrew_path/opt/python@3.13/bin:$PATH"
    export PATH="$homebrew_path/bin:$PATH"

    success "Shell configuration updated for Python $TARGET_PYTHON_VERSION"
}

# Function to create Python symlinks
create_python_symlinks() {
    local python_path="$1"
    local python_bin_dir=$(dirname "$python_path")

    info "Creating Python symlinks..."

    # Create local bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create symlinks in ~/.local/bin (which should be in PATH)
    ln -sf "$python_path" "$HOME/.local/bin/python3" 2>/dev/null || true
    ln -sf "$python_bin_dir/pip3.13" "$HOME/.local/bin/pip3" 2>/dev/null || true

    # Ensure ~/.local/bin is in PATH for current session
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    success "Python symlinks created"
}

# Function to verify Python installation
verify_python_installation() {
    info "Verifying Python installation..."

    # Determine the correct Homebrew path
    local homebrew_path=""
    if [[ -d "/opt/homebrew" ]]; then
        homebrew_path="/opt/homebrew"
    else
        homebrew_path="/usr/local"
    fi

    # Update PATH for current session to include Homebrew Python
    export PATH="$homebrew_path/opt/python@3.13/bin:$homebrew_path/bin:$HOME/.local/bin:$PATH"

    # Check Python version using the updated PATH
    local current_version=""
    local python_path=""

    # Try different Python commands in order of preference
    if command -v python3.13 >/dev/null 2>&1; then
        current_version=$(python3.13 --version 2>&1 | cut -d' ' -f2)
        python_path=$(which python3.13)
    elif command -v python3 >/dev/null 2>&1; then
        current_version=$(python3 --version 2>&1 | cut -d' ' -f2)
        python_path=$(which python3)
    else
        error "❌ No Python3 command found after installation"
        return 1
    fi

    info "Found Python: $current_version at $python_path"

    # Check if we have the right version (3.13+ preferred, 3.8+ minimum)
    if [[ "$current_version" == "$REQUIRED_PYTHON_MAJOR_MINOR"* ]]; then
        success "✅ Python verification passed: $current_version at $python_path"
    elif python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)" 2>/dev/null; then
        success "✅ Python verification passed (minimum): $current_version at $python_path"
        warning "⚠️  Consider upgrading to Python $REQUIRED_PYTHON_MAJOR_MINOR for best compatibility"
    else
        error "❌ Python verification failed: expected 3.8+, got $current_version"
        return 1
    fi

    # Check pip
    local pip_cmd=""
    if command -v pip3.13 >/dev/null 2>&1; then
        pip_cmd="pip3.13"
    elif command -v pip3 >/dev/null 2>&1; then
        pip_cmd="pip3"
    else
        error "❌ pip3 not available"
        return 1
    fi

    local pip_version=$($pip_cmd --version 2>&1)
    success "✅ pip available: $pip_version"

    # Test Python functionality
    if python3 -c "import sys; print(f'Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro} working correctly')" 2>/dev/null; then
        success "✅ Python functionality test passed"
    else
        error "❌ Python functionality test failed"
        return 1
    fi
}

# Function to migrate existing Python packages
migrate_python_packages() {
    local old_python_path="$1"
    local new_python_path="$2"

    if [[ -z "$old_python_path" || "$old_python_path" == "$new_python_path" ]]; then
        info "No package migration needed"
        return 0
    fi

    info "Migrating Python packages from old installation..."

    # Get list of user-installed packages from old Python
    local old_pip_path=$(dirname "$old_python_path")/pip3
    if [[ -f "$old_pip_path" ]]; then
        local packages_file="/tmp/python_packages_backup.txt"

        # Export current packages (excluding system packages)
        if $old_pip_path list --user --format=freeze > "$packages_file" 2>/dev/null; then
            local package_count=$(wc -l < "$packages_file")
            if [[ $package_count -gt 0 ]]; then
                info "Found $package_count user packages to migrate"

                # Install packages with new Python
                if pip3 install --user -r "$packages_file" 2>/dev/null; then
                    success "✅ Package migration completed"
                else
                    error "⚠️  Some packages failed to migrate (this is normal)"
                fi

                rm -f "$packages_file"
            else
                info "No user packages found to migrate"
            fi
        else
            info "Could not read old package list"
        fi
    else
        info "Old pip not found, skipping package migration"
    fi
}

# Function to install pipx
install_pipx() {
    info "🔧 Installing pipx..."

    if command -v pipx >/dev/null 2>&1; then
        local pipx_version
        pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
        success "pipx already installed: version $pipx_version"
        return 0
    fi

    # Install pipx via Homebrew (preferred method for macOS)
    if command -v brew >/dev/null 2>&1; then
        info "Installing pipx via Homebrew..."
        brew install pipx
    else
        # Fallback to pip installation if Homebrew is not available
        info "Installing pipx via pip..."
        python3 -m pip install --user pipx

        # Add pipx to PATH
        local pip_user_bin="$HOME/.local/bin"
        if [[ -d "$pip_user_bin" ]] && [[ ":$PATH:" != *":$pip_user_bin:"* ]]; then
            export PATH="$pip_user_bin:$PATH"
            info "Added $pip_user_bin to PATH"
        fi
    fi

    # Configure pipx environment
    if command -v pipx >/dev/null 2>&1; then
        info "Configuring pipx environment..."

        # Ensure pipx directories exist
        local pipx_bin_dir="$HOME/.local/bin"
        local pipx_data_dir="$HOME/.local/share/pipx"

        mkdir -p "$pipx_bin_dir" "$pipx_data_dir"

        # Run pipx ensurepath
        info "Running pipx ensurepath..."
        pipx ensurepath --force 2>/dev/null || warning "pipx ensurepath failed"

        # Update PATH for current session
        if [[ -d "$pipx_bin_dir" ]] && [[ ":$PATH:" != *":$pipx_bin_dir:"* ]]; then
            export PATH="$pipx_bin_dir:$PATH"
            success "✅ Added $pipx_bin_dir to PATH for current session"
        fi

        # Verify pipx is working
        local pipx_version
        pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
        success "✅ pipx installed successfully: version $pipx_version"

        # Show pipx configuration
        info "Pipx configuration:"
        echo "  • Bin directory: $pipx_bin_dir"
        echo "  • Data directory: $pipx_data_dir"
        echo "  • PATH includes pipx bin: $(if [[ ":$PATH:" == *":$pipx_bin_dir:"* ]]; then echo "✅ Yes"; else echo "❌ No"; fi)"

    else
        error "❌ pipx installation failed"
        return 1
    fi
}

# Function to ensure pipx PATH is configured in shell files
configure_pipx_in_shell() {
    info "🔧 Configuring pipx PATH in shell configuration files..."

    local pipx_bin_dir="$HOME/.local/bin"
    local path_export="export PATH=\"$pipx_bin_dir:\$PATH\""
    local pipx_marker="# Added by dotsible bootstrap for pipx"

    # Determine which shell configuration file to use
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]] || [[ -f "$HOME/.zshrc" ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]] || [[ -f "$HOME/.bashrc" ]]; then
        shell_config="$HOME/.bashrc"
    else
        shell_config="$HOME/.profile"
    fi

    info "Using shell configuration file: $shell_config"

    # Check if pipx PATH is already configured
    if [[ -f "$shell_config" ]] && grep -q "$pipx_bin_dir" "$shell_config"; then
        success "✅ pipx PATH already configured in $shell_config"
        return 0
    fi

    # Create backup before modification
    if [[ -f "$shell_config" ]]; then
        local backup_dir="$HOME/.dotsible/backups"
        mkdir -p "$backup_dir"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$backup_dir/$(basename "$shell_config")_${timestamp}_pipx_config"
        cp "$shell_config" "$backup_file"
        info "📋 Backed up $shell_config to $backup_file"
    else
        # Create the config file if it doesn't exist
        touch "$shell_config"
        info "Created shell configuration file: $shell_config"
    fi

    # Add pipx PATH configuration
    info "Adding pipx PATH configuration to $shell_config"
    {
        echo ""
        echo "$pipx_marker"
        echo "if [[ -d \"$pipx_bin_dir\" ]] && [[ \":\$PATH:\" != *\":$pipx_bin_dir:\"* ]]; then"
        echo "    $path_export"
        echo "fi"
    } >> "$shell_config"

    success "✅ Added pipx PATH configuration to $shell_config"

    # Also add to .zprofile for zsh (loaded for login shells)
    if [[ "$SHELL" == *"zsh"* ]] && [[ ! -f "$HOME/.zprofile" || ! $(grep -q "$pipx_bin_dir" "$HOME/.zprofile" 2>/dev/null) ]]; then
        info "Adding pipx PATH configuration to ~/.zprofile"
        {
            echo ""
            echo "$pipx_marker"
            echo "if [[ -d \"$pipx_bin_dir\" ]] && [[ \":\$PATH:\" != *\":$pipx_bin_dir:\"* ]]; then"
            echo "    $path_export"
            echo "fi"
        } >> "$HOME/.zprofile"
        success "✅ Added pipx PATH configuration to ~/.zprofile"
    fi
}

# Function to debug and display PATH information
debug_path_configuration() {
    info "🔍 Debugging PATH configuration..."

    echo "Current PATH:"
    echo "$PATH" | tr ':' '\n' | nl
    echo

    local pipx_bin_dir="$HOME/.local/bin"
    echo "Checking pipx bin directory: $pipx_bin_dir"
    if [[ -d "$pipx_bin_dir" ]]; then
        success "✅ Directory exists: $pipx_bin_dir"
        echo "Contents:"
        ls -la "$pipx_bin_dir" 2>/dev/null || echo "  (empty or inaccessible)"
        echo

        if [[ ":$PATH:" == *":$pipx_bin_dir:"* ]]; then
            success "✅ $pipx_bin_dir is in PATH"
        else
            warning "⚠️  $pipx_bin_dir is NOT in PATH"
        fi
    else
        error "❌ Directory does not exist: $pipx_bin_dir"
    fi
    echo

    # Check pipx installation status
    if command -v pipx >/dev/null 2>&1; then
        echo "Pipx installations:"
        pipx list 2>/dev/null || echo "  (pipx list failed)"
    else
        error "❌ pipx command not found"
    fi
    echo
}

# Function to fix PATH for current session
fix_path_for_session() {
    info "🔧 Attempting to fix PATH for current session..."

    local pipx_bin_dir="$HOME/.local/bin"

    # Add pipx bin directory to PATH if not already present
    if [[ -d "$pipx_bin_dir" ]] && [[ ":$PATH:" != *":$pipx_bin_dir:"* ]]; then
        export PATH="$pipx_bin_dir:$PATH"
        success "✅ Added $pipx_bin_dir to PATH for current session"
    fi

    # Try to source shell configuration files
    local shell_configs=(
        "$HOME/.zprofile"
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
    )

    for config in "${shell_configs[@]}"; do
        if [[ -f "$config" ]]; then
            info "Sourcing: $config"
            # Source in a subshell to avoid potential errors affecting main script
            (source "$config" 2>/dev/null) || warning "Failed to source $config"
        fi
    done

    # Update PATH from pipx if available
    if command -v pipx >/dev/null 2>&1; then
        info "Running pipx ensurepath..."
        pipx ensurepath --force 2>/dev/null || warning "pipx ensurepath failed"
    fi
}

# Function removed - duplicate definition exists above

# Function to check for alternative Ansible command names (Ansible 11.6.0 issue)
check_alternative_ansible_commands() {
    local alternative_commands=(
        "ansible-community"
        "ansible-core"
    )

    info "🔍 Checking for alternative Ansible command names..."

    for cmd in "${alternative_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            warning "⚠️  Found alternative command: $cmd"
            echo "  Location: $(which "$cmd")"

            # Try to create symlink for main ansible command
            local pipx_bin_dir="$HOME/.local/bin"
            local ansible_symlink="$pipx_bin_dir/ansible"

            if [[ ! -e "$ansible_symlink" ]]; then
                info "Creating symlink: $ansible_symlink -> $(which "$cmd")"
                ln -sf "$(which "$cmd")" "$ansible_symlink" 2>/dev/null || warning "Failed to create symlink"
            fi
        fi
    done
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

    info "🔍 Verifying Ansible commands availability..."

    # First check for alternative command names and try to fix
    check_alternative_ansible_commands

    for cmd in "${expected_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            available_commands+=("$cmd")
            success "  ✅ $cmd: $(which "$cmd")"
        else
            missing_commands+=("$cmd")
            error "  ❌ $cmd: Not found"
        fi
    done

    echo
    info "Summary:"
    info "  Available: ${#available_commands[@]}/${#expected_commands[@]} commands"
    info "  Missing: ${#missing_commands[@]} commands"

    # Consider it successful if we have the core commands
    local core_commands=("ansible" "ansible-playbook")
    local core_available=0

    for cmd in "${core_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            ((core_available++))
        fi
    done

    if [[ $core_available -eq ${#core_commands[@]} ]]; then
        success "✅ Core Ansible commands are available"
        if [[ ${#missing_commands[@]} -gt 0 ]]; then
            warning "⚠️  Some optional commands missing: ${missing_commands[*]}"
        fi
        return 0
    else
        error "❌ Missing critical Ansible commands: ${missing_commands[*]}"
        return 1
    fi
}

# Function to check what's actually in ~/.local/bin
debug_local_bin_contents() {
    local pipx_bin_dir="$HOME/.local/bin"

    info "🔍 Analyzing $pipx_bin_dir contents..."

    if [[ ! -d "$pipx_bin_dir" ]]; then
        error "❌ Directory does not exist: $pipx_bin_dir"
        return 1
    fi

    echo "All files in $pipx_bin_dir:"
    ls -la "$pipx_bin_dir" 2>/dev/null || echo "  (empty or inaccessible)"
    echo

    echo "Ansible-related files:"
    ls -la "$pipx_bin_dir" 2>/dev/null | grep -i ansible || echo "  (no ansible-related files found)"
    echo

    echo "Symlink analysis:"
    for file in "$pipx_bin_dir"/*; do
        if [[ -L "$file" ]] && [[ "$(basename "$file")" == *ansible* ]]; then
            local target
            target=$(readlink "$file")
            echo "  $(basename "$file") -> $target"
        fi
    done
    echo
}

# Function to force reinstall Ansible via pipx
force_reinstall_ansible() {
    info "🔄 Force reinstalling Ansible via pipx..."

    # First, try to uninstall if it exists
    if pipx list | grep -q ansible; then
        info "Uninstalling existing Ansible installation..."
        pipx uninstall ansible || warning "Failed to uninstall existing Ansible"
    fi

    # Force install with verbose output
    info "Installing Ansible with --force flag..."
    if pipx install --force ansible; then
        success "✅ Ansible force installation completed"
    else
        error "❌ Ansible force installation failed"
        return 1
    fi

    # Verify the installation created the expected symlinks
    debug_local_bin_contents

    return 0
}

# Function to install Ansible via pipx
install_ansible_via_pipx() {
    info "🤖 Installing Ansible via pipx..."

    # Initial PATH debugging
    debug_path_configuration

    # Check if all Ansible commands are already available
    if verify_ansible_commands; then
        local ansible_version
        ansible_version=$(ansible --version | head -1)
        success "✅ All Ansible commands already available: $ansible_version"
        return 0
    fi

    # Verify pipx is available
    if ! command -v pipx >/dev/null 2>&1; then
        error "❌ pipx is not available. Please install pipx first."
        return 1
    fi

    # Check if Ansible package exists in pipx but commands are missing
    local ansible_in_pipx=false
    if pipx list | grep -q ansible; then
        ansible_in_pipx=true
        warning "⚠️  Ansible package found in pipx but commands are missing"
        debug_local_bin_contents

        info "This indicates an incomplete installation. Will force reinstall..."
        force_reinstall_ansible
    else
        # Fresh installation
        info "Installing Ansible via pipx..."
        if pipx install ansible; then
            success "✅ Ansible installed successfully via pipx"
        else
            error "❌ Failed to install Ansible via pipx"
            debug_path_configuration
            return 1
        fi
    fi

    # Verify pipx installation shows the package
    info "Verifying pipx installation..."
    if pipx list | grep -q ansible; then
        success "✅ Ansible found in pipx installations"
        pipx list | grep ansible
    else
        error "❌ Ansible not found in pipx installations"
        debug_path_configuration
        return 1
    fi

    # First comprehensive verification attempt
    info "🔍 First verification attempt - checking all Ansible commands..."
    debug_local_bin_contents

    if verify_ansible_commands; then
        local ansible_version
        ansible_version=$(ansible --version | head -1)
        success "✅ Ansible verification passed: $ansible_version"

        # Test Ansible functionality
        if ansible localhost -m ping >/dev/null 2>&1; then
            success "✅ Ansible functionality verified"
        else
            info "ℹ️  Ansible ping test failed, but installation appears successful"
        fi
        return 0
    fi

    # If first attempt fails, try to fix PATH and retry
    warning "⚠️  First verification failed - attempting PATH fix..."
    debug_path_configuration

    fix_path_for_session

    # Second verification attempt
    info "🔍 Second verification attempt after PATH fix..."
    if verify_ansible_commands; then
        local ansible_version
        ansible_version=$(ansible --version | head -1)
        success "✅ Ansible verification passed after PATH fix: $ansible_version"

        # Test Ansible functionality
        if ansible localhost -m ping >/dev/null 2>&1; then
            success "✅ Ansible functionality verified"
        else
            info "ℹ️  Ansible ping test failed, but installation appears successful"
        fi
        return 0
    fi

    # Third attempt: Force reinstallation
    warning "⚠️  Second verification failed - attempting force reinstallation..."
    if force_reinstall_ansible; then
        info "🔍 Third verification attempt after force reinstallation..."
        fix_path_for_session  # Ensure PATH is updated

        if verify_ansible_commands; then
            local ansible_version
            ansible_version=$(ansible --version | head -1)
            success "✅ Ansible verification passed after force reinstallation: $ansible_version"

            # Test Ansible functionality
            if ansible localhost -m ping >/dev/null 2>&1; then
                success "✅ Ansible functionality verified"
            else
                info "ℹ️  Ansible ping test failed, but installation appears successful"
            fi
            return 0
        fi
    fi

    # Final failure with comprehensive diagnostics
    error "❌ Ansible installation failed after all attempts"
    echo
    error "COMPREHENSIVE TROUBLESHOOTING INFORMATION:"
    echo "=========================================="

    debug_path_configuration
    debug_local_bin_contents

    echo "PIPX STATUS:"
    pipx list 2>/dev/null || echo "pipx list failed"
    echo

    echo "MANUAL TROUBLESHOOTING STEPS:"
    echo "1. Check pipx installation status:"
    echo "   pipx list"
    echo "   pipx --version"
    echo
    echo "2. Try manual Ansible reinstallation:"
    echo "   pipx uninstall ansible"
    echo "   pipx install ansible --verbose"
    echo "   pipx ensurepath"
    echo
    echo "3. Check for conflicting installations:"
    echo "   which -a ansible"
    echo "   pip list | grep ansible"
    echo "   brew list | grep ansible"
    echo
    echo "4. Verify PATH configuration:"
    echo "   echo \$PATH"
    echo "   ls -la ~/.local/bin/"
    echo
    echo "5. Try alternative installation method:"
    echo "   pip3 install --user ansible"
    echo "   # or"
    echo "   brew install ansible"
    echo
    echo "6. Add to your shell configuration (~/.zshrc or ~/.bashrc):"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo
    echo "7. Restart your terminal and try again"
    echo

    return 1
}

# Function to provide final installation summary
provide_installation_summary() {
    info "📋 Installation Summary"
    echo "======================="

    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        local python_version
        python_version=$(python3 --version 2>&1)
        success "✅ Python: $python_version"
    else
        error "❌ Python: Not found"
    fi

    # Check pipx
    if command -v pipx >/dev/null 2>&1; then
        local pipx_version
        pipx_version=$(pipx --version 2>/dev/null || echo "unknown")
        success "✅ pipx: version $pipx_version"

        # Show pipx installations
        echo "   Installed packages:"
        pipx list 2>/dev/null | grep -E "^\s*package" || echo "   (no packages installed)"
    else
        error "❌ pipx: Not found"
    fi

    # Check Ansible with comprehensive command verification
    echo "Ansible Commands:"
    if verify_ansible_commands >/dev/null 2>&1; then
        local ansible_version
        ansible_version=$(ansible --version | head -1)
        success "✅ Ansible: $ansible_version"

        # Show available commands
        local ansible_commands=("ansible" "ansible-playbook" "ansible-galaxy" "ansible-vault")
        for cmd in "${ansible_commands[@]}"; do
            if command -v "$cmd" >/dev/null 2>&1; then
                success "   ✅ $cmd: Available"
            else
                warning "   ⚠️  $cmd: Missing"
            fi
        done

        # Test Ansible functionality
        if ansible localhost -m ping >/dev/null 2>&1; then
            success "   ✅ Ansible functionality test passed"
        else
            warning "   ⚠️  Ansible functionality test failed"
        fi
    else
        error "❌ Ansible: Commands missing or incomplete installation"

        # Show what's actually available
        local ansible_commands=("ansible" "ansible-playbook" "ansible-galaxy" "ansible-vault")
        for cmd in "${ansible_commands[@]}"; do
            if command -v "$cmd" >/dev/null 2>&1; then
                success "   ✅ $cmd: Available"
            else
                error "   ❌ $cmd: Missing"
            fi
        done
    fi

    # Check PATH configuration
    local pipx_bin_dir="$HOME/.local/bin"
    if [[ ":$PATH:" == *":$pipx_bin_dir:"* ]]; then
        success "✅ PATH: pipx bin directory is configured"
    else
        warning "⚠️  PATH: pipx bin directory not in current PATH"
        echo "   Add this to your shell config: export PATH=\"$pipx_bin_dir:\$PATH\""
    fi

    echo
    if verify_ansible_commands >/dev/null 2>&1; then
        success "🎉 Bootstrap completed successfully!"
        echo

        # Export PATH for parent shell if possible
        local pipx_bin_dir="$HOME/.local/bin"
        if [[ -d "$pipx_bin_dir" ]]; then
            echo "# Add pipx to PATH" >> "$HOME/.zshrc"
            echo "export PATH=\"$pipx_bin_dir:\$PATH\"" >> "$HOME/.zshrc"
            info "✅ Added pipx PATH to ~/.zshrc for future sessions"
        fi

        info "Next steps:"
        echo "  1. Run: ansible-playbook site.yml"
        echo "  2. Or run: ./run-dotsible.sh --profile developer --environment personal"
        echo "  3. If commands not found, restart terminal or run: source ~/.zshrc"
        echo "  3. If Ansible commands are not found in new terminals, restart your terminal or run:"
        echo "     source ~/.zshrc  # or ~/.bashrc"
        echo
        info "Available Ansible commands:"
        local ansible_commands=("ansible" "ansible-playbook" "ansible-galaxy" "ansible-vault")
        for cmd in "${ansible_commands[@]}"; do
            if command -v "$cmd" >/dev/null 2>&1; then
                echo "  ✅ $cmd"
            fi
        done
    else
        error "⚠️  Bootstrap completed with issues - Ansible installation incomplete"
        echo
        info "Troubleshooting:"
        echo "  1. Restart your terminal"
        echo "  2. Run: source ~/.zshrc  # or ~/.bashrc"
        echo "  3. Check available commands: ls -la ~/.local/bin/ | grep ansible"
        echo "  4. Try force reinstall: pipx uninstall ansible && pipx install ansible"
        echo "  5. Check pipx status: pipx list"
        echo "  6. If still not working, try alternative installation:"
        echo "     brew install ansible"
        echo "  7. Verify PATH includes ~/.local/bin"
    fi
    echo
}

main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                  macOS BOOTSTRAP SCRIPT                     ║${NC}"
    echo -e "${BLUE}║              Dotsible Environment Setup                     ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    
    log "macOS bootstrap started for environment: $ENVIRONMENT_TYPE"
    
    # Check for Xcode Command Line Tools
    if ! xcode-select -p >/dev/null 2>&1; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        info "Please complete the Xcode Command Line Tools installation and re-run this script"
        exit 1
    fi
    success "Xcode Command Line Tools: $(xcode-select -p)"
    
    # Install Homebrew
    if ! command -v brew >/dev/null 2>&1; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        success "Homebrew already installed"
        brew update
    fi
    
    # Python Version Management - Upgrade to Python 3.13.4
    manage_python_version

    # Install pipx
    install_pipx

    # Configure pipx in shell files
    configure_pipx_in_shell

    # Install Ansible via pipx
    install_ansible_via_pipx

    # Provide installation summary
    provide_installation_summary
}

trap 'error "macOS bootstrap failed at line $LINENO"; exit 1' ERR
main "$@"
