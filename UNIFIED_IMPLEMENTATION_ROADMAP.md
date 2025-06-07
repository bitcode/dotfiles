# Unified Cross-Platform Developer Environment Implementation Roadmap

## Executive Summary

This roadmap outlines the step-by-step implementation for merging three repositories into a unified cross-platform developer environment restoration system:

1. **Current dotfiles** (`/Users/mdrozrosario/dotfiles`) - Enhanced macOS foundation
2. **Dotsible** (`/Users/mdrozrosario/dotsible`) - Sophisticated Ansible architecture  
3. **AD-Scripts** (`/Users/mdrozrosario/AD-Scripts`) - Enterprise Windows toolkit

**Target**: Single repository supporting Windows, macOS, Arch Linux, Ubuntu across personal and enterprise environments.

## Phase 1: Repository Analysis and Foundation (Week 1)

### 1.1 Complete Repository Assessment

#### Current State Analysis
- ✅ **Current dotfiles**: Proven macOS automation with MCP integration
- ✅ **Dotsible**: Production-ready cross-platform architecture
- ✅ **AD-Scripts**: Enterprise Windows PowerShell toolkit

#### Key Integration Points
- **Package Management**: Extend current macOS idempotent approach to all platforms
- **Enterprise Support**: Integrate AD-Scripts for Windows enterprise environments
- **Architecture**: Adopt dotsible's role-based structure
- **Configuration**: Preserve current battle-tested dotfiles

### 1.2 Foundation Setup Tasks

#### Repository Consolidation
```bash
# 1. Create unified repository structure
mkdir unified-dotfiles
cd unified-dotfiles

# 2. Initialize with current dotfiles as foundation
cp -r /Users/mdrozrosario/dotfiles/* .

# 3. Integrate dotsible architecture
cp -r /Users/mdrozrosario/dotsible/roles .
cp -r /Users/mdrozrosario/dotsible/group_vars .
cp -r /Users/mdrozrosario/dotsible/inventories .
cp /Users/mdrozrosario/dotsible/site.yml .
cp /Users/mdrozrosario/dotsible/ansible.cfg .

# 4. Integrate AD-Scripts
mkdir -p powershell/ad-scripts
cp -r /Users/mdrozrosario/AD-Scripts/* powershell/ad-scripts/
```

#### Architecture Integration
- **Preserve**: Current `ansible/macsible.yaml` as macOS foundation
- **Adopt**: Dotsible's role-based structure and site.yml orchestration
- **Integrate**: AD-Scripts into `powershell/ad-scripts/` directory
- **Enhance**: Cross-platform package management based on current macOS patterns

### 1.3 Cross-Platform Package Management Strategy

Building on the proven macOS approach:

```yaml
# group_vars/all/packages.yml - Unified package inventory
cross_platform_packages:
  development_tools:
    git:
      macos: "git"
      windows: "git"
      archlinux: "git" 
      ubuntu: "git"
    
    nodejs_lts:
      macos: "node"  # via homebrew
      windows: "nodejs"  # via chocolatey
      archlinux: "nodejs"  # via pacman
      ubuntu: "nodejs"  # via apt

# Extend current MCP packages approach
npm_global_packages:
  - "@modelcontextprotocol/server-brave-search"
  - "@modelcontextprotocol/server-puppeteer"
  - "firecrawl-mcp"
  - "typescript"
  - "nodemon"
  # ... other packages from current implementation

# Platform-specific package managers
package_managers:
  macos: "homebrew"
  windows: "chocolatey"
  archlinux: "pacman"
  ubuntu: "apt"
```

## Phase 2: Cross-Platform Playbook Development (Week 2)

### 2.1 Platform-Specific Playbooks

#### macOS Playbook (Foundation)
```yaml
# ansible/macos.yml - Enhanced current macsible.yaml
---
- name: macOS Developer Environment Setup
  hosts: macos
  gather_facts: yes
  vars:
    environment_type: "{{ environment | default('personal') }}"
  
  tasks:
    # Use current proven implementation as foundation
    - import_tasks: ../ansible/macsible.yaml
    
    # Add enterprise features when needed
    - include_role:
        name: environments/enterprise
      when: environment_type == "enterprise"
```

#### Windows Playbook (AD-Scripts Integration)
```yaml
# ansible/windows.yml - Hybrid Ansible + PowerShell
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
      win_shell: |
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        & "{{ playbook_dir }}/../powershell/ad-scripts/Load-ADEnvironment.ps1"
      when: environment_type == "enterprise"
    
    - name: Install development tools
      include_role:
        name: package_manager
      vars:
        package_manager_type: "chocolatey"
```

#### Linux Playbooks (Dotsible Foundation)
```yaml
# ansible/archlinux.yml - Arch Linux with AUR support
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
    
    - name: Install packages
      include_role:
        name: package_manager
      vars:
        package_manager_type: "pacman"
    
    - name: Install AUR packages
      include_role:
        name: platform_specific/archlinux/aur_manager
```

### 2.2 Environment Detection and Conditional Logic

