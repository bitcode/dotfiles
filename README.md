# 🚀 Dotsible - Cross-Platform Developer Environment Restoration System

[![Platform Support](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20Arch%20Linux%20%7C%20Ubuntu-blue)](#supported-platforms)
[![Ansible](https://img.shields.io/badge/Ansible-2.9%2B-red)](https://ansible.com)
[![Python](https://img.shields.io/badge/Python-3.8%2B-green)](https://python.org)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

**Dotsible** is a unified cross-platform developer environment restoration system that supports Windows, macOS, Arch Linux, and Ubuntu with conditional deployment based on OS, distribution, window manager, and environment type (personal/enterprise).

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Prerequisites](#-prerequisites)
- [Quick Start Guide](#-quick-start-guide)
- [Bootstrap Commands](#-bootstrap-commands)
- [Ansible Playbook Commands](#-ansible-playbook-commands)
- [Font Management](#-font-management)
- [Testing Commands](#-testing-commands)
- [Supported Platforms](#-supported-platforms)
- [Development Tools Integration](#-development-tools-integration)
- [Troubleshooting](#-troubleshooting)
- [Future Roadmap](#-future-roadmap)

## 🎯 Project Overview

Dotsible provides a comprehensive solution for:

- **Cross-Platform Support**: Unified configuration management across Windows, macOS, Arch Linux, and Ubuntu
- **Interactive User Experience**: Guided setup with profile and environment selection prompts
- **Clean Output Interface**: Professional deployment logs with clear status indicators and progress tracking
- **Intelligent Privilege Escalation**: Automatic detection and handling of administrator privileges when needed
- **Idempotent Package Management**: Check-before-install patterns ensuring safe repeated execution
- **Environment-Aware Deployment**: Conditional configurations based on personal vs enterprise environments
- **Window Manager Integration**: Support for i3, Hyprland, Sway, Waybar, Polybar, and more
- **Font Management**: Cross-platform Nerd Font installation with automatic cache refresh
- **Development Tools**: Integrated Python development toolkit with pipx, community-ansible-dev-tools, and ansible-lint
- **MCP Integration**: Model Context Protocol packages for AI-enhanced development workflows
- **Automation Friendly**: Full backward compatibility with CI/CD systems and scripted deployments

### Architecture

```
dotsible/
├── 📄 run-dotsible.sh                 # Enhanced execution script with interactive prompts
├── 📄 bootstrap.sh                    # Universal Unix bootstrap
├── 📄 bootstrap.ps1                   # Windows PowerShell bootstrap
├── 📄 site.yml                        # Main Ansible playbook
├── 📄 ansible.cfg                     # Ansible configuration with clean output
├── 📄 requirements.yml                # Ansible Galaxy requirements
│
├── 📁 callback_plugins/               # Custom Ansible output formatting
│   └── 📄 dotsible_clean.py          # Clean output callback plugin
│
├── 📁 scripts/                        # Platform-specific bootstrap scripts
│   ├── 📄 bootstrap_macos.sh         # macOS bootstrap (Homebrew, Xcode)
│   ├── 📄 bootstrap_windows.ps1      # Windows bootstrap (Chocolatey, Python)
│   ├── 📄 bootstrap_archlinux.sh     # Arch Linux bootstrap (pacman, AUR)
│   └── 📄 bootstrap_ubuntu.sh        # Ubuntu bootstrap (apt, snap, flatpak)
│
├── 📁 roles/                          # Ansible roles
│   ├── 📁 platform_specific/         # Platform-specific configurations
│   │   ├── 📁 macos/                 # macOS-specific tasks and packages
│   │   ├── 📁 windows/               # Windows-specific tasks and packages
│   │   ├── 📁 archlinux/             # Arch Linux-specific tasks and packages
│   │   └── 📁 ubuntu/                # Ubuntu-specific tasks and packages
│   ├── 📁 applications/              # Cross-platform application roles
│   │   ├── 📁 fonts/                 # Font management (Iosevka Nerd Font)
│   │   ├── 📁 neovim/                # Neovim configuration
│   │   ├── 📁 tmux/                  # Tmux setup
│   │   ├── 📁 zsh/                   # ZSH with Oh My Zsh
│   │   └── 📁 [window_managers]/     # i3, Hyprland, Sway, etc.
│   └── 📁 profiles/                  # Environment profiles
│       ├── 📁 developer/             # Developer-focused setup
│       ├── 📁 enterprise/            # Enterprise environment
│       └── 📁 minimal/               # Minimal installation
│
└── 📁 tests/                         # Comprehensive testing framework
    ├── 📁 integration/               # Cross-platform integration tests
    ├── 📁 validation/                # Syntax and configuration validation
    └── 📁 scripts/                   # Test automation scripts
```

## 🔧 Prerequisites

### System Requirements

| Platform | Requirements |
|----------|-------------|
| **macOS** | macOS 10.15+ (Catalina), Xcode Command Line Tools |
| **Windows** | Windows 10/11, PowerShell 5.1+, Administrator privileges (optional) |
| **Arch Linux** | Base installation, sudo access, internet connection |
| **Ubuntu** | Ubuntu 18.04+/Debian 10+, sudo access, internet connection |

### Dependencies (Auto-Installed by Bootstrap)

- **Python 3.8+** - Core automation engine
- **Ansible 2.9+** - Configuration management
- **pipx** - Python package isolation
- **Platform Package Managers**:
  - macOS: Homebrew
  - Windows: Chocolatey
  - Arch Linux: pacman + yay (AUR helper)
  - Ubuntu: apt + snap + flatpak

## 🚀 Quick Start Guide

### 1. Clone and Bootstrap

```bash
# Clone the repository
git clone <repository-url> dotsible
cd dotsible

# Run platform-appropriate bootstrap
# Unix-like systems (macOS, Linux)
./bootstrap.sh

# Windows (PowerShell as Administrator recommended)
.\bootstrap.ps1
```

### 2. Run Configuration

#### Interactive Mode (Recommended for New Users)
```bash
# Run with interactive prompts - guides you through profile and environment selection
./run-dotsible.sh
```

#### Direct Mode (For Automation/CI-CD)
```bash
# Specify profile and environment directly
./run-dotsible.sh --profile developer --environment personal

# Other common configurations
./run-dotsible.sh --profile minimal --environment personal
./run-dotsible.sh --profile enterprise --environment enterprise
```

#### Cross-Platform Execution
- **Linux/macOS**: `./run-dotsible.sh` (bash script)
- **Windows**: Use the bash script through WSL, Git Bash, or PowerShell with bash support
  ```powershell
  # If using Git Bash or WSL
  ./run-dotsible.sh

  # Alternative: Direct Ansible execution
  ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer
  ```

### 3. Verify Installation

```bash
# Run comprehensive tests
./tests/scripts/run_all_tests.sh

# Validate syntax
./tests/scripts/validate_syntax.sh
```

## 🔄 Bootstrap Commands

Bootstrap scripts prepare your system to run Ansible playbooks by installing essential dependencies.

### Universal Bootstrap

```bash
# Unix-like systems (auto-detects platform)
./bootstrap.sh [environment_type]

# Windows
.\bootstrap.ps1 [environment_type]
```

**Environment Types:**
- `personal` (default) - Personal development setup
- `enterprise` - Enterprise-compliant configuration

### Platform-Specific Bootstrap

#### macOS
```bash
# Direct execution
./scripts/bootstrap_macos.sh personal

# What it installs:
# - Xcode Command Line Tools
# - Homebrew package manager
# - Python 3.8+ via Homebrew
# - Ansible via pip
# - pipx for Python package isolation
# - community-ansible-dev-tools and ansible-lint
```

#### Windows
```powershell
# Direct execution
.\scripts\bootstrap_windows.ps1 personal

# What it installs:
# - Chocolatey package manager
# - Python 3.8+ via Chocolatey
# - Ansible via pip
# - pipx for Python package isolation
# - community-ansible-dev-tools and ansible-lint
```

#### Arch Linux
```bash
# Direct execution
./scripts/bootstrap_archlinux.sh personal

# What it installs:
# - System update (pacman -Syu)
# - Base development tools (base-devel)
# - Python 3.8+ and pip
# - yay AUR helper
# - Ansible via pacman or pip
# - pipx and development tools
```

#### Ubuntu/Debian
```bash
# Direct execution
./scripts/bootstrap_ubuntu.sh personal

# What it installs:
# - System update (apt update && upgrade)
# - Build essentials and Python 3.8+
# - Ansible via apt or pip
# - Snap and Flatpak package managers
# - pipx and development tools
```

### Bootstrap Success Indicators

✅ **Successful Bootstrap Output:**
```
✅ [Platform] bootstrap completed successfully!

Installed components:
  - Python: Python 3.x.x
  - Ansible: ansible [core 2.x.x]
  - pipx: x.x.x
  - community-ansible-dev-tools: installed
  - ansible-lint: installed

Next steps:
  1. Run: ansible-playbook site.yml
  2. Check logs: ~/.dotsible/logs/bootstrap_[timestamp].log
```

## 🎮 Enhanced Run Script (run-dotsible.sh)

The enhanced `run-dotsible.sh` script provides a user-friendly interface with interactive prompts and intelligent privilege escalation while maintaining full automation compatibility.

### Interactive Mode Features

#### Profile Selection with Descriptions
When running without arguments, users get guided profile selection:

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
```

#### Environment Type Selection
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
```

#### Intelligent Privilege Escalation
The script automatically detects when administrator privileges are needed:
- **macOS**: Requires sudo for developer/enterprise profiles (system packages)
- **Linux**: Always requires sudo for package management
- **Windows**: No sudo required (uses user-level package managers)

### Complete Help Output

```bash
./run-dotsible.sh --help
```

```
🚀 Dotsible - Cross-Platform Environment Setup

Usage: ./run-dotsible.sh [OPTIONS]

INTERACTIVE MODE:
    ./run-dotsible.sh                         Run with interactive prompts for profile and environment selection

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
    ./run-dotsible.sh

    # Direct execution with specified options
    ./run-dotsible.sh --profile developer --environment enterprise

    # Dry run to preview changes
    ./run-dotsible.sh --dry-run

    # Install only platform-specific packages
    ./run-dotsible.sh --tags platform_specific

    # Install fonts only
    ./run-dotsible.sh --tags fonts

    # Verbose output for debugging
    ./run-dotsible.sh --verbose

    # Install specific applications
    ./run-dotsible.sh --tags neovim,git,tmux

    # Install fonts and applications together
    ./run-dotsible.sh --tags fonts,applications

PROFILES:
    minimal     - Basic system setup with essential tools
    developer   - Full development environment with editors, languages, etc.
    enterprise  - Enterprise-ready setup with additional security and tools

ENVIRONMENT TYPES:
    personal    - Personal workstation configuration
    enterprise  - Enterprise/corporate environment settings

COMMON TAGS:
    platform_specific  - Platform-specific package installation and configuration
    applications       - Application installation and configuration
    fonts             - Font installation and management (Iosevka Nerd Font)
    dotfiles          - Dotfiles deployment with conditional logic
    neovim            - Neovim editor setup with dotfiles
    git               - Git configuration and dotfiles
    tmux              - Terminal multiplexer setup with dotfiles
    zsh               - Zsh shell configuration with oh-my-zsh and plugins
    window_manager    - Window manager configurations (Linux only)
```

### Usage Modes

#### 1. Interactive Mode (New Users)
```bash
# Run with interactive prompts
./run-dotsible.sh
```
- Guides through profile and environment selection
- Explains what each option includes
- Handles privilege escalation automatically
- Shows configuration summary before execution

#### 2. Direct Mode (Automation/Experienced Users)
```bash
# Specify all parameters directly
./run-dotsible.sh --profile developer --environment enterprise
```
- Skips interactive prompts
- Perfect for CI/CD pipelines
- Maintains backward compatibility

#### 3. Mixed Mode (Partial Automation)
```bash
# Specify some parameters, prompt for others
./run-dotsible.sh --profile developer
# Will prompt for environment type only

./run-dotsible.sh --environment personal
# Will prompt for profile only
```

#### 4. Preview Mode (Dry Run)
```bash
# See what would be changed without applying
./run-dotsible.sh --dry-run
./run-dotsible.sh --profile developer --environment personal --dry-run
```

#### 5. Debugging Mode
```bash
# Verbose output for troubleshooting
./run-dotsible.sh --verbose
./run-dotsible.sh --profile developer --environment personal --verbose
```

#### 6. Targeted Installation
```bash
# Install only specific components
./run-dotsible.sh --tags platform_specific
./run-dotsible.sh --tags neovim,git,tmux
./run-dotsible.sh --profile developer --tags applications
```

### Clean Output Features

The enhanced script provides clean, readable output with:
- ✅ **Clear status indicators** (INSTALLED, FAILED, SKIPPED, CHANGED)
- 📊 **Progress tracking** with section headers
- 📋 **Summary sections** for each major component
- 🔇 **Reduced verbose debug messages** (unless --verbose specified)
- 🎨 **Professional formatting** suitable for enterprise environments

#### Font Management Output Example
```
🔤 Font Management
Installing and configuring fonts for Darwin

Unzip utility: INSTALLED
Iosevka Nerd Font: MISSING
Iosevka download: COMPLETED
Iosevka extraction: COMPLETED
Iosevka installation: COMPLETED
Font cache: REFRESHED
✅ Font Management Complete
```

## 📚 Ansible Playbook Commands

After successful bootstrap, you can use either the enhanced `run-dotsible.sh` script (recommended) or direct Ansible commands for system configuration.

### Recommended: Enhanced Run Script

```bash
# Interactive mode (recommended for new users)
./run-dotsible.sh

# Direct mode (recommended for automation)
./run-dotsible.sh --profile developer --environment personal
./run-dotsible.sh --profile minimal --environment personal
./run-dotsible.sh --profile enterprise --environment enterprise
```

### Alternative: Direct Ansible Commands

```bash
# Basic execution with default profile (localhost)
ansible-playbook -i inventories/local/hosts.yml site.yml

# Specify profile explicitly
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=minimal
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=enterprise
```

### Platform-Specific Targeting

```bash
# Target specific platforms using inventory limits
ansible-playbook -i inventories/local/hosts.yml site.yml --limit macos_workstations
ansible-playbook -i inventories/local/hosts.yml site.yml --limit windows_workstations
ansible-playbook -i inventories/local/hosts.yml site.yml --limit archlinux_workstations
ansible-playbook -i inventories/local/hosts.yml site.yml --limit ubuntu_workstations

# Multiple platforms
ansible-playbook -i inventories/local/hosts.yml site.yml --limit "macos_workstations,ubuntu_workstations"
```

### Tag-Based Execution

#### Using Enhanced Run Script (Recommended)
```bash
# Install only platform-specific packages
./run-dotsible.sh --tags platform_specific

# Install fonts only
./run-dotsible.sh --tags fonts

# Configure applications only
./run-dotsible.sh --tags applications

# Specific applications
./run-dotsible.sh --tags "git,zsh,tmux"

# Fonts and applications together
./run-dotsible.sh --tags "fonts,applications"

# Multiple tags with profile
./run-dotsible.sh --profile developer --tags "platform_specific,applications,fonts"

# Interactive mode with specific tags
./run-dotsible.sh --tags neovim
```

#### Using Direct Ansible Commands
```bash
# Install only platform-specific packages
ansible-playbook -i inventories/local/hosts.yml site.yml --tags platform_specific

# Install fonts only
ansible-playbook -i inventories/local/hosts.yml site.yml --tags fonts

# Configure applications only
ansible-playbook -i inventories/local/hosts.yml site.yml --tags applications

# Setup profiles only
ansible-playbook -i inventories/local/hosts.yml site.yml --tags profiles

# Specific applications
ansible-playbook -i inventories/local/hosts.yml site.yml --tags "git,zsh,tmux"

# Fonts and applications together
ansible-playbook -i inventories/local/hosts.yml site.yml --tags "fonts,applications"

# Multiple tags
ansible-playbook -i inventories/local/hosts.yml site.yml --tags "platform_specific,applications,fonts"
```

### Environment-Specific Deployment

#### Using Enhanced Run Script (Recommended)
```bash
# Personal environment (interactive selection)
./run-dotsible.sh --environment personal

# Enterprise environment (interactive selection)
./run-dotsible.sh --environment enterprise

# Complete specification
./run-dotsible.sh --profile developer --environment personal
./run-dotsible.sh --profile enterprise --environment enterprise
```

#### Using Direct Ansible Commands
```bash
# Personal environment (default)
ansible-playbook -i inventories/local/hosts.yml site.yml -e environment_type=personal

# Enterprise environment
ansible-playbook -i inventories/local/hosts.yml site.yml -e environment_type=enterprise

# Custom window manager
ansible-playbook -i inventories/local/hosts.yml site.yml -e dotsible_window_manager=i3
ansible-playbook -i inventories/local/hosts.yml site.yml -e dotsible_window_manager=hyprland
```

### Dry-Run and Check Mode

#### Using Enhanced Run Script (Recommended)
```bash
# Check what would be changed (dry-run) - Interactive mode
./run-dotsible.sh --dry-run

# Dry-run with specific configuration
./run-dotsible.sh --profile developer --environment personal --dry-run

# Verbose output for debugging
./run-dotsible.sh --verbose
./run-dotsible.sh --profile developer --environment personal --verbose

# Combined dry-run and verbose
./run-dotsible.sh --profile developer --dry-run --verbose
```

#### Using Direct Ansible Commands
```bash
# Check what would be changed (dry-run)
ansible-playbook -i inventories/local/hosts.yml site.yml --check

# Show differences that would be made
ansible-playbook -i inventories/local/hosts.yml site.yml --check --diff

# Verbose output for debugging
ansible-playbook -i inventories/local/hosts.yml site.yml -v
ansible-playbook -i inventories/local/hosts.yml site.yml -vv  # More verbose
ansible-playbook -i inventories/local/hosts.yml site.yml -vvv # Maximum verbosity
```

### Cross-Platform Execution

#### Linux/macOS
```bash
# Enhanced run script (recommended)
./run-dotsible.sh

# Make executable if needed
chmod +x run-dotsible.sh
./run-dotsible.sh --profile developer
```

#### Windows
Dotsible supports Windows through multiple execution methods:

**Option 1: Windows Subsystem for Linux (WSL) - Recommended**
```bash
# Install WSL2 and Ubuntu
wsl --install

# Inside WSL
git clone <repository-url> dotsible
cd dotsible
./bootstrap.sh
./run-dotsible.sh
```

**Option 2: Git Bash**
```bash
# Using Git Bash terminal
./run-dotsible.sh --profile developer --environment personal
```

**Option 3: PowerShell with Direct Ansible**
```powershell
# After running bootstrap.ps1
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer -e environment_type=personal
```

**Note**: The enhanced `run-dotsible.sh` script is a bash script. Windows users should use WSL, Git Bash, or direct Ansible commands through PowerShell.

### Advanced Execution Options

```bash
# Skip specific tags
ansible-playbook -i inventories/local/hosts.yml site.yml --skip-tags backup

# Force handlers to run
ansible-playbook -i inventories/local/hosts.yml site.yml --force-handlers

# Start at specific task
ansible-playbook -i inventories/local/hosts.yml site.yml --start-at-task "Install Homebrew packages"

# Custom inventory
ansible-playbook -i custom_inventory.yml site.yml

# Extra variables from file
ansible-playbook -i inventories/local/hosts.yml site.yml -e @custom_vars.yml
```

## 🧪 Testing Commands

Comprehensive testing framework to validate installations and configurations.

### Bootstrap Infrastructure Tests

```bash
# Test bootstrap script existence and executability
./scripts/test_bootstrap.sh

# Test Python development tools integration
./scripts/test_python_dev_tools.sh

# Test Ansible Python dev tools integration
./scripts/test_ansible_python_dev_tools.sh
```

### Validation Tests

```bash
# Validate Ansible syntax
./tests/scripts/validate_syntax.sh

# Run integration tests
./tests/scripts/run_integration_tests.sh

# Comprehensive test suite
./tests/scripts/run_all_tests.sh
```

### Platform-Specific Tests

```bash
# Test idempotency
./scripts/test_idempotent.sh

# Validate Phase 3 implementation
./scripts/validate_phase3.sh
```

### Test Result Interpretation

✅ **Successful Test Output:**
```
🔍 Testing Bootstrap Infrastructure
==================================
✅ bootstrap.sh: Exists and executable
✅ scripts/bootstrap_macos.sh: Exists and executable
✅ scripts/bootstrap_windows.ps1: Exists
✅ scripts/bootstrap_archlinux.sh: Exists and executable
✅ scripts/bootstrap_ubuntu.sh: Exists and executable

🎉 Bootstrap infrastructure test completed!
```

❌ **Failed Test Indicators:**
- Missing executable permissions
- Syntax errors in playbooks
- Missing dependencies
- Platform-specific issues

## 🌐 Supported Platforms

### Platform Matrix

| Platform | Package Managers | Window Managers | Font Support | Status |
|----------|-----------------|-----------------|--------------|---------|
| **macOS** | Homebrew, pip, npm | Native (Aqua) | ✅ ~/Library/Fonts | ✅ Full Support |
| **Windows** | Chocolatey, Scoop, winget, pip | Native (DWM) | ✅ %LOCALAPPDATA%\Fonts | ✅ Full Support |
| **Arch Linux** | pacman, AUR (yay), pip | i3, Hyprland, Sway | ✅ ~/.local/share/fonts | ✅ Full Support |
| **Ubuntu** | apt, snap, flatpak, pip | i3, Hyprland, Sway, GNOME | ✅ ~/.local/share/fonts | ✅ Full Support |

### Package Manager Features

#### macOS (Homebrew)
- ✅ Homebrew packages (CLI tools)
- ✅ Homebrew casks (GUI applications)
- ✅ Mac App Store apps (via `mas`)
- ✅ Nerd Fonts (Iosevka) via direct download
- ✅ NPM global packages
- ✅ Python packages via pipx

#### Windows (Multi-Manager)
- ✅ Chocolatey packages
- ✅ Scoop packages
- ✅ Winget packages
- ✅ PowerShell modules
- ✅ Nerd Fonts (Iosevka) via direct download
- ✅ NPM global packages
- ✅ Python packages via pipx

#### Arch Linux (pacman + AUR)
- ✅ Official repository packages
- ✅ AUR packages via yay
- ✅ Development packages
- ✅ Window manager packages
- ✅ Font packages (system + Nerd Fonts)
- ✅ NPM global packages
- ✅ Python packages via pipx

#### Ubuntu (Multi-Manager)
- ✅ APT packages
- ✅ Snap packages
- ✅ Flatpak packages
- ✅ Development packages
- ✅ Font packages (system + Nerd Fonts)
- ✅ NPM global packages
- ✅ Python packages via pipx

## 🛠️ Development Tools Integration

### Python Development Toolkit

Dotsible integrates a comprehensive Python development toolkit managed through pipx for dependency isolation:

#### Core Tools
- **pipx** - Python package isolation tool
- **community-ansible-dev-tools** - Ansible development toolkit
- **ansible-lint** - Ansible linting and best practices

#### Installation Sequence
1. **Python 3.8+** validation
2. **pip** functionality check
3. **pipx** installation via pip
4. **community-ansible-dev-tools** installation via pipx
5. **ansible-lint** installation via pipx

#### Usage Examples
```bash
# List installed pipx packages
pipx list

# Verify development tools
community-ansible-dev-tools --version
ansible-lint --version

# Lint Ansible playbooks
ansible-lint site.yml

# Use development tools
community-ansible-dev-tools --help
```

### MCP (Model Context Protocol) Integration

Dotsible includes MCP packages for AI-enhanced development:

```bash
# Installed via NPM global packages
npm list -g | grep mcp

# Available MCP packages:
# - @modelcontextprotocol/server-brave-search
# - @modelcontextprotocol/server-puppeteer
# - firecrawl-mcp
```

## 🔤 Font Management

Dotsible provides comprehensive cross-platform font management with automatic installation of Nerd Fonts for enhanced terminal and development experiences.

### Supported Fonts

#### Iosevka Nerd Font (Primary)
- **Full Unicode Support**: Complete Unicode coverage with programming ligatures
- **Cross-Platform**: Consistent appearance across all supported platforms
- **Developer Optimized**: Designed specifically for programming and terminal use
- **Multiple Weights**: Regular, Bold, Italic, and BoldItalic variants

#### Future Font Support
- JetBrains Mono Nerd Font (planned)
- Fira Code Nerd Font (planned)
- Hack Nerd Font (planned)

### Platform-Specific Installation Paths

| Platform | User Font Directory | System Font Directory |
|----------|-------------------|----------------------|
| **macOS** | `~/Library/Fonts/` | `/Library/Fonts/` |
| **Windows** | `%LOCALAPPDATA%\Microsoft\Windows\Fonts\` | `C:\Windows\Fonts\` |
| **Arch Linux** | `~/.local/share/fonts/` | `/usr/share/fonts/` |
| **Ubuntu/Debian** | `~/.local/share/fonts/` | `/usr/share/fonts/` |

### Font Installation Features

#### Idempotent Installation
- **Check-Before-Install**: Automatically detects existing font installations
- **Skip Redundant Downloads**: Avoids re-downloading fonts that are already present
- **Status Reporting**: Clear indicators (✅ INSTALLED, ❌ MISSING, ⏭️ SKIPPED)

#### Automatic Dependency Management
- **Unzip Utility**: Automatically installs unzip if not present
- **Font Cache**: Refreshes system font cache after installation (Unix-like systems)
- **Platform Detection**: Uses appropriate package managers for dependencies

#### Profile-Based Selection
```yaml
# Font installation varies by profile
minimal:     # Iosevka only
  - iosevka

developer:   # Programming fonts
  - iosevka
  - jetbrains_mono

enterprise:  # Comprehensive font set
  - iosevka
  - jetbrains_mono
  - fira_code
```

### Usage Examples

#### Install Fonts Only
```bash
# Using enhanced run script (recommended)
./run-dotsible.sh --tags fonts

# Using direct Ansible command
ansible-playbook -i inventories/local/hosts.yml site.yml --tags fonts
```

#### Install Fonts with Specific Profile
```bash
# Developer profile with fonts
./run-dotsible.sh --profile developer --tags fonts

# Enterprise profile with comprehensive font set
./run-dotsible.sh --profile enterprise --tags fonts
```

#### Combined Installation
```bash
# Install fonts along with applications
./run-dotsible.sh --tags "fonts,applications"

# Complete setup including fonts
./run-dotsible.sh --profile developer --environment personal
```

#### Dry Run Font Installation
```bash
# Preview font installation without changes
./run-dotsible.sh --tags fonts --dry-run

# Verbose output for debugging
./run-dotsible.sh --tags fonts --verbose
```

### Font Installation Process

1. **Dependency Check**: Verifies unzip utility availability
2. **Font Detection**: Scans for existing Iosevka Nerd Font files
3. **Download**: Downloads font archive from GitHub releases (if needed)
4. **Extraction**: Extracts font files to temporary directory
5. **Installation**: Copies fonts to platform-specific directory
6. **Cache Refresh**: Updates system font cache (Unix-like systems)
7. **Cleanup**: Removes temporary files

### Verification

#### Check Font Installation
```bash
# Unix-like systems (macOS, Linux)
fc-list | grep -i iosevka

# List fonts in user directory
ls -la ~/Library/Fonts/*Iosevka*        # macOS
ls -la ~/.local/share/fonts/*Iosevka*   # Linux

# Windows PowerShell
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows\Fonts" -Filter "*Iosevka*"
```

#### Test Font in Terminal
```bash
# Test font rendering with special characters
echo "→ ← ↑ ↓ ≠ ≤ ≥ ∞ ∅ ∈ ∉ ∩ ∪ ⊂ ⊃ ⊆ ⊇"
echo "λ α β γ δ ε ζ η θ ι κ μ ν ξ π ρ σ τ υ φ χ ψ ω"
echo "Ligatures: -> => != <= >= === !== && ||"
```

### Troubleshooting Font Issues

#### Font Not Appearing in Applications
```bash
# Refresh font cache (Unix-like)
fc-cache -fv

# Restart applications to reload fonts
# Terminal applications may need restart
```

#### Download Failures
```bash
# Check internet connectivity
curl -I https://github.com/ryanoasis/nerd-fonts/releases/

# Manual font installation
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Iosevka.zip
unzip Iosevka.zip -d ~/.local/share/fonts/  # Linux
```

#### Permission Issues
```bash
# Ensure font directory exists and is writable
mkdir -p ~/.local/share/fonts  # Linux
chmod 755 ~/.local/share/fonts
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Bootstrap Issues

**Problem**: `Permission denied` on macOS
```bash
# Solution: Install Xcode Command Line Tools first
xcode-select --install
```

**Problem**: PowerShell execution policy on Windows
```powershell
# Solution: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Problem**: `sudo` password prompts
```bash
# Solution: Configure passwordless sudo (handled by bootstrap)
# Or run with NOPASSWD configuration
```

#### Enhanced Run Script Issues

**Problem**: `./run-dotsible.sh: Permission denied`
```bash
# Solution: Make script executable
chmod +x run-dotsible.sh
./run-dotsible.sh
```

**Problem**: Enhanced script not working on Windows
```bash
# Solution: Use WSL, Git Bash, or direct Ansible commands
# WSL (recommended)
wsl
./run-dotsible.sh

# Git Bash
./run-dotsible.sh --profile developer

# PowerShell (direct Ansible)
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer
```

**Problem**: Privilege escalation prompts during execution
```bash
# Solution: The script handles this automatically
# You'll be prompted for sudo password when needed
# For automation, use direct Ansible with --ask-become-pass
ansible-playbook -i inventories/local/hosts.yml site.yml --ask-become-pass
```

#### Ansible Issues

**Problem**: `ansible-playbook: command not found`
```bash
# Solution: Ensure PATH includes pip user bin
export PATH="$HOME/.local/bin:$PATH"  # Linux/macOS
# Or re-run bootstrap script
```

**Problem**: Package installation failures
```bash
# Solution: Update package managers first
brew update          # macOS
sudo pacman -Sy       # Arch Linux
sudo apt update       # Ubuntu
choco upgrade all     # Windows
```

#### Platform-Specific Issues

**macOS**: Rosetta 2 required for Apple Silicon
```bash
# Auto-handled by bootstrap, but manual installation:
softwareupdate --install-rosetta --agree-to-license
```

**Windows**: Missing Visual C++ Build Tools
```powershell
# Install via Chocolatey (handled by bootstrap)
choco install visualstudio2019buildtools
```

**Arch Linux**: AUR helper installation fails
```bash
# Manual yay installation
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

**Ubuntu**: Snap/Flatpak not working
```bash
# Restart snapd service
sudo systemctl restart snapd
# Re-add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### Debug Mode

#### Using Enhanced Run Script (Recommended)
```bash
# Verbose output for debugging
./run-dotsible.sh --verbose

# Dry-run with verbose output
./run-dotsible.sh --dry-run --verbose

# Specific profile with verbose debugging
./run-dotsible.sh --profile developer --environment personal --verbose
```

#### Using Direct Ansible Commands
```bash
# Enable verbose logging
export ANSIBLE_VERBOSITY=3
ansible-playbook -i inventories/local/hosts.yml site.yml -vvv

# Check bootstrap logs
tail -f ~/.dotsible/logs/bootstrap_*.log

# Validate configuration
ansible-playbook -i inventories/local/hosts.yml site.yml --syntax-check
```

#### Enhanced Script Logs
```bash
# Check execution logs
tail -f ~/.dotsible/execution.log

# View clean output in real-time
./run-dotsible.sh --profile developer | tee deployment.log
```

## 🗺️ Future Roadmap

### Planned Enhancements

#### AD-Scripts Integration (Phase 4)
- **Enterprise Windows Management**: Integration of PowerShell-based Active Directory scripts
- **Group Policy Automation**: Automated GPO configuration and compliance
- **Enterprise Security**: Advanced Windows security configurations
- **Note**: AD-Scripts integration is planned but **not essential** for current Dotsible functionality

#### Additional Features
- **Container Support**: Docker and Podman configuration management
- **Cloud Integration**: AWS, Azure, GCP development environment setup
- **IDE Configurations**: VSCode, IntelliJ, and other IDE automation
- **Security Hardening**: Platform-specific security configurations
- **Backup and Restore**: Automated configuration backup and restoration

### Contributing

Dotsible is designed for extensibility. Key areas for contribution:
- Additional platform support (FreeBSD, openSUSE, etc.)
- New application roles
- Enhanced testing frameworks
- Documentation improvements

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Documentation**: Check the `docs/` directory for detailed guides
- **Issues**: Report bugs and feature requests via GitHub Issues
- **Testing**: Use the comprehensive test suite in `tests/`

---

**Dotsible** - *Unified Cross-Platform Developer Environment Restoration* 🚀
