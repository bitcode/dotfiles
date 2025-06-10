# Dotsible Setup Guide

This guide provides detailed instructions for setting up and configuring Dotsible for your environment.

## Prerequisites

### Control Machine Requirements

- **Operating System**: Linux, macOS, or Windows (with WSL)
- **Ansible**: Version 2.9 or higher
- **Python**: Version 3.6 or higher
- **Git**: For cloning repositories
- **SSH Client**: For remote system management

### Target System Requirements

- **Supported OS**: Ubuntu 18.04+, Arch Linux, macOS 10.15+, Windows 10+
- **Python**: Version 3.6 or higher
- **SSH Server**: For remote management (optional for local)
- **Sudo Access**: For system-level changes

## Installation

### 1. Install Ansible

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install ansible python3-pip
```

#### Arch Linux
```bash
sudo pacman -S ansible python-pip
```

#### macOS
```bash
# Using Homebrew
brew install ansible

# Using pip
pip3 install ansible
```

#### Windows (WSL)
```bash
# Install WSL first, then use Ubuntu instructions
sudo apt update
sudo apt install ansible python3-pip
```

### 2. Clone Dotsible Repository

```bash
git clone https://github.com/username/dotsible.git
cd dotsible
```

### 3. Install Dependencies

```bash
# Install Ansible collections and roles
ansible-galaxy install -r requirements.yml

# Verify installation
ansible --version
ansible-galaxy collection list
```

## Configuration

### 1. Inventory Setup

#### Local Development
Copy and edit the local inventory:
```bash
cp inventories/local/hosts.yml.example inventories/local/hosts.yml
vim inventories/local/hosts.yml
```

Example configuration:
```yaml
all:
  children:
    workstations:
      children:
        ubuntu_workstations:
          hosts:
            localhost:
              ansible_host: localhost
              ansible_connection: local
              profile: developer
              features:
                - gui
                - development
                - docker
```

#### Remote Systems
For remote systems, configure SSH access:
```yaml
ubuntu_workstations:
  hosts:
    remote-dev:
      ansible_host: 192.168.1.100
      ansible_user: developer
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
      profile: developer
```

### 2. SSH Configuration

#### Generate SSH Keys
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### Copy SSH Keys to Target Systems
```bash
ssh-copy-id user@target-system
```

#### Test SSH Connection
```bash
ssh user@target-system
ansible all -m ping
```

### 3. Dotfiles Configuration

Edit `group_vars/all/main.yml` to configure your dotfiles:
```yaml
dotfiles:
  enabled: true
  repository: "https://github.com/yourusername/dotfiles.git"
  branch: "main"
  local_path: "{{ ansible_user_dir }}/.dotfiles"
  backup_existing: true
```

### 4. Profile Selection

Choose appropriate profiles for your systems:

- **minimal**: Basic tools only
- **developer**: Full development environment
- **server**: Headless server configuration
- **gaming**: Gaming setup
- **designer**: Creative tools

Configure in inventory or as extra vars:
```yaml
# In inventory
hosts:
  my-laptop:
    profile: developer

# Or as command line argument
ansible-playbook site.yml --extra-vars "profile=developer"
```

## First Run

### 1. Test Connection
```bash
ansible all -m ping
```

### 2. Bootstrap New Systems
```bash
ansible-playbook site.yml --extra-vars "bootstrap=true"
```

### 3. Full Configuration
```bash
ansible-playbook site.yml
```

### 4. Verify Installation
```bash
ansible-playbook site.yml --tags "verify"
```

## Advanced Configuration

### 1. Custom Variables

Create host-specific variables:
```bash
# Create host variable file
vim host_vars/hostname.yml
```

Example host variables:
```yaml
# host_vars/my-laptop.yml
git_user_name: "John Doe"
git_user_email: "john@example.com"
dotfiles_repo: "https://github.com/johndoe/dotfiles.git"

custom_packages:
  - neovim
  - tmux
  - zsh
```

### 2. Environment-Specific Settings

Use different inventories for different environments:
```bash
# Development environment
ansible-playbook -i inventories/development/hosts.yml site.yml

# Production environment
ansible-playbook -i inventories/production/hosts.yml site.yml
```

### 3. Vault for Secrets

Encrypt sensitive data:
```bash
# Create vault file
ansible-vault create group_vars/all/vault.yml

# Edit vault file
ansible-vault edit group_vars/all/vault.yml

# Run with vault password
ansible-playbook site.yml --ask-vault-pass
```

### 4. Custom Roles

Create custom application roles:
```bash
mkdir -p roles/applications/myapp/{tasks,vars,handlers,templates,meta}
```

## Troubleshooting

### Common Issues

#### Connection Problems
```bash
# Test basic connectivity
ansible all -m ping

# Use password authentication
ansible-playbook site.yml --ask-pass

# Specify SSH user
ansible-playbook site.yml --user=myuser
```

#### Permission Issues
```bash
# Use sudo
ansible-playbook site.yml --ask-become-pass

# Skip privilege escalation
ansible-playbook site.yml --extra-vars "ansible_become=false"
```

#### Package Installation Failures
```bash
# Update package cache
ansible all -m package -a "update_cache=yes" --become

# Check package availability
ansible all -m package -a "name=git state=present" --check
```

### Debug Mode

Enable verbose output:
```bash
# Basic verbose
ansible-playbook site.yml -v

# More verbose
ansible-playbook site.yml -vvv

# Debug mode
ansible-playbook site.yml --check --diff
```

### Log Analysis

Check Ansible logs:
```bash
# View log file
tail -f ansible.log

# Filter for errors
grep ERROR ansible.log

# Filter for specific host
grep "hostname" ansible.log
```

## Performance Optimization

### 1. Parallel Execution
```ini
# ansible.cfg
[defaults]
forks = 20
```

### 2. SSH Optimization
```ini
# ansible.cfg
[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
```

### 3. Fact Caching
```ini
# ansible.cfg
[defaults]
gathering = smart
fact_caching = memory
fact_caching_timeout = 86400
```

## Next Steps

1. **Customize Profiles**: Modify existing profiles or create new ones
2. **Add Applications**: Create roles for additional applications
3. **Integrate CI/CD**: Set up automated testing and deployment
4. **Monitor Systems**: Implement monitoring and alerting
5. **Backup Configuration**: Set up configuration backups

## Support

- **Documentation**: [GitHub Wiki](https://github.com/username/dotsible/wiki)
- **Issues**: [GitHub Issues](https://github.com/username/dotsible/issues)
- **Community**: [Discord Server](https://discord.gg/dotsible)
- **Email**: support@dotsible.com