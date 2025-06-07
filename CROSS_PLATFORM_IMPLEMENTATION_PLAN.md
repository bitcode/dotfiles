# Cross-Platform Developer Environment Implementation Plan

## Executive Summary

This document outlines the implementation strategy for creating a unified cross-platform developer environment restoration system by merging three repositories and extending to support Windows, macOS, Arch Linux, and Ubuntu across both personal and enterprise environments.

## 1. Architecture Overview

### 1.1 Unified Repository Structure

```
unified-dotfiles/
├── 📄 README.md                          # Comprehensive cross-platform guide
├── 📄 bootstrap.sh                       # Universal bootstrap script
├── 📄 bootstrap.ps1                      # Windows PowerShell bootstrap
├── 📄 ansible.cfg                        # Ansible configuration
├── 📄 requirements.yml                   # Ansible Galaxy requirements
│
├── 📁 ansible/                           # Ansible automation
│   ├── 📄 site.yml                      # Main orchestration playbook
│   ├── 📄 macos.yml                     # macOS-specific playbook (current foundation)
│   ├── 📄 windows.yml                   # Windows-specific playbook
│   ├── 📄 archlinux.yml                 # Arch Linux playbook
│   ├── 📄 ubuntu.yml                    # Ubuntu playbook
│   └── 📄 enterprise.yml                # Enterprise environment playbook
│
├── 📁 roles/                             # Cross-platform Ansible roles
│   ├── 📁 common/                       # Base system configuration
│   ├── 📁 package_manager/              # Cross-platform package management
│   ├── 📁 dotfiles/                     # Dotfiles management
│   ├── 📁 applications/                 # Application-specific roles
│   ├── 📁 environments/                 # Environment-specific configurations
│   │   ├── 📁 personal/                # Personal environment setup
│   │   └── 📁 enterprise/              # Enterprise environment setup
│   └── 📁 platform_specific/           # Platform-specific roles
│       ├── 📁 macos/                   # macOS-specific roles
│       ├── 📁 windows/                 # Windows-specific roles
│       ├── 📁 archlinux/               # Arch Linux-specific roles
│       └── 📁 ubuntu/                  # Ubuntu-specific roles
│
├── 📁 powershell/                        # Windows PowerShell integration
│   ├── 📁 ad-scripts/                   # Integrated AD-Scripts functionality
│   ├── 📁 modules/                     # PowerShell modules
│   ├── 📁 profiles/                    # PowerShell profiles
│   └── 📁 environment/                 # Environment configuration
│
├── 📁 inventory/                         # Ansible inventories
│   ├── 📁 personal/                     # Personal environment inventory
│   ├── 📁 enterprise/                  # Enterprise environment inventory
│   └── 📁 local/                       # Local machine inventory
│
├── 📁 group_vars/                        # Platform and environment variables
│   ├── 📁 all/                          # Global variables
│   │   ├── 📄 main.yml                 # Main configuration
│   │   ├── 📄 packages.yml             # Cross-platform package definitions
│   │   ├── 📄 applications.yml         # Application configurations
│   │   └── 📄 environments.yml         # Environment-specific settings
│   ├── 📄 macos.yml                    # macOS-specific variables
│   ├── 📄 windows.yml                  # Windows-specific variables
│   ├── 📄 archlinux.yml                # Arch Linux-specific variables
│   ├── 📄 ubuntu.yml                   # Ubuntu-specific variables
│   ├── 📄 personal.yml                 # Personal environment variables
│   └── 📄 enterprise.yml               # Enterprise environment variables
│
├── 📁 templates/                         # Configuration templates
│   ├── 📁 common/                       # Cross-platform templates
│   ├── 📁 macos/                       # macOS-specific templates
│   ├── 📁 windows/                     # Windows-specific templates
│   ├── 📁 linux/                       # Linux-specific templates
│   └── 📁 enterprise/                  # Enterprise-specific templates
│
├── 📁 files/                            # Static configuration files
│   ├── 📁 dotfiles/                     # Original dotfiles (preserved)
│   ├── 📁 scripts/                     # Utility scripts
│   └── 📁 configs/                     # Platform-specific configs
│
├── 📁 tests/                            # Testing framework
│   ├── 📁 integration/                 # Cross-platform integration tests
│   ├── 📁 platform/                   # Platform-specific tests
│   └── 📁 enterprise/                 # Enterprise environment tests
│
└── 📁 docs/                             # Comprehensive documentation
    ├── 📄 USAGE.md                     # Usage guide
    ├── 📄 PLATFORMS.md                 # Platform-specific guides
    ├── 📄 ENTERPRISE.md                # Enterprise deployment guide
    ├── 📄 MIGRATION.md                 # Migration from existing systems
    └── 📄 TROUBLESHOOTING.md           # Cross-platform troubleshooting
```

