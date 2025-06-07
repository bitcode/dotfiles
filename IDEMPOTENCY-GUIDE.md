# Ansible macOS Playbook Idempotency Guide

## Overview

The `ansible/macsible.yaml` playbook has been enhanced with comprehensive idempotency checks that make it safe to run repeatedly. The playbook will only install software that's missing and skip items that are already present on the system.

## Key Idempotency Features

### 1. **Software Detection Methods**

#### Homebrew Packages
```yaml
- name: Check which Homebrew packages are already installed
  shell: brew list {{ item }} 2>/dev/null
  register: homebrew_package_check
  failed_when: false
  changed_when: false
  loop: "{{ homebrew_packages }}"

- name: Install missing Homebrew packages
  community.general.homebrew:
    name: "{{ item.item }}"
    state: present
  when: item.rc != 0
  loop: "{{ homebrew_package_check.results }}"
```

#### Homebrew Casks
```yaml
- name: Check which Homebrew casks are already installed
  shell: brew list --cask {{ item }} 2>/dev/null
  register: homebrew_cask_check
  failed_when: false
  changed_when: false
  loop: "{{ homebrew_casks }}"

- name: Install missing Homebrew casks
  community.general.homebrew_cask:
    name: "{{ item.item }}"
    state: present
  when: item.rc != 0
  loop: "{{ homebrew_cask_check.results }}"
```

#### Manual Installations
```yaml
- name: Check if Rust is installed
  shell: rustc --version
  register: rust_check
  failed_when: false
  changed_when: false

- name: Install Rust
  shell: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  when: rust_check.rc != 0
```

#### Application Installations
```yaml
- name: Check if iTerm2 is already installed
  stat:
    path: /Applications/iTerm2.app
  register: iterm2_installed

- name: Download iTerm2 if not installed
  get_url:
    url: https://iterm2.com/downloads/stable/latest
    dest: "{{ ansible_env.HOME }}/Downloads/iTerm2.zip"
  when: not iterm2_installed.stat.exists
```

### 2. **System Prerequisites**

#### Xcode Command Line Tools
```yaml
- name: Check if Xcode Command Line Tools are installed
  stat:
    path: /Library/Developer/CommandLineTools/usr/bin/git
  register: xcode_tools_installed

- name: Install Xcode Command Line Tools
  shell: xcode-select --install
  when: not xcode_tools_installed.stat.exists
```

#### Homebrew
```yaml
- name: Check if Homebrew is installed
  stat:
    path: /opt/homebrew/bin/brew
  register: homebrew_installed

- name: Install Homebrew
  shell: |
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  when: not homebrew_installed.stat.exists
```

### 3. **Software Inventory Management**

The playbook maintains a centralized inventory of all managed software:

```yaml
vars:
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
    - name: "Node Version Manager (nvm)"
      check_path: "~/.nvm/nvm.sh"
    - name: "Go"
      check_command: "go version"
      version_pattern: "go1.21"
```

### 4. **Status Reporting**

The playbook provides clear feedback about what's installed vs. missing:

```yaml
- name: Display Homebrew package status
  debug:
    msg: "{{ item.item }}: {{ 'INSTALLED' if item.rc == 0 else 'MISSING' }}"
  loop: "{{ homebrew_package_check.results }}"
```

### 5. **Architecture-Aware Installation**

For tools like Go, the playbook detects the CPU architecture:

```yaml
- name: Detect CPU architecture for Go download
  shell: uname -m
  register: cpu_arch
  changed_when: false
  when: go_version_check.rc != 0

- name: Set Go download URL based on architecture
  set_fact:
    go_download_url: "https://go.dev/dl/go1.21.5.darwin-{{ 'arm64' if cpu_arch.stdout == 'arm64' else 'amd64' }}.pkg"
  when: go_version_check.rc != 0
```

## Benefits of Idempotency

### ✅ **Safe to Run Repeatedly**
- No duplicate installations
- No wasted time re-installing existing software
- No conflicts from multiple installation attempts

### ✅ **Clear Status Visibility**
- See what's already installed vs. what needs to be installed
- Track your complete software inventory
- Identify manually installed vs. Ansible-managed software

### ✅ **Efficient Execution**
- Only performs necessary operations
- Skips checks for already-installed software
- Minimal system impact on subsequent runs

### ✅ **Reliable State Management**
- Consistent environment across multiple runs
- Predictable outcomes
- Easy to add new software without affecting existing installations

## Usage Examples

### Initial Setup (Fresh System)
```bash
ansible-playbook -c local -i localhost, ansible/macsible.yaml
```
**Result**: Installs all missing software, skips system prerequisites if already present.

### Adding New Software
1. Add package to appropriate inventory list in `vars` section
2. Run playbook again
```bash
ansible-playbook -c local -i localhost, ansible/macsible.yaml
```
**Result**: Only installs the new software, skips everything already installed.

### System Verification
```bash
ansible-playbook -c local -i localhost, test-idempotency.yaml
```
**Result**: Shows current installation status without making changes.

## Best Practices

### 1. **Always Use Detection Before Installation**
```yaml
# ✅ Good - Check first, then install conditionally
- name: Check if tool is installed
  shell: which tool_name
  register: tool_check
  failed_when: false
  changed_when: false

- name: Install tool if missing
  shell: install_command
  when: tool_check.rc != 0

# ❌ Bad - Install without checking
- name: Install tool
  shell: install_command
```

### 2. **Use Appropriate Detection Methods**
- **Homebrew packages**: `brew list package_name`
- **Homebrew casks**: `brew list --cask cask_name`
- **Applications**: `stat` module to check `/Applications/App.app`
- **Command-line tools**: `which command` or `command --version`
- **Files/directories**: `stat` module

### 3. **Maintain Software Inventory**
Keep the `vars` section updated with all managed software for easy tracking and modification.

### 4. **Test Idempotency**
Run the playbook multiple times to ensure it doesn't make unnecessary changes on subsequent runs.

## Troubleshooting

### False Positives
If a tool shows as "MISSING" but is actually installed:
1. Check the detection method
2. Verify the command or path being checked
3. Update the detection logic if needed

### False Negatives
If a tool shows as "INSTALLED" but installation fails:
1. The detection method may be too broad
2. Check for version-specific requirements
3. Add more specific version checking

This idempotency system ensures your macOS development environment setup is reliable, efficient, and maintainable.
