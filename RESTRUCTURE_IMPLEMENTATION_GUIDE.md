# Dotfiles Restructuring Implementation Guide

## Overview

This guide provides step-by-step instructions for restructuring your dotfiles repository to prepare for merger with dotsible. Each step includes specific commands and validation procedures.

## Pre-Implementation Checklist

### 1. Backup Current Repository
```bash
# Create a complete backup
cd /Users/mdrozrosario
cp -r dotfiles dotfiles-backup-$(date +%Y%m%d)

# Create git backup branch
cd dotfiles
git checkout -b backup-pre-restructure
git add -A
git commit -m "Backup before restructuring for dotsible merger"
git push origin backup-pre-restructure
```

### 2. Analyze Current Structure
```bash
# Document current structure
find . -type f -name "*.yaml" -o -name "*.yml" -o -name "*.conf" -o -name "*.config" | head -20
ls -la ansible/
ls -la scripts/
```

## Phase 1: Directory Structure Creation

### 1.1 Create Dotsible-Compatible Structure
```bash
# Create main directories
mkdir -p {roles,group_vars,host_vars,inventories,templates,files,tests,docs}
mkdir -p roles/{applications,platform_specific,profiles,common,package_manager}
mkdir -p files/dotfiles
mkdir -p group_vars/all
mkdir -p inventories/{local,development,production}
mkdir -p templates/{common,macos,linux,windows}
mkdir -p tests/{roles,integration,validation}

# Create application-specific role directories
mkdir -p roles/applications/{git,zsh,tmux,neovim,alacritty,starship,i3,hyprland,sway}

# Create platform-specific role directories  
mkdir -p roles/platform_specific/{macos,archlinux,ubuntu,nixos,windows}

# Create profile directories
mkdir -p roles/profiles/{minimal,developer,server,enterprise,nixos}
```

### 1.2 Create Core Configuration Files
```bash
# Create ansible.cfg
cat > ansible.cfg << 'EOF'
[defaults]
host_key_checking = False
inventory = inventories/local/hosts.yml
roles_path = roles
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections
interpreter_python = auto_silent
gathering = smart
fact_caching = memory
stdout_callback = yaml
bin_ansible_callbacks = True

[inventory]
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
EOF

# Create requirements.yml
cat > requirements.yml << 'EOF'
---
collections:
  - name: community.general
    version: ">=3.0.0"
  - name: ansible.posix
    version: ">=1.0.0"
  - name: community.crypto
    version: ">=1.0.0"

roles: []
EOF
```

## Phase 2: Configuration Migration

### 2.1 Migrate Application Configurations
```bash
# Move application configs to files/dotfiles/
mv nvim files/dotfiles/
mv tmux files/dotfiles/
mv zsh files/dotfiles/
mv alacritty files/dotfiles/
mv i3 files/dotfiles/
mv hyprland files/dotfiles/
mv starship files/dotfiles/
mv vim files/dotfiles/
mv ranger files/dotfiles/
mv rofi files/dotfiles/
mv waybar files/dotfiles/
mv swaync files/dotfiles/
mv polybar files/dotfiles/
mv picom files/dotfiles/
mv compton files/dotfiles/
mv wofi files/dotfiles/
mv zellij files/dotfiles/
```

### 2.2 Create Application Roles
```bash
# Create neovim role structure
mkdir -p roles/applications/neovim/{tasks,handlers,templates,vars,files,meta}

# Create neovim role main task
cat > roles/applications/neovim/tasks/main.yml << 'EOF'
---
# Neovim installation and configuration role
- name: Install Neovim
  package:
    name: neovim
    state: present
  become: yes
  when: ansible_os_family != "Darwin"

- name: Install Neovim on macOS
  homebrew:
    name: neovim
    state: present
  when: ansible_os_family == "Darwin"

- name: Create Neovim config directory
  file:
    path: "{{ ansible_user_dir }}/.config/nvim"
    state: directory
    mode: '0755'

- name: Deploy Neovim configuration
  copy:
    src: "{{ item }}"
    dest: "{{ ansible_user_dir }}/.config/nvim/"
    mode: '0644'
  with_fileglob:
    - "{{ playbook_dir }}/files/dotfiles/nvim/*"
  notify: restart neovim
EOF

# Create neovim role meta
cat > roles/applications/neovim/meta/main.yml << 'EOF'
---
dependencies: []
galaxy_info:
  author: mdrozrosario
  description: Neovim configuration management
  license: MIT
  min_ansible_version: 2.9
  platforms:
    - name: Ubuntu
      versions: [18.04, 20.04, 22.04]
    - name: MacOSX
      versions: [10.15, 11.0, 12.0]
    - name: ArchLinux
      versions: [any]
EOF
```

