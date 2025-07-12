# Dotfiles Symlink Fixes and Cross-Platform Automation

## Overview

This document describes the comprehensive fixes implemented to resolve critical symlink issues in the dotfiles deployment automation, specifically addressing ZSH and tmux configuration problems while ensuring cross-platform compatibility.

## Issues Resolved

### 1. ZSH Configuration Symlink Issues

**Problem**: Oh-My-Zsh installation was creating backup files that interfered with GNU Stow deployment:
- `.zshrc.pre-oh-my-zsh` symlink was created instead of `.zshrc`
- Oh-My-Zsh prompt and plugins were not loading
- Stow deployment was pointing to wrong symlink names

**Solution**: Added comprehensive pre-deployment cleanup and post-deployment validation:
- Detect and remove incorrect `.zshrc.pre-oh-my-zsh` symlinks
- Backup existing non-symlink `.zshrc` files before stow deployment
- Create correct `.zshrc` symlink if stow deployment fails
- Validate symlinks after deployment and fix automatically

### 2. Tmux Configuration Symlink Issues

**Problem**: Tmux configuration was not being properly symlinked:
- `.tmux.conf` file was missing from home directory
- Stow was creating symlinks in wrong directory due to incorrect target specification
- Conflicting deployment methods between tmux role and dotfiles role

**Solution**: Enhanced stow deployment with proper target directory handling:
- Ensure stow uses `--target={{ ansible_user_dir }}` consistently
- Remove conflicting copy tasks from tmux role
- Add automatic symlink creation if stow deployment fails
- Cross-platform path detection for stow command

### 3. Cross-Platform Compatibility Issues

**Problem**: Hardcoded paths and macOS-specific assumptions:
- Hardcoded `/home/bit` paths instead of `{{ ansible_user_dir }}`
- macOS ARM64 vs Intel stow path differences
- Inconsistent stow command detection

**Solution**: Comprehensive cross-platform variable usage:
- Replace all hardcoded paths with `{{ ansible_user_dir }}`
- Dynamic stow command path detection for macOS ARM64/Intel and Linux
- Fallback stow command detection with multiple path attempts

## Implementation Details

### Enhanced Dotfiles Role Tasks

#### 1. Pre-Deployment Cleanup
```yaml
- name: Check for Oh-My-Zsh backup files that interfere with stow
- name: Remove incorrect Oh-My-Zsh symlink that blocks stow
- name: Check for existing .zshrc that might conflict with stow
- name: Backup existing .zshrc if it's not a symlink
- name: Remove non-symlink .zshrc to allow stow deployment
```

#### 2. Cross-Platform Stow Command Detection
```yaml
- name: Set stow command path (cross-platform)
  set_fact:
    stow_command: >-
      {%- if ansible_os_family == 'Darwin' -%}
        {%- if ansible_architecture == 'arm64' -%}
          /opt/homebrew/bin/stow
        {%- else -%}
          /usr/local/bin/stow
        {%- endif -%}
      {%- else -%}
        stow
      {%- endif -%}
```

#### 3. Post-Deployment Validation and Fixes
```yaml
- name: Fix critical symlink issues discovered during verification
```

This task automatically:
- Detects missing or broken symlinks
- Creates correct symlinks for ZSH and tmux configurations
- Backs up existing files before replacement
- Provides detailed logging of all fixes applied

### Stow Deployment Improvements

#### Enhanced Target Directory Handling
- All stow commands now use explicit `--target="{{ ansible_user_dir }}"` parameter
- Cross-platform stow command detection with fallback paths
- Proper working directory management for stow operations

#### Robust Error Handling
- Multiple fallback paths for stow command detection
- Automatic symlink creation if stow deployment fails
- Comprehensive validation after deployment
- Detailed logging for troubleshooting

## Testing and Validation

### Automated Validation Tasks
The automation now includes comprehensive validation that checks:
1. **ZSH Configuration**: Verifies `~/.zshrc` symlink exists and points to correct target
2. **Tmux Configuration**: Verifies `~/.tmux.conf` symlink exists and points to correct target
3. **Cleanup Verification**: Ensures no incorrect symlinks remain
4. **Cross-Platform Paths**: All paths use `{{ ansible_user_dir }}` variable

### Manual Testing Commands
```bash
# Test ZSH configuration
ls -la ~/.zshrc
zsh -c "echo 'ZSH test successful'"

# Test tmux configuration  
ls -la ~/.tmux.conf
tmux -V

# Verify Oh-My-Zsh is working
zsh -c "echo \$ZSH_THEME"
```

## Platform Support

### macOS
- **ARM64 (Apple Silicon)**: `/opt/homebrew/bin/stow`
- **Intel**: `/usr/local/bin/stow`
- **Fallback**: `which stow`

### Linux
- **Primary**: `stow` (from PATH)
- **Fallback**: `/usr/bin/stow`

### Windows
- **Status**: Not supported (Windows-specific tasks are skipped)

## Idempotency

All tasks are designed to be idempotent:
- **Detection**: Check current state before making changes
- **Backup**: Preserve existing configurations before replacement
- **Validation**: Verify changes were applied correctly
- **Cleanup**: Remove temporary files and incorrect symlinks

## Usage

### Full Deployment
```bash
ansible-playbook -i inventories/local/hosts.yml site.yml \
  -e profile=developer \
  -e dotsible_window_manager=i3 \
  -e environment_type=personal \
  --tags dotfiles \
  --limit localhost
```

### ZSH-Only Deployment
```bash
ansible-playbook -i inventories/local/hosts.yml site.yml \
  -e profile=developer \
  --tags zsh,dotfiles \
  --limit localhost
```

### Tmux-Only Deployment
```bash
ansible-playbook -i inventories/local/hosts.yml site.yml \
  -e profile=developer \
  --tags tmux,dotfiles \
  --limit localhost
```

## Troubleshooting

### Common Issues and Solutions

1. **Symlink pointing to wrong location**
   - **Cause**: Stow executed from wrong directory
   - **Solution**: Automation now enforces correct working directory

2. **Oh-My-Zsh not loading**
   - **Cause**: `.zshrc.pre-oh-my-zsh` symlink instead of `.zshrc`
   - **Solution**: Automatic cleanup and correct symlink creation

3. **Tmux configuration not found**
   - **Cause**: Missing symlink or wrong target directory
   - **Solution**: Post-deployment validation and automatic fix

4. **Cross-platform path issues**
   - **Cause**: Hardcoded paths for specific OS
   - **Solution**: Dynamic path detection using Ansible variables

## Future Improvements

1. **Enhanced Validation**: Add more comprehensive symlink validation
2. **Rollback Capability**: Implement automatic rollback on deployment failure
3. **Configuration Testing**: Add functional testing of deployed configurations
4. **Performance Optimization**: Reduce deployment time through parallel operations
