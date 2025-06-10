# Dotsible Troubleshooting Guide

This guide helps you diagnose and resolve common issues when using Dotsible.

## Common Issues

### 1. Connection Problems

#### SSH Connection Refused
```bash
# Error: ssh: connect to host X.X.X.X port 22: Connection refused

# Solutions:
# 1. Check if SSH service is running on target
ssh user@target "sudo systemctl status ssh"

# 2. Test basic connectivity
ping target-host

# 3. Check SSH port
nmap -p 22 target-host

# 4. Use password authentication temporarily
ansible-playbook site.yml --ask-pass
```

#### Permission Denied (publickey)
```bash
# Error: Permission denied (publickey,password)

# Solutions:
# 1. Copy SSH key to target
ssh-copy-id user@target-host

# 2. Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# 3. Use password authentication
ansible-playbook site.yml --ask-pass --ask-become-pass
```

#### Host Key Verification Failed
```bash
# Error: Host key verification failed

# Solutions:
# 1. Remove old host key
ssh-keygen -R target-host

# 2. Accept new host key
ssh user@target-host

# 3. Disable host key checking (not recommended for production)
export ANSIBLE_HOST_KEY_CHECKING=False
```

### 2. Package Installation Issues

#### Package Not Found
```bash
# Error: No package matching 'package-name' found available

# Solutions:
# 1. Update package cache
ansible all -m package -a "update_cache=yes" --become

# 2. Check package name for your OS
# Ubuntu/Debian: apt search package-name
# Arch Linux: pacman -Ss package-name
# macOS: brew search package-name

# 3. Add required repositories
ansible-playbook site.yml --tags "repositories"
```

#### Permission Denied During Installation
```bash
# Error: Permission denied

# Solutions:
# 1. Use become (sudo)
ansible-playbook site.yml --ask-become-pass

# 2. Check sudo configuration
ansible all -m shell -a "sudo -l" --ask-become-pass

# 3. Add user to sudo group
ansible all -m user -a "name=username groups=sudo append=yes" --become
```

### 3. Dotfiles Issues

#### Git Repository Not Found
```bash
# Error: Repository not found

# Solutions:
# 1. Check repository URL
git ls-remote https://github.com/username/dotfiles.git

# 2. Use SSH instead of HTTPS
dotfiles_repo: "git@github.com:username/dotfiles.git"

# 3. Make repository public or configure SSH keys
```

#### File Permission Issues
```bash
# Error: Permission denied when creating symlinks

# Solutions:
# 1. Check file ownership
ls -la ~/.dotfiles

# 2. Fix ownership
ansible all -m file -a "path=~/.dotfiles owner={{ ansible_user }} recurse=yes"

# 3. Backup existing files
dotfiles_backup_existing: true
```

#### Symlink Conflicts
```bash
# Error: Cannot create symlink - file exists

# Symptoms:
# - Deployment fails with "file exists" errors
# - Existing configurations prevent symlink creation
# - Backup system not working properly

# Solutions:
# 1. Check what's blocking the symlink
ls -la ~/.gitconfig ~/.zshrc ~/.config/nvim

# 2. Manual backup (if automatic backup failed)
mkdir -p ~/.dotsible/backups/manual_$(date +%s)
cp ~/.gitconfig ~/.dotsible/backups/manual_$(date +%s)/ 2>/dev/null || true
cp ~/.zshrc ~/.dotsible/backups/manual_$(date +%s)/ 2>/dev/null || true
cp -r ~/.config/nvim ~/.dotsible/backups/manual_$(date +%s)/ 2>/dev/null || true

# 3. Remove conflicting files
rm ~/.gitconfig ~/.zshrc 2>/dev/null || true
rm -rf ~/.config/nvim 2>/dev/null || true

# 4. Re-run deployment
./run-dotsible.sh --profile enterprise --tags dotfiles

# 5. Verify backup location
ls -la ~/.dotsible/backups/
cat ~/.dotsible/backups/*/git_backup_manifest.txt
```

#### Backup System Issues
```bash
# Error: Backup system not working

# Symptoms:
# - Files not being backed up before symlink creation
# - Backup directory empty or missing
# - No backup manifests generated

# Diagnosis:
# 1. Check backup configuration
grep -r "backup_existing" roles/dotfiles/vars/

# 2. Check backup directory permissions
ls -la ~/.dotsible/backups/

# 3. Test backup logic manually
ansible-playbook -i "localhost," -c local test-dotfiles-backup-only.yml -e "profile=enterprise"

# Solutions:
# 1. Ensure backup directory exists
mkdir -p ~/.dotsible/backups

# 2. Check backup is enabled in roles/dotfiles/vars/main.yml:
# dotfiles:
#   backup_existing: true

# 3. Re-run with verbose output
./run-dotsible.sh --profile enterprise --tags dotfiles --verbose
```

### 4. Role and Profile Issues

#### Role Not Found
```bash
# Error: the role 'applications/myapp' was not found

# Solutions:
# 1. Check role directory structure
ls -la roles/applications/myapp/

# 2. Verify role name in profile
# Check group_vars/all/profiles.yml

# 3. Create missing role
mkdir -p roles/applications/myapp/{tasks,vars,handlers,meta}
```

