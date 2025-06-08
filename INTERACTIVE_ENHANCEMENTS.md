# Dotsible Interactive Enhancements

## Overview

The enhanced `run-dotsible.sh` script now provides a user-friendly interactive experience while maintaining full backward compatibility with command-line arguments. This implementation addresses the need for better user guidance and proper privilege escalation handling.

## Key Enhancements

### ✅ **Interactive Profile Selection**

When running `./run-dotsible.sh` without arguments, users are presented with a clear menu:

```
📋 Profile Selection
Choose your dotsible profile:

1) minimal     - Basic system setup with essential tools
   • Git configuration
   • Basic shell setup
   • Essential system tools

2) developer   - Full development environment
   • Everything from minimal profile
   • Neovim with full configuration
   • Tmux terminal multiplexer
   • Zsh shell with enhancements
   • Development tools and languages

3) enterprise  - Enterprise-ready setup
   • Everything from developer profile
   • Additional security tools
   • Enterprise compliance settings
   • Advanced monitoring and logging

4) Cancel      - Exit without making changes

Enter your choice (1-4):
```

### ✅ **Interactive Environment Type Selection**

Users can choose between environment types with clear descriptions:

```
🏢 Environment Type Selection
Choose your environment type:

1) personal    - Personal workstation configuration
   • Optimized for individual productivity
   • Personal dotfiles and preferences
   • Flexible security settings
   • Full customization freedom

2) enterprise  - Corporate/enterprise environment
   • Compliance with corporate policies
   • Enhanced security configurations
   • Standardized tool versions
   • Audit logging and monitoring

3) Cancel      - Exit without making changes

Enter your choice (1-3):
```

### ✅ **Intelligent Privilege Escalation**

The script automatically detects when administrator privileges are needed:

#### **Detection Logic**
- **macOS**: Requires sudo for developer/enterprise profiles (system packages, Go installation)
- **Linux**: Always requires sudo for package management (apt, pacman, dnf)
- **Windows**: No sudo required (uses user-level package managers)

#### **User Experience**
```
🔐 Privilege Escalation Required
Some tasks require administrator privileges for:
  • Installing system packages (Go, system tools)
  • Modifying system configurations

You will be prompted for your password when needed.
Press Enter to continue or Ctrl+C to cancel...
```

#### **Ansible Integration**
- Automatically adds `--ask-become-pass` flag when needed
- Prompts for password once at the beginning
- Handles privilege escalation gracefully

### ✅ **Enhanced User Experience**

#### **Selection Summary**
Before execution, users see a clear summary:
```
📋 Configuration Summary
Profile: developer
Environment: personal
Privileges: Administrator access required

Press Enter to proceed or Ctrl+C to cancel...
```

#### **Execution Information**
The execution banner now includes privilege information:
```
╔══════════════════════════════════════════════════════════════╗
║                    DOTSIBLE EXECUTION                       ║
╠══════════════════════════════════════════════════════════════╣
║ Profile: developer                                           ║
║ Environment: personal                                        ║
║ Mode: EXECUTION                                              ║
║ Verbose: DISABLED                                            ║
║ Privileges: ADMIN REQUIRED                                   ║
╚══════════════════════════════════════════════════════════════╝
```

## Usage Modes

### **Interactive Mode (New)**
```bash
# Run with interactive prompts
./run-dotsible.sh
```
- Prompts for profile selection
- Prompts for environment type
- Automatically detects privilege requirements
- Shows configuration summary before execution

### **Direct Mode (Existing)**
```bash
# Specify all parameters directly
./run-dotsible.sh --profile developer --environment enterprise
```
- Skips interactive prompts
- Validates provided parameters
- Maintains full backward compatibility

### **Mixed Mode (New)**
```bash
# Specify some parameters, prompt for others
./run-dotsible.sh --profile developer
# Will prompt for environment type only

./run-dotsible.sh --environment personal
# Will prompt for profile only
```

## Input Validation

