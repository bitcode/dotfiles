# Dotsible Usage Guide

This comprehensive guide covers all aspects of using Dotsible for cross-platform system configuration management.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Installation Methods](#installation-methods)
3. [Configuration](#configuration)
4. [Running Dotsible](#running-dotsible)
5. [Profiles](#profiles)
6. [Advanced Usage](#advanced-usage)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

## Quick Start

### 1. Bootstrap Your System

```bash
# Clone Dotsible
git clone <repository-url> dotsible
cd dotsible

# Run bootstrap script (installs dependencies)
./scripts/bootstrap.sh

# Validate system readiness
./scripts/validate.sh
```

### 2. Basic Configuration

```bash
# Create backup before making changes
./scripts/backup.sh

# Run with minimal profile
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=minimal

# Or run with developer profile
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer
```

### 3. Verification

```bash
# Check what was installed
cat ~/.ansible_profile_summary

# Run tests
./tests/scripts/run_all_tests.sh
```

## Installation Methods

### Method 1: Bootstrap Script (Recommended)

The bootstrap script automatically installs all dependencies and sets up Dotsible:

```bash
./scripts/bootstrap.sh
```

**What it does:**
- Detects your operating system
- Installs Python 3.6+ and Ansible 2.9+
- Installs required Python packages
- Creates initial configuration
- Runs basic validation

**Options:**
```bash
./scripts/bootstrap.sh --help           # Show help
./scripts/bootstrap.sh --check-only     # Only check prerequisites
./scripts/bootstrap.sh --skip-ssh       # Skip SSH key setup
./scripts/bootstrap.sh --minimal        # Minimal installation
```

### Method 2: Manual Installation

If you prefer manual control:

```bash
# Install Python and Ansible
sudo apt install python3 python3-pip ansible  # Ubuntu/Debian
sudo pacman -S python python-pip ansible      # Arch Linux
brew install python ansible                   # macOS

# Install Python requirements
pip3 install -r requirements.txt

# Install Ansible Galaxy requirements
ansible-galaxy install -r requirements.yml

# Create local inventory
cp inventories/local/hosts.yml.example inventories/local/hosts.yml
```

## Configuration

### Inventory Configuration

Edit your inventory file to match your setup:

```yaml
# inventories/local/hosts.yml
---
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
  vars:
    # Choose your profile
    profile: developer  # minimal, developer, server, gaming
    
    # Enable/disable features
    dotfiles_enabled: true
    backup_existing: true
    skip_interactive: false
    
    # Customize applications
    custom_applications:
      - git
      - vim
      - zsh
      - tmux
```

### Profile Customization

Modify profiles in [`group_vars/all/profiles.yml`](../group_vars/all/profiles.yml):

```yaml
profiles:
  developer:
    applications:
      - git
      - vim
      - zsh
      - tmux
      - docker
      - nodejs
    features:
      - advanced_shell
      - development_tools
      - docker_support
    packages:
      - build-essential
      - curl
      - wget
      - tree
```

### Package Customization

Edit package definitions in [`group_vars/all/packages.yml`](../group_vars/all/packages.yml):

```yaml
development_packages:
  ubuntu:
    - build-essential
    - python3-dev
    - nodejs
    - npm
  archlinux:
    - base-devel
    - python
    - nodejs
    - npm
  macos:
    - python
    - node
```

### OS-Specific Configuration

Customize OS-specific settings:

- [`group_vars/ubuntu.yml`](../group_vars/ubuntu.yml) - Ubuntu/Debian settings
- [`group_vars/archlinux.yml`](../group_vars/archlinux.yml) - Arch Linux settings
- [`group_vars/macos.yml`](../group_vars/macos.yml) - macOS settings
- [`group_vars/windows.yml`](../group_vars/windows.yml) - Windows settings

## Running Dotsible

### Basic Execution

```bash
# Run with default profile (minimal)
ansible-playbook -i inventories/local/hosts.yml site.yml

# Run with specific profile
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer

# Dry run (check what would change)
ansible-playbook -i inventories/local/hosts.yml site.yml --check --diff
```

### Advanced Execution Options

```bash
# Run specific tags only
ansible-playbook -i inventories/local/hosts.yml site.yml --tags=git,vim

# Skip specific tags
ansible-playbook -i inventories/local/hosts.yml site.yml --skip-tags=dotfiles

# Verbose output
ansible-playbook -i inventories/local/hosts.yml site.yml -vvv

# Ask for sudo password
ansible-playbook -i inventories/local/hosts.yml site.yml --ask-become-pass

# Run on specific hosts
ansible-playbook -i inventories/development/hosts.yml site.yml --limit=webservers
```

### Environment Variables

Control behavior with environment variables:

```bash
# Skip interactive prompts
export SKIP_INTERACTIVE=true

# Force reinstallation
export FORCE_INSTALL=true

# Custom backup directory
export BACKUP_DIR=/custom/backup/path

# Enable debug mode
export DEBUG=true

ansible-playbook -i inventories/local/hosts.yml site.yml
```

## Profiles

### Available Profiles

#### Minimal Profile
Basic system setup with essential tools:
- **Applications**: Git, Vim, basic shell
- **Features**: Essential packages, basic configuration
- **Use Case**: Servers, minimal workstations

```bash
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=minimal
```

#### Developer Profile
Complete development environment:
- **Applications**: Git, Vim, ZSH, Tmux, Docker, Node.js, Python
- **Features**: Advanced shell (Oh My Zsh), development tools, Docker support
- **Use Case**: Software development workstations

```bash
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=developer
```

#### Server Profile
Headless server configuration:
- **Applications**: Essential server tools, monitoring
- **Features**: Security hardening, log management, service monitoring
- **Use Case**: Production servers, VPS instances

```bash
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=server
```

#### Gaming Profile
Gaming and entertainment setup:
- **Applications**: Steam, media players, gaming tools
- **Features**: Graphics optimizations, gaming-specific configurations
- **Use Case**: Gaming workstations, entertainment systems

```bash
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=gaming
```

### Creating Custom Profiles

1. **Define the profile** in [`group_vars/all/profiles.yml`](../group_vars/all/profiles.yml):

```yaml
profiles:
  custom:
    applications:
      - git
      - vim
      - custom_app
    features:
      - custom_feature
    packages:
      - custom-package
```

2. **Create profile role** (optional):

```bash
mkdir -p roles/profiles/custom/{tasks,vars,meta}
```

3. **Add profile-specific tasks**:

```yaml
# roles/profiles/custom/tasks/main.yml
---
- name: Install custom profile packages
  package:
    name: "{{ custom_profile_packages }}"
    state: present
```

4. **Use the custom profile**:

```bash
ansible-playbook -i inventories/local/hosts.yml site.yml -e profile=custom
```

## Advanced Usage

### Remote Host Configuration

#### Single Remote Host

```bash
# Configure remote development server
ansible-playbook -i inventories/development/hosts.yml site.yml -e profile=server

# With custom SSH key
ansible-playbook -i inventories/development/hosts.yml site.yml --private-key=~/.ssh/custom_key
```

#### Multiple Hosts

```yaml
# inventories/production/hosts.yml
---
webservers:
  hosts:
    web1.example.com:
      profile: server
    web2.example.com:
      profile: server
  vars:
    ansible_user: deploy
    ansible_ssh_private_key_file: ~/.ssh/deploy_key

databases:
  hosts:
    db1.example.com:
      profile: server
      custom_packages:
        - postgresql
        - redis
```

```bash
# Configure all webservers
ansible-playbook -i inventories/production/hosts.yml site.yml --limit=webservers

# Configure specific host
ansible-playbook -i inventories/production/hosts.yml site.yml --limit=web1.example.com
```

### Conditional Execution

#### OS-Specific Tasks

```yaml
# In your playbook or role
- name: Install Linux-specific packages
  package:
    name: "{{ linux_packages }}"
    state: present
  when: ansible_os_family != "Darwin"

- name: Install macOS-specific packages
  homebrew:
    name: "{{ macos_packages }}"
    state: present
  when: ansible_os_family == "Darwin"
```

#### Profile-Specific Tasks

```yaml
- name: Install development tools
  package:
    name: "{{ development_tools }}"
    state: present
  when: "'developer' in profile"

- name: Configure gaming environment
  include_tasks: gaming_setup.yml
  when: profile == "gaming"
```

### Custom Variables

#### Host-Specific Variables

```yaml
# host_vars/myhost.yml
---
custom_git_config:
  user:
    name: "Custom User"
    email: "custom@example.com"

custom_packages:
  - special-tool
  - custom-app
```

#### Group Variables

```yaml
# group_vars/development.yml
---
development_mode: true
debug_enabled: true
custom_repositories:
  - "deb http://custom.repo.com/ubuntu focal main"
```

### Dotfiles Management

#### Custom Dotfiles Repository

```yaml
# In your inventory or group_vars
dotfiles_config:
  repository: "https://github.com/yourusername/dotfiles.git"
  destination: "{{ ansible_env.HOME }}/.dotfiles"
  files:
    - src: "bashrc"
      dest: ".bashrc"
    - src: "vimrc"
      dest: ".vimrc"
    - src: "gitconfig"
      dest: ".gitconfig"
```

#### Template-Based Dotfiles

```yaml
dotfiles_templates:
  - src: "bashrc.j2"
    dest: ".bashrc"
    vars:
      custom_prompt: true
      enable_colors: true
  - src: "gitconfig.j2"
    dest: ".gitconfig"
    vars:
      git_user_name: "{{ ansible_user_id }}"
      git_user_email: "{{ ansible_user_id }}@{{ ansible_hostname }}"
```

## Troubleshooting

### Common Issues

#### 1. Permission Errors

```bash
# Error: Permission denied
# Solution: Run with sudo privileges
ansible-playbook -i inventories/local/hosts.yml site.yml --ask-become-pass

# Or configure passwordless sudo
echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER
```

#### 2. Package Installation Failures

```bash
# Error: Package not found
# Solution: Update package cache first
sudo apt update      # Ubuntu/Debian
sudo pacman -Sy      # Arch Linux
brew update          # macOS

# Or force package cache update in playbook
ansible-playbook -i inventories/local/hosts.yml site.yml -e update_cache=true
```

#### 3. SSH Connection Issues

```bash
# Error: SSH connection failed
# Solution: Test SSH connectivity
ansible all -i inventories/development/hosts.yml -m ping

# Check SSH configuration
ssh -vvv user@remote-host

# Use SSH key authentication
ssh-copy-id user@remote-host
```

#### 4. Ansible Version Compatibility

```bash
# Error: Ansible version too old
# Solution: Upgrade Ansible
pip3 install --upgrade ansible

# Check version
ansible --version
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Basic verbose output
ansible-playbook -i inventories/local/hosts.yml site.yml -v

# More verbose output
ansible-playbook -i inventories/local/hosts.yml site.yml -vvv

# Debug specific tasks
ansible-playbook -i inventories/local/hosts.yml site.yml --tags=git -vvv
```

### Log Analysis

Check logs for detailed information:

```bash
# View Ansible logs
tail -f /var/log/ansible/bootstrap.log
tail -f /var/log/ansible/applications.log

# View profile summary
cat ~/.ansible_profile_summary

# View verification report
cat ~/.ansible_verification_report
```

### Recovery Procedures

#### Rollback Changes

```bash
# Emergency rollback
./scripts/rollback.sh

# List available backups
./scripts/rollback.sh --list-backups

# Cleanup only
./scripts/rollback.sh --cleanup-only
```

#### Restore from Backup

```bash
# Create backup before changes
./scripts/backup.sh

# List existing backups
./scripts/backup.sh --list-backups

# Restore specific backup
cd ~/.dotsible/backups/backup_YYYYMMDD_HHMMSS
./restore.sh
```

## Best Practices

### 1. Always Backup First

```bash
# Create backup before running Dotsible
./scripts/backup.sh

# Or enable automatic backup
echo "backup_before_run: true" >> inventories/local/hosts.yml
```

### 2. Test with Dry Run

```bash
# Always test changes first
ansible-playbook -i inventories/local/hosts.yml site.yml --check --diff
```

### 3. Use Version Control

```bash
# Track your customizations
git init
git add inventories/ group_vars/ host_vars/
git commit -m "Initial Dotsible configuration"
```

### 4. Validate Configuration

```bash
# Validate before running
./scripts/validate.sh

# Run syntax checks
./tests/scripts/validate_syntax.sh
```

### 5. Monitor Execution

```bash
# Use verbose output for important runs
ansible-playbook -i inventories/local/hosts.yml site.yml -v

# Check logs after execution
tail -f /var/log/ansible/*.log
```

### 6. Document Customizations

```bash
# Document your changes
echo "# Custom configuration for $(hostname)" >> inventories/local/hosts.yml
echo "# Added $(date): Custom packages for development" >> group_vars/all/packages.yml
```

### 7. Regular Testing

```bash
# Run tests regularly
./tests/scripts/run_all_tests.sh

# Test on clean systems
vagrant up  # If using Vagrant
docker run -it ubuntu:latest  # If using Docker
```

### 8. Keep Updated

```bash
# Update Dotsible regularly
git pull origin main

# Update Ansible Galaxy requirements
ansible-galaxy install -r requirements.yml --force

# Update Python requirements
pip3 install -r requirements.txt --upgrade
```

## Examples

### Example 1: Developer Workstation Setup

```bash
# 1. Bootstrap system
./scripts/bootstrap.sh

# 2. Customize for development
cat >> inventories/local/hosts.yml << EOF
  vars:
    profile: developer
    custom_applications:
      - docker
      - nodejs
      - python3
    git_config:
      user:
        name: "Your Name"
        email: "your.email@example.com"
EOF

# 3. Run configuration
ansible-playbook -i inventories/local/hosts.yml site.yml

# 4. Verify setup
./tests/scripts/run_all_tests.sh
```

### Example 2: Server Configuration

```bash
# 1. Prepare server inventory
cat > inventories/production/hosts.yml << EOF
---
servers:
  hosts:
    server1.example.com:
      profile: server
    server2.example.com:
      profile: server
  vars:
    ansible_user: deploy
    ansible_ssh_private_key_file: ~/.ssh/deploy_key
EOF

# 2. Run server configuration
ansible-playbook -i inventories/production/hosts.yml site.yml

# 3. Verify servers
ansible servers -i inventories/production/hosts.yml -m ping
```

### Example 3: Multi-Environment Setup

```bash
# Development environment
ansible-playbook -i inventories/development/hosts.yml site.yml -e profile=developer

# Staging environment
ansible-playbook -i inventories/staging/hosts.yml site.yml -e profile=server

# Production environment
ansible-playbook -i inventories/production/hosts.yml site.yml -e profile=server --check
```

## Getting Help

### Documentation

- [`README.md`](../README.md) - Project overview
- [`docs/SETUP.md`](SETUP.md) - Installation guide
- [`docs/EXTENDING.md`](EXTENDING.md) - Customization guide
- [`docs/TESTING.md`](TESTING.md) - Testing procedures
- [`docs/TROUBLESHOOTING.md`](TROUBLESHOOTING.md) - Common issues

### Support Channels

- **Issues**: Create GitHub issues for bugs
- **Discussions**: Use GitHub discussions for questions
- **Logs**: Check `/var/log/ansible/` for detailed logs
- **Tests**: Run `./tests/scripts/run_all_tests.sh` for diagnostics

### Community

- Share your configurations and customizations
- Contribute new roles and features
- Report bugs and suggest improvements
- Help others in discussions

---

**Happy Configuring with Dotsible!** 🎉