### 1.2 Cross-Platform Package Management Strategy

Building on the proven macOS approach from `ansible/macsible.yaml`:

```yaml
# group_vars/all/packages.yml - Cross-platform package inventory
cross_platform_packages:
  development_tools:
    git:
      macos: "git"
      windows: "git"
      archlinux: "git"
      ubuntu: "git"
    
    nodejs:
      macos: "node"
      windows: "nodejs"
      archlinux: "nodejs"
      ubuntu: "nodejs"
    
    python:
      macos: "python@3.11"
      windows: "python"
      archlinux: "python"
      ubuntu: "python3"

  terminal_tools:
    starship:
      macos: "starship"
      windows: "starship"
      archlinux: "starship"
      ubuntu: "starship"
    
    tmux:
      macos: "tmux"
      windows: null  # Not applicable
      archlinux: "tmux"
      ubuntu: "tmux"

# MCP packages (extending current implementation)
npm_global_packages:
  - "@modelcontextprotocol/server-brave-search"
  - "@modelcontextprotocol/server-puppeteer"
  - "firecrawl-mcp"
  - "typescript"
  - "nodemon"
  # ... other packages from current implementation
```

## 2. Implementation Phases

### Phase 1: Foundation and Integration (Weeks 1-2)

#### 2.1 Repository Consolidation
1. **Preserve current dotfiles as foundation**
   - Keep proven `ansible/macsible.yaml` as template
   - Maintain idempotent package management patterns
   - Preserve MCP integration

2. **Integrate AD-Scripts repository**
   - Move AD-Scripts to `powershell/ad-scripts/`
   - Preserve environment configuration system
   - Maintain security practices

3. **Create unified structure**
   - Establish cross-platform directory layout
   - Create platform-specific playbooks
   - Set up environment detection logic

#### 2.2 Cross-Platform Bootstrap System
```bash
# bootstrap.sh - Universal bootstrap script
#!/bin/bash
set -euo pipefail

detect_platform() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/arch-release ]]; then
                echo "archlinux"
            elif [[ -f /etc/lsb-release ]] && grep -q "Ubuntu" /etc/lsb-release; then
                echo "ubuntu"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

detect_environment() {
    # Enterprise detection logic
    if [[ -n "${DOMAIN:-}" ]] || [[ -n "${USERDNSDOMAIN:-}" ]]; then
        echo "enterprise"
    else
        echo "personal"
    fi
}

main() {
    local platform=$(detect_platform)
    local environment=$(detect_environment)
    
    echo "🔍 Detected platform: $platform"
    echo "🏢 Detected environment: $environment"
    
    case "$platform" in
        macos)
            ./scripts/bootstrap_macos.sh "$environment"
            ;;
        windows)
            powershell -ExecutionPolicy Bypass -File bootstrap.ps1 -Environment "$environment"
            ;;
        archlinux)
            ./scripts/bootstrap_archlinux.sh "$environment"
            ;;
        ubuntu)
            ./scripts/bootstrap_ubuntu.sh "$environment"
            ;;
        *)
            echo "❌ Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

main "$@"
```