### 2.3 Extract macOS Platform Role
```bash
# Create macOS platform role
mkdir -p roles/platform_specific/macos/{tasks,handlers,templates,vars,files,meta}

# Extract package management from macsible.yaml
cat > roles/platform_specific/macos/vars/main.yml << 'EOF'
---
# macOS-specific variables extracted from macsible.yaml
homebrew_packages:
  - powershell
  - starship
  - tmux
  - stow
  - ranger
  - sesh
  - git
  - docker
  - kubectl
  - python@3.11

homebrew_casks:
  - visual-studio-code
  - iterm2
  - docker

mac_app_store_apps:
  - name: "Xcode"
    path: "/Applications/Xcode.app"
  - name: "Keynote"
    path: "/Applications/Keynote.app"

manual_installations:
  - name: "Rust"
    check_command: "rustc --version"
    install_creates: "~/.cargo/bin/rustc"
  - name: "Node Version Manager (nvm)"
    check_path: "~/.nvm/nvm.sh"
  - name: "Go"
    check_command: "go version"
    version_pattern: "go1.21"
  - name: "Zellij"
    check_command: "zellij --version"
    install_creates: "/usr/local/bin/zellij"

npm_global_packages:
  - "@angular/cli"
  - "create-react-app"
  - "typescript"
  - "ts-node"
  - "nodemon"
  - "pm2"
  - "yarn"
  - "pnpm"
  - "eslint"
  - "prettier"
  - "http-server"
  - "live-server"
  - "@modelcontextprotocol/server-brave-search"
  - "@modelcontextprotocol/server-puppeteer"
  - "firecrawl-mcp"
EOF
```

## Phase 3: Create Main Playbook

### 3.1 Create Site Playbook
```bash
cat > site.yml << 'EOF'
---
# Main site playbook for restructured dotfiles
- name: Cross-Platform Development Environment Setup
  hosts: localhost
  gather_facts: yes
  become: no
  vars:
    profile: "{{ profile | default('developer') }}"
    
  pre_tasks:
    - name: Display configuration banner
      debug:
        msg: |
          ╔══════════════════════════════════════════════════════════════╗
          ║                    DOTFILES CONFIGURATION                   ║
          ║              Cross-Platform Development Setup               ║
          ╚══════════════════════════════════════════════════════════════╝
          
          🖥️  Host: {{ inventory_hostname }}
          🐧  OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          🏗️  Architecture: {{ ansible_architecture }}
          👤  Profile: {{ profile }}
          ⏰  Timestamp: {{ ansible_date_time.iso8601 }}

  roles:
    # Platform-specific setup
    - role: platform_specific/macos
      when: ansible_os_family == "Darwin"
      tags: ['platform', 'macos']
      
    - role: platform_specific/archlinux  
      when: ansible_distribution == "Archlinux"
      tags: ['platform', 'archlinux']
      
    - role: platform_specific/nixos
      when: ansible_distribution == "NixOS"
      tags: ['platform', 'nixos']

    # Application configuration
    - role: applications/git
      tags: ['applications', 'git']
      
    - role: applications/zsh
      tags: ['applications', 'zsh']
      
    - role: applications/tmux
      tags: ['applications', 'tmux']
      
    - role: applications/neovim
      tags: ['applications', 'neovim']
      
    - role: applications/alacritty
      tags: ['applications', 'alacritty']
      
    - role: applications/starship
      tags: ['applications', 'starship']

    # Window managers (Linux only)
    - role: applications/i3
      when: ansible_os_family == "RedHat" or ansible_os_family == "Debian" or ansible_distribution == "Archlinux"
      tags: ['applications', 'i3', 'wm']
      
    - role: applications/hyprland
      when: ansible_distribution == "Archlinux"
      tags: ['applications', 'hyprland', 'wm']

    # Profile-specific configuration
    - role: profiles/developer
      when: profile == "developer"
      tags: ['profiles', 'developer']
      
    - role: profiles/nixos
      when: profile == "nixos" or ansible_distribution == "NixOS"
      tags: ['profiles', 'nixos']

  post_tasks:
    - name: Configuration complete
      debug:
        msg: |
          ✅ Configuration completed successfully!
          Profile: {{ profile }}
          Platform: {{ ansible_distribution }}
          
          Next steps:
          1. Restart your shell: exec $SHELL
          2. Test applications: nvim --version, tmux -V
          3. Check logs for any issues
EOF
```