### **Profile Validation**
- Accepts: `minimal`, `developer`, `enterprise`
- Re-prompts for invalid input
- Provides clear error messages

### **Environment Validation**
- Accepts: `personal`, `enterprise`
- Re-prompts for invalid input
- Provides clear error messages

### **Cancellation Options**
- Users can select "Cancel" option in menus
- Ctrl+C support at any prompt
- Graceful exit with appropriate messages

## Privilege Escalation Details

### **Detection Algorithm**
```bash
detect_sudo_requirements() {
    local os_type=$(uname -s)
    local needs_sudo=false
    
    case "$os_type" in
        "Darwin")
            # macOS may need sudo for developer/enterprise profiles
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
}
```

### **Ansible Integration**
- Adds `--ask-become-pass` flag when `NEED_SUDO=true`
- Password prompt appears before playbook execution
- Single password prompt for entire deployment
- Proper error handling for authentication failures

## Backward Compatibility

### ✅ **Preserved Functionality**
- All existing command-line arguments work unchanged
- CI/CD scripts continue to function
- Automation-friendly interface maintained
- Exit codes preserved for scripting

### ✅ **Enhanced Features**
- Interactive mode only activates when parameters are missing
- Direct parameter specification bypasses prompts
- All existing options (`--verbose`, `--dry-run`, `--tags`) preserved

## Examples

### **Interactive Deployment**
```bash
./run-dotsible.sh
# User selects: 2 (developer), 1 (personal)
# System detects: Admin privileges required
# Prompts for sudo password
# Executes deployment
```

### **Automated Deployment**
```bash
./run-dotsible.sh --profile minimal --environment personal --dry-run
# No prompts, direct execution
# Perfect for CI/CD pipelines
```

### **Debugging Mode**
```bash
./run-dotsible.sh --profile developer --environment enterprise --verbose
# Direct execution with full Ansible output
# Ideal for troubleshooting
```

### **Partial Automation**
```bash
./run-dotsible.sh --profile developer
# Prompts only for environment type
# Useful for semi-automated scenarios
```

## Error Handling

### **Invalid Input**
- Clear error messages for invalid selections
- Re-prompting until valid input provided
- Option to cancel at any time

### **Missing Privileges**
- Clear explanation of why privileges are needed
- Platform-specific privilege requirements
- Graceful handling of authentication failures

### **System Requirements**
- Validation of Ansible installation
- Inventory file existence checks
- Working directory validation

## Benefits

### **User Experience**
- **Guided Setup**: Clear descriptions help users choose appropriate options
- **Reduced Errors**: Input validation prevents common mistakes
- **Flexible Usage**: Interactive for new users, direct for automation
- **Professional Interface**: Clean, consistent user experience

### **Security**
- **Minimal Privileges**: Only requests admin access when actually needed
- **Clear Disclosure**: Users know exactly why privileges are required
- **Platform Awareness**: Different privilege handling per operating system

### **Operational**
- **CI/CD Friendly**: Maintains automation compatibility
- **Debugging Support**: Verbose mode available when needed
- **Consistent Behavior**: Same functionality across all platforms

## Migration Guide

### **For New Users**
1. Run `./run-dotsible.sh` without arguments
2. Follow interactive prompts
3. Review configuration summary
4. Proceed with deployment

### **For Existing Users**
- **No changes required** - existing commands continue to work
- **Optional enhancement** - can use interactive mode for convenience
- **Same functionality** - all features preserved

### **For CI/CD Systems**
- **No changes required** - continue using direct parameter mode
- **Enhanced logging** - privilege information now included in output
- **Same exit codes** - automation scripts continue to work

## Conclusion

The enhanced interactive mode transforms dotsible from a command-line tool into a user-friendly deployment system while maintaining its powerful automation capabilities. Users get guided setup with clear explanations, while CI/CD systems continue to work unchanged. The intelligent privilege escalation ensures security best practices while providing a smooth user experience.
