# Cross-Platform Development Tools Implementation

## Overview

This document describes the implementation of cross-platform installation support for essential development tools in the dotsible Ansible roles. The implementation ensures consistent availability of debugging and search tools across all supported platforms.

## Tools Added

### 1. **gdb** (GNU Debugger)
- **Purpose**: Essential debugging tool for C/C++ development
- **Verification**: `gdb --version`

### 2. **ripgrep** (rg)
- **Purpose**: Fast text search tool, replacement for grep
- **Verification**: `rg --version`

### 3. **fd-find** (fd)
- **Purpose**: Fast file finder, replacement for find
- **Verification**: `fd --version`

### 4. **fzf** (Fuzzy Finder)
- **Purpose**: Command-line fuzzy finder for interactive searching
- **Verification**: `fzf --version`

## Platform-Specific Implementation

### macOS (Homebrew)
**File**: `roles/platform_specific/macos/vars/main.yml`
```yaml
homebrew_packages:
  - ripgrep
  - fd
  - fzf
  # ... other packages

development_tools:
  - gdb
  # ... other tools
```

### Windows (Multiple Package Managers)
**File**: `roles/platform_specific/windows/vars/main.yml`
```yaml
# Chocolatey packages
development_tools_chocolatey:
  - ripgrep
  - fd

# Winget packages  
winget_packages:
  - BurntSushi.ripgrep.MSVC
  - sharkdp.fd

# Scoop packages
scoop_packages:
  - fzf
  - gdb

# Cargo packages (Rust)
cargo_packages:
  - ripgrep
  - fd-find
```

### Ubuntu/Debian (APT)
**File**: `roles/platform_specific/ubuntu/vars/main.yml`
```yaml
apt_packages:
  - ripgrep
  - fd-find
  - fzf

assembler_packages:
  - gdb
```

### Arch Linux (Pacman)
**File**: `roles/platform_specific/archlinux/vars/main.yml`
```yaml
pacman_packages:
  - ripgrep
  - fd
  - fzf

assembler_packages:
  - gdb
```

## Idempotent Installation Patterns

### Check-Before-Install Logic
All platforms implement idempotent checks using appropriate verification commands:

- **macOS**: `brew list <package>`
- **Windows**: `choco list --local-only`, `winget list`, `scoop list`
- **Ubuntu**: `dpkg -l | grep <package>`
- **Arch**: `pacman -Q <package>`

### Status Indicators
Consistent visual feedback across all platforms:
- ✅ **INSTALLED/ACCESSIBLE**: Tool is available
- ❌ **MISSING/NOT ACCESSIBLE**: Tool needs installation
- ⏭️ **SKIPPED**: Already installed, no action needed
- 🔄 **CHANGED**: Newly installed

## Verification System

### Post-Installation Verification
Each platform includes verification tasks that test tool accessibility:

```yaml
- name: Verify essential development tools are accessible
  shell: "{{ item.command }}"
  register: essential_tools_verify
  failed_when: false
  changed_when: false
  loop:
    - { name: "gdb", command: "gdb --version" }
    - { name: "ripgrep", command: "rg --version" }
    - { name: "fd", command: "fd --version" }
    - { name: "fzf", command: "fzf --version" }
```

### Cross-Platform Package Name Mapping
Handles different package names across platforms:

| Tool | macOS | Windows | Ubuntu | Arch |
|------|-------|---------|--------|------|
| ripgrep | ripgrep | ripgrep | ripgrep | ripgrep |
| fd | fd | fd | fd-find | fd |
| fzf | fzf | fzf | fzf | fzf |
| gdb | gdb | gdb (scoop) | gdb | gdb |

## Testing

### Test Playbook
Use `test-development-tools.yml` to verify installation:

```bash
ansible-playbook test-development-tools.yml
```

### Expected Output
The test will show:
- Platform detection
- Tool accessibility status
- Version information for accessible tools
- Summary of missing tools (if any)

## Integration with Existing Structure

### Variable Structure Consistency
Follows existing patterns in `vars/main.yml` files:
- Grouped by package manager
- Consistent naming conventions
- Platform-specific package lists

### Task Implementation
Integrated into existing task flows:
- Added after development package installation
- Uses existing error handling patterns
- Maintains clean output formatting

## Benefits

1. **Consistency**: Same tools available across all platforms
2. **Idempotency**: Safe to run multiple times
3. **Verification**: Post-installation checks ensure tools work
4. **Flexibility**: Multiple installation methods per platform
5. **Maintainability**: Clear separation by platform and package manager

## Usage

These tools are automatically installed when running the platform-specific roles:

```bash
# macOS
ansible-playbook -i inventory site.yml --tags macos

# Windows  
ansible-playbook -i inventory site.yml --tags windows

# Ubuntu
ansible-playbook -i inventory site.yml --tags ubuntu

# Arch Linux
ansible-playbook -i inventory site.yml --tags archlinux
```

The tools will be available in the system PATH after installation and can be used immediately for development workflows.