#### Profile Compatibility Issues
```bash
# Error: Profile is not compatible with OS

# Solutions:
# 1. Check profile compatibility matrix
# See group_vars/all/profiles.yml

# 2. Use compatible profile
ansible-playbook site.yml --extra-vars "profile=minimal"

# 3. Modify profile for your OS
```

### 5. Template and Configuration Issues

#### Template Syntax Errors
```bash
# Error: TemplateSyntaxError

# Solutions:
# 1. Check Jinja2 syntax
ansible-playbook site.yml --syntax-check

# 2. Validate template manually
ansible all -m template -a "src=template.j2 dest=/tmp/test" --check

# 3. Check variable definitions
ansible all -m debug -a "var=variable_name"
```

#### Missing Variables
```bash
# Error: 'variable_name' is undefined

# Solutions:
# 1. Define variable in appropriate location
# host_vars/, group_vars/, or role vars/

# 2. Set default value in template
{{ variable_name | default('default_value') }}

# 3. Check variable precedence
ansible-inventory --host hostname --vars
```

## Debugging Techniques

### 1. Verbose Output
```bash
# Basic verbose
ansible-playbook site.yml -v

# More verbose (connection info)
ansible-playbook site.yml -vv

# Very verbose (execution info)
ansible-playbook site.yml -vvv

# Extremely verbose (debug info)
ansible-playbook site.yml -vvvv
```

### 2. Check Mode (Dry Run)
```bash
# See what would change without making changes
ansible-playbook site.yml --check

# Show file differences
ansible-playbook site.yml --check --diff

# Limit to specific hosts
ansible-playbook site.yml --check --limit hostname
```

### 3. Step Mode
```bash
# Execute step by step
ansible-playbook site.yml --step

# Start at specific task
ansible-playbook site.yml --start-at-task "task name"
```

### 4. Tag-based Debugging
```bash
# Run only specific tags
ansible-playbook site.yml --tags "git,vim"

# Skip specific tags
ansible-playbook site.yml --skip-tags "docker,gaming"

# List available tags
ansible-playbook site.yml --list-tags
```

### 5. Variable Inspection
```bash
# Show all variables for a host
ansible-inventory --host hostname --vars

# Debug specific variable
ansible all -m debug -a "var=ansible_facts"

# Show gathered facts
ansible all -m setup
```

## Log Analysis

### 1. Ansible Logs
```bash
# View current log
tail -f ansible.log

# Search for errors
grep -i error ansible.log

# Search for specific host
grep hostname ansible.log

# Search for failed tasks
grep -A 5 -B 5 "FAILED" ansible.log
```

### 2. System Logs
```bash
# Check system logs (Linux)
sudo journalctl -f

# Check SSH logs
sudo journalctl -u ssh

# Check package manager logs
# Ubuntu: /var/log/apt/
# Arch: journalctl -u pacman
```

## Performance Issues

### 1. Slow Execution
```bash
# Increase parallel execution
# In ansible.cfg:
[defaults]
forks = 20

# Enable SSH pipelining
[ssh_connection]
pipelining = True

# Use fact caching
[defaults]
gathering = smart
fact_caching = memory
```

### 2. Network Timeouts
```bash
# Increase timeouts
# In ansible.cfg:
[defaults]
timeout = 30

# In inventory:
ansible_ssh_common_args: '-o ConnectTimeout=30'
```

## Recovery Procedures

### 1. Restore from Backup
```bash
# Restore dotfiles backup
cp ~/.dotfiles.backup/* ~/

# Restore configuration backup
sudo cp /etc/backup/* /etc/
```

### 2. Reset Configuration
```bash
# Remove Dotsible configurations
ansible-playbook site.yml --extra-vars "reset_config=true"

# Start fresh
rm -rf ~/.dotfiles ~/.config/dotsible
```

### 3. Emergency Access
```bash
# If SSH is broken, use console access
# Reset SSH configuration
sudo systemctl restart ssh

# Reset user shell
sudo chsh -s /bin/bash username
```

## Getting Help

### 1. Community Support
- **GitHub Issues**: [Report bugs and request features](https://github.com/username/dotsible/issues)
- **Discord**: [Join the community chat](https://discord.gg/dotsible)
- **Wiki**: [Browse documentation](https://github.com/username/dotsible/wiki)

### 2. Professional Support
- **Email**: support@dotsible.com
- **Consulting**: Available for complex deployments

### 3. Self-Help Resources
- **Ansible Documentation**: [docs.ansible.com](https://docs.ansible.com)
- **Jinja2 Documentation**: [jinja.palletsprojects.com](https://jinja.palletsprojects.com)
- **YAML Syntax**: [yaml.org](https://yaml.org)

## Reporting Issues

When reporting issues, please include:

1. **Environment Information**:
   ```bash
   ansible --version
   python --version
   uname -a
   ```

2. **Error Output**:
   ```bash
   ansible-playbook site.yml -vvv 2>&1 | tee debug.log
   ```

3. **Configuration Files**:
   - Inventory file (sanitized)
   - Relevant group_vars
   - Custom roles or modifications

4. **Steps to Reproduce**:
   - Exact commands run
   - Expected vs actual behavior
   - Any workarounds found