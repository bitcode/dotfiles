# Homebrew Integration Fix - Comprehensive Solution

## Problem Analysis

The dotsible bootstrap and run scripts were exhibiting serious Homebrew package management issues:

### **Primary Issues Identified:**

1. **Duplicate Script Content**: The `bootstrap_macos.sh` file contained duplicate `main()` functions and conflicting implementations
2. **PATH Conflicts**: Multiple scripts were modifying shell configuration files simultaneously
3. **Conflicting Installation Methods**: Bootstrap script and Ansible roles were using different approaches
4. **Shell Configuration Chaos**: Modifications to `.zshrc`, `.bashrc`, `.profile`, and `.zprofile` without coordination
5. **Idempotency Failures**: No proper state tracking causing repeated installations

### **Root Causes:**

- **File Corruption**: `bootstrap_macos.sh` had 941 lines with duplicate content after line 562
- **Uncoordinated PATH Management**: Multiple functions modifying PATH without checking existing configurations
- **Legacy Code**: Old pipx and Python PATH management functions conflicting with Homebrew
- **Missing Idempotency Checks**: Scripts not properly detecting existing installations

## Solution Implemented

### **1. Cleaned Bootstrap Script**
- **Removed duplicate content** from `bootstrap_macos.sh` (reduced from 941 to 562 lines)
- **Eliminated conflicting functions**: Removed unused `install_pipx()` and `configure_pipx_in_shell()` functions
- **Streamlined main execution**: Single, clean main function with proper error handling

### **2. Improved Homebrew Installation Logic**
```bash
# New approach in bootstrap_macos.sh
install_homebrew() {
    # Check if already installed and working
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew already installed"
        setup_homebrew_path_current_session
        return 0
    fi
    
    # Install with proper environment
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $HOMEBREW_INSTALL_URL)"
    
    # Configure shell integration (idempotent)
    configure_homebrew_shell_integration
}
```

### **3. Idempotent Shell Integration**
```bash
configure_homebrew_shell_integration() {
    # Use .zprofile for zsh (login shells)
    # Use .bash_profile for bash (login shells)
    # Check for existing configuration before adding
    
    if grep -q "Homebrew - Dotsible managed" "$shell_config"; then
        success "Already configured"
        return 0
    fi
    
    # Add configuration with marker
}
```

### **4. Enhanced Ansible Role**
Updated `roles/package_manager/tasks/setup_homebrew.yml`:
- **Idempotent PATH checks**: Verify existing configuration before modification
- **Conditional installation**: Only install if not already present
- **Proper shell file targeting**: Use `.zprofile` for persistent configuration
- **Architecture-aware setup**: Different paths for Apple Silicon vs Intel Macs

### **5. Comprehensive Testing**
Created `scripts/test_homebrew_integration.sh` to verify:
- Homebrew installation and functionality
- Shell integration and PATH configuration
- Package installation capabilities
- System health and idempotency

## Key Improvements

### **Idempotent Installation**
```yaml
- name: Check if Homebrew PATH is already configured
  shell: grep -q "brew shellenv" "{{ ansible_env.HOME }}/.zprofile"
  register: homebrew_path_configured
  failed_when: false

- name: Add Homebrew to PATH (only if needed)
  blockinfile:
    path: "{{ ansible_env.HOME }}/.zprofile"
    marker: "# {mark} Homebrew - Dotsible managed"
    block: |
      if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi
  when: homebrew_path_configured.rc != 0
```

### **Proper Shell File Management**
- **Bootstrap script**: Uses `.zprofile` for persistent configuration
- **Ansible role**: Coordinates with bootstrap script using same file
- **Markers**: Clear identification of dotsible-managed sections
- **Conditional logic**: Checks for Homebrew existence before sourcing

### **Session vs Persistent PATH**
- **Current session**: `eval "$(brew shellenv)"` for immediate availability
- **Future sessions**: Shell configuration file modifications for persistence
- **No conflicts**: Separate handling prevents PATH duplication

## Expected Behavior After Fix

### **✅ Successful Installation Flow**
1. **First run**: Homebrew installs cleanly with proper PATH configuration
2. **Subsequent runs**: Detects existing installation and skips reinstallation
3. **Package availability**: All Homebrew-installed packages remain accessible
4. **Shell integration**: Commands work immediately and persist across sessions

### **✅ Idempotent Execution**
- Multiple script runs don't break existing installations
- PATH configurations are not duplicated
- Existing packages remain available
- No unnecessary reinstallations

### **✅ Cross-Platform Compatibility**
- **Apple Silicon Macs**: Uses `/opt/homebrew` path
- **Intel Macs**: Uses `/usr/local` path
- **Automatic detection**: Scripts detect architecture and configure appropriately

## Verification Steps

### **1. Run Test Script**
```bash
./scripts/test_homebrew_integration.sh
```

### **2. Manual Verification**
```bash
# Check Homebrew installation
which brew
brew --version

# Verify PATH configuration
echo $PATH | grep homebrew

# Check shell configuration
grep -A5 -B5 "brew shellenv" ~/.zprofile

# Test package installation
brew install tree
which tree
```

### **3. Idempotency Test**
```bash
# Run bootstrap multiple times
./scripts/bootstrap_macos.sh
./scripts/bootstrap_macos.sh  # Should skip Homebrew installation

# Run dotsible multiple times
./run-dotsible.sh --profile enterprise --environment enterprise
./run-dotsible.sh --profile enterprise --environment enterprise  # Should be idempotent
```

## Troubleshooting Guide

### **If Homebrew Commands Not Found**
```bash
# Check if Homebrew is installed
ls -la /opt/homebrew/bin/brew  # Apple Silicon
ls -la /usr/local/bin/brew     # Intel

# Manually source Homebrew environment
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
eval "$(/usr/local/bin/brew shellenv)"     # Intel

# Check shell configuration
cat ~/.zprofile | grep brew
```

### **If PATH Issues Persist**
```bash
# Check current PATH
echo $PATH | tr ':' '\n' | grep -E 'homebrew|local'

# Restart shell
exec $SHELL

# Check for conflicts
grep -r "export PATH" ~/.zshrc ~/.bashrc ~/.profile ~/.zprofile 2>/dev/null
```

### **If Packages Disappear**
```bash
# Check Homebrew status
brew doctor

# List installed packages
brew list

# Reinstall if needed
brew reinstall <package>
```

## Integration with Dotsible Ecosystem

### **Bootstrap Integration**
- **Prerequisite**: Homebrew installation happens before Ansible execution
- **State tracking**: Proper detection prevents duplicate installations
- **Error handling**: Graceful failure with helpful error messages

### **Ansible Integration**
- **Role coordination**: Package manager role works with bootstrap script
- **Conditional execution**: Only runs when Homebrew is available
- **Platform awareness**: Adapts to different macOS architectures

### **Application Roles**
- **Dependency management**: Applications can rely on Homebrew being available
- **Package installation**: Consistent package management across all roles
- **Cask support**: GUI applications install properly via Homebrew Cask

## Future Considerations

### **Maintenance**
- **Regular testing**: Use test script to verify integration health
- **Version updates**: Monitor Homebrew changes and adapt accordingly
- **Shell compatibility**: Ensure compatibility with future shell versions

### **Enhancements**
- **Backup/restore**: Implement package list backup and restore functionality
- **Performance optimization**: Cache package lists for faster execution
- **Advanced configuration**: Support for custom Homebrew configurations

This comprehensive fix resolves all identified Homebrew integration issues while establishing a robust, maintainable foundation for package management in the dotsible ecosystem.