#### Universal Bootstrap Script
```bash
#!/bin/bash
# bootstrap.sh - Universal cross-platform bootstrap

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
    
    # Install Ansible if needed
    if ! command -v ansible-playbook &> /dev/null; then
        case "$platform" in
            macos) ./install-ansible.sh ;;
            *) echo "Please install Ansible manually" ;;
        esac
    fi
    
    # Run platform-specific playbook
    ansible-playbook -c local -i localhost, \
        ansible/${platform}.yml \
        -e environment="$environment"
}

main "$@"
```

## Phase 3: Enterprise Environment Integration (Week 3)

### 3.1 Enterprise Windows Integration

#### AD-Scripts Integration Strategy
```yaml
# roles/environments/enterprise/tasks/windows.yml
---
- name: Ensure PowerShell execution policy
  win_shell: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

- name: Load AD environment configuration
  win_shell: |
    & "{{ playbook_dir }}/../../powershell/ad-scripts/Load-ADEnvironment.ps1"
  register: ad_environment_result

- name: Configure AD user management
  win_shell: |
    & "{{ playbook_dir }}/../../powershell/ad-scripts/user-management/Get-UserInfo.ps1" -Username "{{ ansible_user }}"
  when: ad_environment_result.rc == 0

- name: Setup enterprise security policies
  include_tasks: security_policies.yml
```

#### Enterprise Environment Variables
```yaml
# group_vars/enterprise.yml
enterprise_restrictions:
  hostname_change: false
  admin_rights: limited
  software_installation: restricted
  
enterprise_software:
  required:
    - "Microsoft Office"
    - "Outlook"
    - "Teams"
  optional:
    - "Visual Studio Code"
    - "Git"
    - "PowerShell Core"

ad_integration:
  enabled: true
  domain_join: automatic
  group_policy: enforce
```

### 3.2 Conditional Dotfile Deployment

#### Environment-Aware Configuration
```yaml
# roles/dotfiles/tasks/main.yml
---
- name: Determine configuration context
  set_fact:
    config_context:
      platform: "{{ ansible_os_family | lower }}"
      environment: "{{ environment_type }}"
      window_manager: "{{ window_manager | default('none') }}"
      restrictions: "{{ enterprise_restrictions | default({}) }}"

- name: Deploy base dotfiles
  include_tasks: "deploy_{{ config_context.platform }}.yml"

- name: Apply environment-specific restrictions
  include_tasks: apply_restrictions.yml
  when: config_context.environment == "enterprise"

- name: Configure window manager (Linux only)
  include_tasks: "configure_{{ config_context.window_manager }}.yml"
  when: 
    - config_context.platform in ['archlinux', 'ubuntu']
    - config_context.window_manager != 'none'
```

## Phase 4: Testing and Validation (Week 4)

### 4.1 Comprehensive Testing Strategy

#### Multi-Platform Testing
```bash
# tests/integration/cross_platform_test.sh
#!/bin/bash

test_platforms=("macos" "ubuntu" "archlinux" "windows")
test_environments=("personal" "enterprise")

for platform in "${test_platforms[@]}"; do
    for environment in "${test_environments[@]}"; do
        echo "Testing $platform with $environment environment..."
        
        # Run syntax check
        ansible-playbook --syntax-check \
            ansible/${platform}.yml \
            -e environment="$environment"
        
        # Run dry run
        ansible-playbook --check --diff \
            ansible/${platform}.yml \
            -e environment="$environment"
    done
done
```

#### Idempotency Validation
```bash
# tests/validation/idempotency_test.sh
#!/bin/bash

# Run playbook twice and ensure no changes on second run
echo "First run..."
ansible-playbook -c local -i localhost, ansible/macos.yml

echo "Second run (should show no changes)..."
ansible-playbook -c local -i localhost, ansible/macos.yml | tee second_run.log

# Check for changed=0 in output
if grep -q "changed=0" second_run.log; then
    echo "✅ Idempotency test passed"
else
    echo "❌ Idempotency test failed"
    exit 1
fi
```

### 4.2 Success Criteria

#### Technical Validation
- ✅ All platforms install successfully
- ✅ Idempotency maintained across all playbooks
- ✅ Enterprise restrictions properly enforced
- ✅ Cross-platform package management working
- ✅ MCP packages install correctly on all platforms

#### User Experience Validation
- ✅ Single command setup works
- ✅ Environment detection accurate
- ✅ Clear error messages and troubleshooting
- ✅ Documentation comprehensive
- ✅ Migration path from existing systems clear

## Expected Outcomes

### Unified Capabilities
- **Cross-Platform**: Single repository supports Windows, macOS, Arch Linux, Ubuntu
- **Environment-Aware**: Automatic detection and configuration for personal vs enterprise
- **Enterprise-Ready**: Full Windows AD integration and policy compliance
- **Idempotent**: Safe to run repeatedly without side effects
- **Extensible**: Easy to add new platforms, applications, and configurations

### Key Benefits
- **Reduced Complexity**: Single system instead of three separate repositories
- **Improved Reliability**: Proven patterns extended across all platforms
- **Enterprise Support**: Professional-grade Windows environment management
- **Consistent Experience**: Unified approach across all development environments
- **Future-Proof**: Extensible architecture for new requirements

This roadmap provides a clear path to creating a comprehensive, cross-platform developer environment restoration system that combines the best aspects of all three repositories while maintaining the proven reliability of the current macOS implementation.
