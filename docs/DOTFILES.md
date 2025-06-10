# Dotfiles Integration Guide

This guide covers the comprehensive dotfiles integration system in Dotsible, which provides cross-platform dotfiles management with advanced features like templating, backup, and verification.

## Overview

The Dotsible dotfiles integration system provides:

- **Cross-platform support** for Linux, macOS, and Windows
- **Automatic backup** of existing dotfiles
- **Symlink management** with conflict resolution
- **Template processing** for OS-specific configurations
- **Profile-based customization** for different use cases
- **Verification and validation** of installations
- **Comprehensive error handling** and reporting

## Quick Start

### 1. Basic Setup

```bash
# Run dotfiles setup as part of workstation configuration
ansible-playbook playbooks/workstation.yml

# Or run dotfiles setup standalone
ansible-playbook playbooks/dotfiles.yml
```

### 2. Custom Repository

```bash
# Use your own dotfiles repository
ansible-playbook playbooks/dotfiles.yml -e "dotfiles_repo=https://github.com/username/dotfiles"
```

### 3. Profile-specific Setup

```bash
# Apply developer profile
ansible-playbook playbooks/dotfiles.yml -e "profile=developer"
```

## Configuration

### Global Configuration

The main dotfiles configuration is in [`group_vars/all/main.yml`](../group_vars/all/main.yml):

```yaml
dotfiles:
  enabled: true
  repository: "https://github.com/bitcode/dotfiles"
  branch: "main"
  local_path: "{{ ansible_user_dir }}/.dotfiles"
  backup_existing: true
  backup_directory: "{{ ansible_user_dir }}/.dotfiles_backup"
  force_update: false
  
  # Advanced options
  symlink_strategy: "force"  # force, skip, backup
  process_templates: true
  os_specific_configs: true
  profile_specific_configs: true
  verify_installation: true
```

### OS-Specific Configuration

Each operating system has specific configurations in [`group_vars/`](../group_vars/):

- **Ubuntu/Debian**: [`group_vars/ubuntu.yml`](../group_vars/ubuntu.yml)
- **Arch Linux**: [`roles/dotfiles/vars/archlinux.yml`](../roles/dotfiles/vars/archlinux.yml)
- **macOS**: [`roles/dotfiles/vars/darwin.yml`](../roles/dotfiles/vars/darwin.yml)

## Dotfiles Repository Structure

Your dotfiles repository should follow this recommended structure:

```
dotfiles/
├── shell/
│   ├── bashrc
│   ├── zshrc
│   ├── profile
│   └── bash_aliases
├── git/
│   └── gitconfig
├── vim/
│   ├── vimrc
│   └── gvimrc
├── tmux/
│   └── tmux.conf
├── ssh/
│   └── config
├── config/
│   ├── i3/
│   ├── alacritty/
│   └── kitty/
├── bin/
│   └── scripts/
├── templates/
│   ├── bashrc.j2
│   ├── gitconfig.j2
│   └── vimrc.j2
└── profiles/
    ├── developer/
    ├── server/
    └── minimal/
```

## Template System

### Jinja2 Templates

Create templates with `.j2` extension for OS-specific configurations:

```bash
# Example: shell/bashrc.j2
{% if ansible_os_family == "Debian" %}
alias ll='ls -alF'
export PACKAGE_MANAGER="apt"
{% elif ansible_os_family == "Archlinux" %}
alias ll='ls -alF --color=auto'
export PACKAGE_MANAGER="pacman"
{% elif ansible_os_family == "Darwin" %}
alias ll='ls -alF'
export PACKAGE_MANAGER="brew"
{% endif %}

# Profile-specific sections
{% if profile == "developer" %}
export EDITOR="vim"
alias gs='git status'
alias gc='git commit'
{% endif %}
```

### Available Template Variables

Templates have access to:

- **Ansible facts**: `ansible_os_family`, `ansible_distribution`, etc.
- **OS-specific variables**: `dotfiles_template_vars`
- **Profile configuration**: `profile`, `profiles[profile]`
- **System paths**: `ansible_user_dir`, etc.

## Profile System

### Defining Profiles

Profiles are defined in [`group_vars/all/profiles.yml`](../group_vars/all/profiles.yml):

```yaml
profiles:
  developer:
    dotfiles:
      enabled: true
    applications:
      - git
      - vim
      - tmux
    packages:
      - build-essential
      - nodejs
      - python3
    environment:
      EDITOR: "vim"
      BROWSER: "firefox"
    aliases:
      gs: "git status"
      gc: "git commit"
    post_install_commands:
      - "git config --global user.name 'Your Name'"
```

### Profile-Specific Dotfiles

Create profile-specific configurations in your dotfiles repository:

```
dotfiles/profiles/
├── developer/
│   ├── vimrc
│   ├── gitconfig
│   └── tmux.conf
├── server/
│   ├── bashrc
│   └── vimrc
└── minimal/
    └── bashrc
```

## Backup System

### Automatic Backups

The system automatically backs up existing dotfiles before creating symlinks:

- **Backup location**: `~/.dotfiles_backup/backup_<timestamp>/`
- **Backup manifest**: Contains details of backed up files
- **Cleanup script**: Automatically generated for old backup removal

### Manual Backup Management

```bash
# View backups
ls -la ~/.dotfiles_backup/

# Restore a specific file
cp ~/.dotfiles_backup/backup_1234567890/bashrc ~/.bashrc

# Clean old backups (older than 30 days)
~/.dotfiles_backup/cleanup_old_backups.sh
```

