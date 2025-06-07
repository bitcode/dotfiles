# Phase 1 Execution Plan: Directory Structure Creation

## Overview
This document provides the exact commands and steps to execute Phase 1 of the dotfiles restructuring. This phase focuses on creating the dotsible-compatible directory structure while preserving all existing functionality.

## Prerequisites
- Current working directory: `/Users/mdrozrosario/dotfiles`
- Git repository is clean (all changes committed)
- Backup branch created: `backup-pre-restructure`

## Step-by-Step Execution

### Step 1: Create Backup and Preparation
```bash
# Ensure we're in the right directory
cd /Users/mdrozrosario/dotfiles

# Create backup branch if not already done
git checkout -b backup-pre-restructure 2>/dev/null || git checkout backup-pre-restructure
git add -A
git commit -m "Backup before Phase 1: Directory structure creation" || echo "No changes to commit"

# Create new working branch
git checkout -b restructure-phase1
```

### Step 2: Create Main Directory Structure
```bash
# Create primary directories
mkdir -p roles
mkdir -p group_vars/all
mkdir -p host_vars
mkdir -p inventories/{local,development,production}
mkdir -p templates/{common,macos,linux,windows}
mkdir -p files/dotfiles
mkdir -p tests/{roles,integration,validation}
mkdir -p docs

# Verify directory creation
echo "Created directories:"
find . -type d -name "roles" -o -name "group_vars" -o -name "inventories" -o -name "templates" -o -name "files" -o -name "tests" | sort
```

### Step 3: Create Role Structure
```bash
# Create role category directories
mkdir -p roles/{applications,platform_specific,profiles,common,package_manager}

# Create application role directories
mkdir -p roles/applications/{git,zsh,tmux,neovim,alacritty,starship,i3,hyprland,sway,ranger,rofi,waybar,polybar,picom,wofi,zellij}

# Create platform-specific role directories
mkdir -p roles/platform_specific/{macos,archlinux,ubuntu,nixos,windows}

# Create profile directories
mkdir -p roles/profiles/{minimal,developer,server,enterprise,nixos}

# Create common role directories
mkdir -p roles/{common,package_manager}/{tasks,handlers,templates,vars,files,meta}

# Verify role structure
echo "Role structure created:"
tree roles -d -L 2 2>/dev/null || find roles -type d | head -20
```

### Step 4: Create Core Configuration Files
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

echo "Core configuration files created:"
ls -la ansible.cfg requirements.yml
```

### Step 5: Create Basic Inventory
```bash
# Create local inventory
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

echo "Inventory created:"
cat inventories/local/hosts.yml
```

### Step 6: Create Basic Group Variables
```bash
# Create main group variables
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

# Default user configuration
default_user:
  name: "{{ ansible_user | default(ansible_user_id) }}"
  shell: "/bin/zsh"
  create_home: true
EOF

echo "Group variables created:"
cat group_vars/all/main.yml
```

### Step 7: Create Placeholder Site Playbook
```bash
# Create basic site.yml for testing
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

  tasks:
    - name: Phase 1 - Directory structure created
      debug:
        msg: |
          ✅ Phase 1 completed successfully!
          Directory structure is now dotsible-compatible.
          
          Next: Execute Phase 2 (Configuration Migration)
EOF

echo "Site playbook created:"
head -10 site.yml
```

### Step 8: Validation and Testing
```bash
# Test Ansible syntax
echo "Testing Ansible syntax..."
ansible-playbook --syntax-check site.yml

# Test inventory
echo "Testing inventory..."
ansible-inventory -i inventories/local/hosts.yml --list

# Test basic playbook execution
echo "Testing basic playbook execution..."
ansible-playbook -i inventories/local/hosts.yml site.yml --check

# Verify directory structure
echo "Final directory structure:"
find . -type d -not -path "./.git*" | sort | head -30
```

### Step 9: Commit Phase 1 Changes
```bash
# Add all new files
git add .

# Commit Phase 1 changes
git commit -m "Phase 1: Create dotsible-compatible directory structure

- Added roles/, group_vars/, inventories/, templates/, files/, tests/, docs/
- Created application role directories for all current applications
- Created platform-specific role directories (macos, archlinux, ubuntu, nixos, windows)
- Created profile directories (minimal, developer, server, enterprise, nixos)
- Added ansible.cfg and requirements.yml
- Created basic inventory and group variables
- Added placeholder site.yml for testing

All existing functionality preserved. Ready for Phase 2."

# Show what was added
git show --stat HEAD
```

## Verification Checklist

After completing Phase 1, verify:

- [ ] All directories created successfully
- [ ] ansible.cfg and requirements.yml exist
- [ ] Basic inventory works: `ansible-inventory -i inventories/local/hosts.yml --list`
- [ ] Syntax check passes: `ansible-playbook --syntax-check site.yml`
- [ ] Basic playbook runs: `ansible-playbook -i inventories/local/hosts.yml site.yml --check`
- [ ] All original files still in place (nvim/, tmux/, zsh/, etc.)
- [ ] Git commit successful with all changes tracked

## Next Steps

1. **Verify Phase 1 completion** using the checklist above
2. **Review the new structure** and ensure it meets expectations
3. **Proceed to Phase 2**: Configuration Migration
4. **Test current functionality** to ensure nothing is broken

## Rollback Procedure (if needed)

If issues arise:
```bash
# Return to backup branch
git checkout backup-pre-restructure

# Or reset to before Phase 1
git checkout main
git reset --hard HEAD~1  # Only if Phase 1 was the last commit
```

This completes Phase 1 of the restructuring process.