## Phase 4: Create Inventory and Group Variables

### 4.1 Create Local Inventory
```bash
mkdir -p inventories/local
cat > inventories/local/hosts.yml << 'EOF'
---
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
      profile: developer
  vars:
    ansible_user: "{{ ansible_user_id }}"
EOF
```

### 4.2 Create Group Variables
```bash
cat > group_vars/all/main.yml << 'EOF'
---
# Main configuration for all hosts
dotfiles_enabled: true
dotfiles_repository: "{{ ansible_env.PWD }}"
dotfiles_local_path: "{{ ansible_env.PWD }}"
dotfiles_backup_existing: true

# Profile definitions
profiles:
  minimal:
    applications: [git, vim]
    features: [basic_shell]
  developer:
    applications: [git, zsh, tmux, neovim, alacritty, starship]
    features: [development_tools, shell_enhancements]
  nixos:
    applications: [git, zsh, tmux, neovim]
    features: [nix_integration, declarative_config]
EOF
```

## Validation Steps

### Test Current Functionality
```bash
# Test the restructured setup
ansible-playbook -i inventories/local/hosts.yml site.yml --check --diff

# Test specific roles
ansible-playbook -i inventories/local/hosts.yml site.yml --tags "applications,neovim" --check

# Validate syntax
ansible-playbook --syntax-check site.yml
```

## Next Steps

1. **Review and approve** this implementation plan
2. **Execute Phase 1** (directory structure)
3. **Execute Phase 2** (configuration migration)  
4. **Execute Phase 3** (main playbook creation)
5. **Execute Phase 4** (inventory and variables)
6. **Test and validate** the restructured repository
7. **Prepare for dotsible merger**

## Phase 4: Create Inventory and Group Variables

### 4.1 Create Local Inventory
```bash
mkdir -p inventories/local
cat > inventories/local/hosts.yml << 'EOF'
---
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
      profile: developer
  vars:
    ansible_user: "{{ ansible_user_id }}"
EOF
```

### 4.2 Create Group Variables
```bash
cat > group_vars/all/main.yml << 'EOF'
---
# Main configuration for all hosts
dotfiles_enabled: true
dotfiles_repository: "{{ ansible_env.PWD }}"
dotfiles_local_path: "{{ ansible_env.PWD }}"
dotfiles_backup_existing: true

# Profile definitions
profiles:
  minimal:
    applications: [git, vim]
    features: [basic_shell]
  developer:
    applications: [git, zsh, tmux, neovim, alacritty, starship]
    features: [development_tools, shell_enhancements]
  nixos:
    applications: [git, zsh, tmux, neovim]
    features: [nix_integration, declarative_config]
EOF
```

## Validation Steps

### Test Current Functionality
```bash
# Test the restructured setup
ansible-playbook -i inventories/local/hosts.yml site.yml --check --diff

# Test specific roles
ansible-playbook -i inventories/local/hosts.yml site.yml --tags "applications,neovim" --check

# Validate syntax
ansible-playbook --syntax-check site.yml
```

## Conflict Analysis and Resolution

### 1. Identified Conflicts

#### Package Management Overlap
- **Current**: Direct homebrew/pacman calls in scripts
- **Dotsible**: Abstracted package management roles
- **Resolution**: Use dotsible's package abstraction, maintain platform-specific optimizations

#### Configuration File Management
- **Current**: Direct file copying and symlinking
- **Dotsible**: Template-based with backup/restore
- **Resolution**: Adopt templating for dynamic configs, preserve static files

#### NixOS Integration
- **Current**: Standalone NixOS configuration
- **Dotsible**: No NixOS support
- **Resolution**: Create NixOS bridge role, maintain declarative approach

### 2. Migration Strategy for Conflicts

#### Preserve Current Functionality
```bash
# Keep current macsible.yaml as fallback
cp ansible/macsible.yaml ansible/macsible-legacy.yaml

# Preserve NixOS configs in dedicated directory
# (already in place - no changes needed)

# Keep utility scripts accessible
# (scripts/ directory preserved)
```

## Next Steps

1. **Review and approve** this implementation plan
2. **Execute Phase 1** (directory structure)
3. **Execute Phase 2** (configuration migration)
4. **Execute Phase 3** (main playbook creation)
5. **Execute Phase 4** (inventory and variables)
6. **Test and validate** the restructured repository
7. **Prepare for dotsible merger**

This implementation preserves all your current functionality while adopting dotsible's superior architecture.
