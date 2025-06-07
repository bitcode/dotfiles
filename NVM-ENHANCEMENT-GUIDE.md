# NVM Enhancement Guide for macOS Ansible Playbook

## Overview

The `ansible/macsible.yaml` playbook has been enhanced with comprehensive Node Version Manager (nvm) installation, configuration, and npm package management capabilities. This implementation provides a complete Node.js development environment setup with full idempotency.

## Enhanced Features

### 1. **Complete NVM Installation**
- Downloads and installs nvm using the official installation script
- Detects existing installations to prevent duplicate setups
- Provides clear status reporting throughout the process

### 2. **Shell Integration Configuration**
- Automatically adds nvm initialization code to `~/.zshrc`
- Uses `blockinfile` module to prevent duplicate entries
- Creates `.zshrc` if it doesn't exist
- Handles existing dotfiles configurations gracefully

### 3. **Node.js LTS Installation**
- Automatically installs the latest LTS version of Node.js
- Sets LTS as the default Node.js version
- Provides version verification and status reporting

### 4. **NPM Global Package Management**
- Centralized inventory of npm global packages
- Idempotent package installation (only installs missing packages)
- Clear status reporting for each package
- Easy to extend with additional packages

## Implementation Details

### **Software Inventory**
```yaml
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
```

### **NVM Installation with Idempotency**
```yaml
- name: Check if Node Version Manager (nvm) is installed
  stat:
    path: "{{ ansible_env.HOME }}/.nvm/nvm.sh"
  register: nvm_installed

- name: Install Node Version Manager (nvm)
  shell: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  when: not nvm_installed.stat.exists
```

### **Shell Configuration Management**
```yaml
- name: Check if nvm configuration exists in .zshrc
  shell: grep -q "NVM_DIR" "{{ ansible_env.HOME }}/.zshrc" 2>/dev/null
  register: nvm_config_exists
  failed_when: false
  changed_when: false

- name: Add nvm configuration to .zshrc
  blockinfile:
    path: "{{ ansible_env.HOME }}/.zshrc"
    marker: "# {mark} ANSIBLE MANAGED BLOCK - NVM Configuration"
    block: |
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    create: yes
  when: nvm_config_exists.rc != 0
```

### **NPM Package Management**
```yaml
- name: Check which npm global packages are already installed
  shell: |
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm list -g --depth=0 {{ item }} 2>/dev/null
  register: npm_package_check
  failed_when: false
  changed_when: false
  loop: "{{ npm_global_packages }}"
  when: nvm_version_check.rc == 0

- name: Install missing npm global packages
  shell: |
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    npm install -g {{ item.item }}
  when: 
    - nvm_version_check.rc == 0
    - npm_package_check.results is defined
    - item.rc != 0
  loop: "{{ npm_package_check.results }}"
```

## Key Benefits

### ✅ **Complete Environment Setup**
- Single playbook run sets up entire Node.js development environment
- No manual configuration required
- Consistent setup across different machines

### ✅ **Idempotent Operations**
- Safe to run multiple times
- Only installs missing components
- Prevents duplicate shell configurations
- Skips already installed npm packages

### ✅ **Proper Shell Integration**
- Automatically configures shell for nvm usage
- Works immediately after installation
- Handles existing dotfiles gracefully
- Uses proper shell sourcing techniques

### ✅ **Comprehensive Package Management**
- Centralized npm package inventory
- Easy to add/remove packages
- Version-aware installations
- Clear status reporting

## Usage Examples

### **Initial Setup**
```bash
ansible-playbook -c local -i localhost, ansible/macsible.yaml
```
**Result**: Installs nvm, configures shell, installs Node.js LTS, and all npm global packages.

### **Adding New NPM Packages**
1. Add package to `npm_global_packages` list in playbook
2. Run playbook again
```bash
ansible-playbook -c local -i localhost, ansible/macsible.yaml
```
**Result**: Only installs the new package, skips everything already installed.

### **Testing NVM Setup**
```bash
ansible-playbook -c local -i localhost, test-nvm-setup.yaml
```
**Result**: Comprehensive status report without making changes.

## Verification Commands

After running the playbook, verify the installation:

```bash
# Check nvm version
nvm --version

# Check Node.js version
node --version

# Check npm version
npm --version

# List global packages
npm list -g --depth=0

# Test package functionality
tsc --version        # TypeScript
nodemon --version    # Nodemon
http-server --help   # HTTP Server
```

## Troubleshooting

### **NVM Not Found After Installation**
```bash
# Reload shell configuration
source ~/.zshrc

# Or restart terminal
```

### **Permission Issues with Global Packages**
The playbook uses nvm's npm, which installs packages in user space, avoiding permission issues.

### **Adding Custom NPM Packages**
Edit the `npm_global_packages` list in the playbook:
```yaml
npm_global_packages:
  - "your-package-name"
  - "@scope/package-name"
```

### **Shell Configuration Conflicts**
The playbook uses `blockinfile` with markers to prevent conflicts with existing configurations.

## Advanced Configuration

### **Custom Node.js Version**
To install a specific Node.js version instead of LTS:
```yaml
- name: Install specific Node.js version
  shell: |
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 18.17.0
    nvm use 18.17.0
    nvm alias default 18.17.0
```

### **Multiple Node.js Versions**
```bash
# After nvm is installed, you can manually install multiple versions
nvm install 16
nvm install 18
nvm install 20
nvm list
```

## Integration with Existing Dotfiles

The playbook is designed to work alongside existing dotfiles:
- Checks for existing nvm configuration before adding
- Uses Ansible markers to identify managed blocks
- Won't interfere with custom shell configurations
- Can be safely run on systems with existing nvm installations

## Status Reporting

The enhanced playbook provides detailed status reporting:
- **NVM Installation**: INSTALLED/MISSING with version
- **Shell Configuration**: CONFIGURED/MISSING
- **Node.js**: INSTALLED with version
- **NPM Packages**: Individual status for each package
- **Comprehensive final report** with next steps

This implementation makes the playbook a complete solution for Node.js development environment setup on macOS, with enterprise-grade reliability and maintainability.
