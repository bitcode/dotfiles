# Dotfiles Repository Restructuring Plan
# Preparing for Merger with Dotsible

## Executive Summary

This document outlines the strategic restructuring of the current dotfiles repository (`/Users/mdrozrosario/dotfiles`) to prepare for merger with the dotsible repository (`/Users/mdrozrosario/dotsible`). The goal is to preserve all valuable configurations while adopting dotsible's superior architecture for cross-platform support.

## Current State Analysis

### Dotfiles Repository Assets to Preserve
1. **Proven macOS Automation**: `ansible/macsible.yaml` - 463 lines of battle-tested idempotent package management
2. **Comprehensive Application Configs**: nvim, tmux, zsh, alacritty, i3, hyprland, starship
3. **NixOS Integration**: Complete flake.nix and configuration.nix setup
4. **MCP Integration**: Model Context Protocol packages for AI development
5. **Utility Scripts**: Extensive collection in `scripts/` directory
6. **Window Manager Support**: i3, hyprland, sway configurations
7. **Cross-Platform Potential**: Arch Linux scripts and configurations

### Dotsible Architecture Benefits
1. **Role-Based Organization**: Modular, maintainable structure
2. **Cross-Platform Support**: Unified approach for multiple OS
3. **Profile System**: Different configurations for different use cases
4. **Enterprise Features**: Backup, rollback, validation, testing
5. **Advanced Templating**: Jinja2 templates for dynamic configurations

## Phase 1: Repository Structure Preparation

### 1.1 Create New Directory Structure
Transform current flat structure into dotsible-compatible hierarchy:

```
dotfiles/ (current)
├── ansible/macsible.yaml          → roles/platform_specific/macos/
├── nvim/                          → files/dotfiles/nvim/
├── tmux/                          → files/dotfiles/tmux/
├── zsh/                           → files/dotfiles/zsh/
├── scripts/                       → scripts/ (enhanced)
├── nixos/                         → nixos/ (preserved)
└── [other configs]                → files/dotfiles/[app]/
```

### 1.2 Preserve Critical Assets
- **macsible.yaml**: Extract into roles and maintain as macOS playbook
- **NixOS configs**: Keep as special platform with integration role
- **Application configs**: Organize into application-specific roles
- **Scripts**: Enhance and integrate into dotsible script framework

## Phase 2: Configuration Migration Strategy

### 2.1 Application Role Creation
Transform current configurations into dotsible roles:

1. **Neovim Role** (`roles/applications/neovim/`)
   - Preserve current comprehensive configuration
   - Add cross-platform package management
   - Create templates for OS-specific paths

2. **Terminal Emulator Roles**
   - Alacritty: Port configuration to role
   - Add cross-platform font and theme management

3. **Window Manager Roles**
   - i3: Create role from current config
   - Hyprland: Create role from current config
   - Sway: Create role from current config

4. **Shell Enhancement Roles**
   - ZSH: Merge current config with dotsible's Oh My Zsh
   - Starship: Create role for prompt configuration

### 2.2 Platform-Specific Integration
1. **macOS Platform Role**
   - Extract macsible.yaml logic into structured roles
   - Maintain idempotent package management approach
   - Add enterprise features from dotsible

2. **NixOS Platform Role**
   - Create bridge between Ansible and Nix
   - Maintain declarative system management
   - Add profile-based Nix configurations

3. **Linux Platform Roles**
   - Arch Linux: Enhance current arch.sh into proper role
   - Ubuntu: Create new role based on dotsible patterns

## Phase 3: Advanced Feature Integration

### 3.1 Profile System Enhancement
Create profiles that leverage both repositories' strengths:

1. **Developer Profile** (Enhanced)
   - Include current comprehensive tool setup
   - Add MCP packages for AI development
   - Window manager configurations

2. **NixOS Profile**
   - Declarative system management
   - Flake-based configuration
   - Integration with Ansible for user-space configs

3. **Enterprise Profile**
   - macOS enterprise features from dotsible
   - Security and compliance configurations
   - Backup and monitoring capabilities

### 3.2 Cross-Platform Package Management
Unify package management while preserving platform strengths:

1. **Package Mapping System**
   - Map packages across homebrew, pacman, apt, nix
   - Maintain current MCP package integration
   - Add fallback strategies for missing packages

2. **Installation Strategy Hierarchy**
   - Package manager (preferred)
   - Manual installation (current approach)
   - Source compilation (fallback)

## Phase 4: Testing and Validation Framework

### 4.1 Preserve Current Functionality
- Test current macsible.yaml functionality
- Validate all application configurations
- Ensure NixOS integration works

### 4.2 Add Dotsible Testing Features
- Role-specific tests
- Integration tests across platforms
- Backup and rollback testing

## Implementation Roadmap

### Week 1: Structure Preparation
1. Create new directory structure
2. Move configurations to appropriate locations
3. Preserve all current functionality

### Week 2: Role Creation
1. Create application roles from current configs
2. Extract macsible.yaml into platform roles
3. Create NixOS integration role

### Week 3: Profile Integration
1. Create enhanced profiles
2. Add cross-platform package mapping
3. Integrate MCP packages

### Week 4: Testing and Validation
1. Comprehensive testing of all functionality
2. Documentation updates
3. Migration scripts for smooth transition

## Risk Mitigation

### Backup Strategy
- Full repository backup before restructuring
- Incremental backups at each phase
- Rollback procedures documented

### Compatibility Preservation
- Maintain current macsible.yaml as fallback
- Keep original configurations accessible
- Gradual migration approach

### Testing Strategy
- Test on clean systems
- Validate each application configuration
- Ensure cross-platform compatibility

## Success Criteria

1. **Functionality Preservation**: All current features work
2. **Architecture Enhancement**: Dotsible structure adopted
3. **Cross-Platform Ready**: Prepared for multi-OS support
4. **Enterprise Ready**: Advanced features integrated
5. **Maintainable**: Clear, documented, testable structure

## Next Steps

1. **Approve this restructuring plan**
2. **Create backup of current repository**
3. **Begin Phase 1: Structure Preparation**
4. **Implement incremental changes with testing**
5. **Prepare for dotsible merger**

This restructuring will create a solid foundation for merging with dotsible while preserving all the valuable configurations and automation you've built.