## Symlink Management

### Symlink Strategies

- **force** (default): Replace existing files/symlinks
- **skip**: Skip files that already exist
- **backup**: Backup existing files before creating symlinks

### Manual Symlink Operations

```bash
# View current symlinks
ls -la ~ | grep '\->'

# Check for broken symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print

# Verify symlink targets
find ~ -maxdepth 1 -type l -exec ls -la {} \;
```

## Verification System

### Automatic Verification

The system automatically verifies:

- Repository integrity
- Symlink validity
- File permissions
- Template processing
- Shell configuration syntax

### Manual Verification

```bash
# Run verification manually
ansible-playbook playbooks/dotfiles.yml --tags verify

# Check verification report
cat ~/.dotfiles/VERIFICATION_REPORT.txt
```

## Advanced Usage

### Custom File Mappings

Override default file mappings in your group_vars:

```yaml
dotfiles_file_mappings:
  "custom/config": "{{ ansible_user_dir }}/.custom_config"
  "special/script": "{{ ansible_user_dir }}/.local/bin/special"
```

### Custom Post-Install Commands

```yaml
dotfiles_post_install_commands:
  - "source ~/.bashrc"
  - "fc-cache -fv"
  - "custom-setup-script"
```

### Template Target Mapping

```yaml
dotfiles_template_target_map:
  "bashrc": "{{ ansible_user_dir }}/.bashrc"
  "gitconfig": "{{ ansible_user_dir }}/.gitconfig"
```

## Troubleshooting

### Common Issues

1. **Repository not found**
   ```bash
   # Check repository URL and access
   git clone https://github.com/username/dotfiles
   ```

2. **Broken symlinks**
   ```bash
   # Find and remove broken symlinks
   find ~ -maxdepth 1 -type l ! -exec test -e {} \; -delete
   ```

3. **Permission errors**
   ```bash
   # Fix permissions
   chmod 600 ~/.ssh/config
   chmod 700 ~/.ssh
   ```

4. **Template errors**
   ```bash
   # Check template syntax
   ansible-playbook playbooks/dotfiles.yml --syntax-check
   ```

### Debug Mode

```bash
# Enable debug output
ansible-playbook playbooks/dotfiles.yml -e "debug_mode=true" -vvv
```

### Force Update

```bash
# Force repository update
ansible-playbook playbooks/dotfiles.yml -e "force_update=true"
```

## Integration with Existing Dotfiles

### Migration from Manual Setup

1. **Backup current dotfiles**:
   ```bash
   mkdir ~/dotfiles_manual_backup
   cp ~/.bashrc ~/.vimrc ~/.gitconfig ~/dotfiles_manual_backup/
   ```

2. **Create dotfiles repository**:
   ```bash
   mkdir ~/dotfiles && cd ~/dotfiles
   git init
   # Add your dotfiles
   ```

3. **Run Dotsible setup**:
   ```bash
   ansible-playbook playbooks/dotfiles.yml -e "dotfiles_repo=~/dotfiles"
   ```

### Working with Existing Repositories

The system works with any existing dotfiles repository structure. Just ensure:

- Files are organized logically
- Use `.j2` extension for templates
- Follow the recommended directory structure for best results

## Security Considerations

### Private Files

Files matching these patterns get restricted permissions (600):

- `ssh/config`
- `ssh/*_rsa`
- `ssh/*_ed25519`
- `aws/credentials`
- `*.key`
- `*.pem`

### Backup Security

- Backups are created with user-only permissions (700)
- Sensitive files maintain their restricted permissions
- Backup cleanup prevents accumulation of old sensitive data

## Performance Optimization

### Large Repositories

For large dotfiles repositories:

```yaml
dotfiles:
  clone_depth: 1  # Shallow clone
  exclude_patterns:
    - "*.git*"
    - "docs/"
    - "*.md"
```

### Network Optimization

```yaml
dotfiles:
  verify_ssl: false  # Only for internal repositories
  update_submodules: false  # Skip if not needed
```

## Examples

### Complete Developer Setup

```bash
# Full developer workstation with dotfiles
ansible-playbook playbooks/workstation.yml \
  -e "profile=developer" \
  -e "dotfiles_repo=https://github.com/username/dev-dotfiles" \
  -e "features=['development','gui','docker']"
```

### Server Configuration

```bash
# Minimal server setup with dotfiles
ansible-playbook playbooks/server.yml \
  -e "profile=server" \
  -e "dotfiles_repo=https://github.com/username/server-dotfiles"
```

### Custom Profile

```bash
# Custom profile with specific settings
ansible-playbook playbooks/dotfiles.yml \
  -e "profile=custom" \
  -e "dotfiles_repo=https://github.com/username/dotfiles" \
  -e "dotfiles_branch=custom-branch"
```

## Contributing

To contribute to the dotfiles integration:

1. Test with multiple operating systems
2. Ensure backward compatibility
3. Add appropriate error handling
4. Update documentation
5. Include verification tests

## Support

For issues with dotfiles integration:

1. Check the verification report: `~/.dotfiles/VERIFICATION_REPORT.txt`
2. Review backup manifests: `~/.dotfiles_backup/*/BACKUP_MANIFEST.txt`
3. Enable debug mode for detailed output
4. Check the troubleshooting section above

---

The Dotsible dotfiles integration provides a robust, cross-platform solution for managing your development environment configurations. With its comprehensive backup, verification, and templating systems, you can confidently manage dotfiles across multiple systems and profiles.