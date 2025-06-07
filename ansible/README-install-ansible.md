# Ansible Installation Script for macOS

A comprehensive bash script that automates the complete Ansible installation and configuration process for macOS systems.

## Quick Start

```bash
# Make the script executable
chmod +x install-ansible.sh

# Run the installation
./install-ansible.sh

# Test your playbook (optional)
./install-ansible.sh --test
```

After successful installation, you can run:
```bash
ansible-playbook -c local -i localhost, ansible/macsible.yaml
```

## Features

### ✅ **Python 3 Verification**
- Checks if Python 3 is installed using `python3 --version`
- Verifies version is 3.8+ (minimum requirement for Ansible)
- Exits with clear error message if Python 3 is not found or incompatible
- Displays detected Python version for confirmation

### ✅ **Ansible Installation**
- Installs Ansible using: `python3 -m pip install --user ansible`
- Handles pip installation errors gracefully
- Displays installation progress and status
- Skips installation if Ansible is already accessible

### ✅ **Smart PATH Configuration**
- Detects user's current shell (`$SHELL` environment variable)
- **zsh users**: Adds PATH export to `~/.zshrc`
- **bash users**: Adds PATH export to `~/.bash_profile` or `~/.bashrc`
- Uses actual detected Python version (not hardcoded)
- Prevents duplicate PATH entries
- Creates shell config file if it doesn't exist

### ✅ **Environment Reload**
- Sources updated shell configuration immediately
- Verifies PATH update success with `which ansible`

### ✅ **Installation Verification**
- Runs `ansible --version` and captures output
- Verifies core commands: `ansible-playbook`, `ansible-galaxy`, `ansible-vault`
- Displays version information and installation location

### ✅ **Idempotency & Error Handling**
- Safe to run multiple times without side effects
- Comprehensive error checking after each step
- Clear, actionable error messages with solutions
- Specific exit codes for different failure types

### ✅ **Optional Self-Test**
- `--test` flag runs syntax check on `ansible/macsible.yaml`
- Option to execute playbook immediately after installation

## Usage

### Basic Installation
```bash
./install-ansible.sh
```

### Installation with Playbook Testing
```bash
./install-ansible.sh --test
```

## Output Features

- **Colored output**: Green for success, red for errors, yellow for warnings
- **Progress indicators** for long-running operations
- **Comprehensive logging** to timestamped log files
- **Installation summary** showing what was configured

## Exit Codes

- `0` - Success
- `1` - Python 3 not found
- `2` - Python version incompatible
- `3` - Ansible installation failed
- `4` - PATH configuration failed
- `5` - Verification failed

## Requirements

- macOS system
- Python 3.8 or higher
- Internet connection for pip installation

## Supported Shells

- **zsh** (default on modern macOS) - uses `~/.zshrc`
- **bash** - uses `~/.bash_profile` or `~/.bashrc`

## Log Files

Each run creates a timestamped log file: `ansible-install-YYYYMMDD-HHMMSS.log`

## Troubleshooting

### Python Not Found
```bash
# Install Python 3 from official website
# https://www.python.org/downloads/
```

### Permission Issues
```bash
# Ensure script is executable
chmod +x install-ansible.sh
```

### PATH Not Working
```bash
# Manually reload shell configuration
source ~/.zshrc  # for zsh
source ~/.bash_profile  # for bash
```

### Ansible Commands Not Found
```bash
# Check if PATH was added correctly
echo $PATH | grep "Library/Python"

# Verify Ansible location
ls -la ~/Library/Python/*/bin/ansible*
```

## What the Script Does

1. **Checks Python 3** installation and version compatibility
2. **Installs Ansible** via pip if not already present
3. **Configures PATH** in appropriate shell configuration file
4. **Reloads environment** to apply changes immediately
5. **Verifies installation** by testing all Ansible commands
6. **Optionally tests** your playbook syntax
7. **Logs everything** for troubleshooting

## Perfect for

- Fresh macOS system setup
- Dotfiles repositories
- System restoration scenarios
- CI/CD environments
- Development environment bootstrapping

---

**Note**: This script is designed specifically for macOS and uses the `--user` pip installation method to avoid system-wide changes.