### Phase 2: Platform-Specific Implementation (Weeks 3-4)

#### 2.1 Windows Integration Strategy
Hybrid approach combining Ansible and PowerShell:

```yaml
# ansible/windows.yml - Windows-specific playbook
---
- name: Windows Developer Environment Setup
  hosts: windows
  gather_facts: yes
  
  vars:
    environment_type: "{{ environment | default('personal') }}"
    
  tasks:
    - name: Setup PowerShell environment
      include_role:
        name: platform_specific/windows/powershell_setup
    
    - name: Configure AD environment (Enterprise only)
      include_role:
        name: platform_specific/windows/ad_integration
      when: environment_type == "enterprise"
    
    - name: Install development tools
      include_role:
        name: package_manager
      vars:
        package_manager_type: "chocolatey"
    
    - name: Setup dotfiles
      include_role:
        name: dotfiles
      vars:
        dotfiles_platform: "windows"
```

#### 2.2 Linux Distribution Support
Extending the macOS patterns to Linux:

```yaml
# ansible/archlinux.yml - Arch Linux playbook
---
- name: Arch Linux Developer Environment Setup
  hosts: archlinux
  gather_facts: yes
  
  tasks:
    - name: Update system
      pacman:
        update_cache: yes
        upgrade: yes
      become: yes
    
    - name: Install base packages
      include_role:
        name: package_manager
      vars:
        package_manager_type: "pacman"
    
    - name: Install AUR packages
      include_role:
        name: platform_specific/archlinux/aur_manager
    
    - name: Setup window manager
      include_role:
        name: applications/window_manager
      when: "'gui' in features"
```

### Phase 3: Enterprise Environment Support (Weeks 5-6)

#### 3.1 Enterprise Windows Integration
```yaml
# roles/environments/enterprise/tasks/main.yml
---
- name: Configure enterprise restrictions
  include_tasks: configure_restrictions.yml

- name: Setup AD integration (Windows only)
  include_tasks: setup_ad_integration.yml
  when: ansible_os_family == "Windows"

- name: Configure enterprise security
  include_tasks: configure_security.yml

- name: Setup monitoring and compliance
  include_tasks: setup_monitoring.yml
```

#### 3.2 Conditional Dotfile Deployment
```yaml
# roles/dotfiles/tasks/main.yml
---
- name: Determine dotfiles configuration
  set_fact:
    dotfiles_config:
      platform: "{{ ansible_os_family | lower }}"
      environment: "{{ environment_type }}"
      window_manager: "{{ window_manager | default('none') }}"
      restrictions: "{{ enterprise_restrictions | default({}) }}"

- name: Deploy platform-specific dotfiles
  include_tasks: "deploy_{{ dotfiles_config.platform }}.yml"

- name: Apply environment restrictions
  include_tasks: apply_restrictions.yml
  when: dotfiles_config.environment == "enterprise"
```

## 3. Key Features and Benefits

### 3.1 Unified Software Inventory
Extending the proven macOS approach:
- **Cross-platform package mapping**: Single inventory, multiple package managers
- **Environment-aware installation**: Different packages for personal vs enterprise
- **Idempotent operations**: Safe to run repeatedly across all platforms

### 3.2 Enterprise Environment Handling
- **Hostname restrictions**: Handle inability to change hostname in enterprise
- **Credential management**: Secure handling of enterprise credentials
- **Policy compliance**: Respect corporate policies and restrictions
- **AD integration**: Seamless Active Directory management on Windows

### 3.3 Conditional Configuration
- **OS-specific dotfiles**: Different configurations per operating system
- **Window manager support**: i3, Hyprland, Sway for Linux environments
- **Environment adaptation**: Personal vs enterprise configurations
- **Feature detection**: Conditional features based on system capabilities

This implementation plan provides a roadmap for creating a comprehensive, cross-platform developer environment restoration system that builds upon the proven macOS foundation while integrating enterprise Windows capabilities and extending to Linux distributions.
