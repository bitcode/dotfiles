# Conditional Dotfiles Deployment System - Implementation Guide

## Overview

This guide documents the comprehensive conditional dotfiles deployment system designed for the dotsible framework. The system intelligently selects which configurations to deploy based on platform, window manager, profile, and environment type detection.

## 🎯 Core Architecture

### **Conditional Logic Engine**

The system uses a multi-layered filtering approach:

1. **Platform Compatibility** - Filters applications by OS support
2. **Display Server Detection** - Separates X11/Wayland/headless applications  
3. **Window Manager Integration** - Deploys WM-specific configurations
4. **Profile-Based Selection** - Applies minimal/developer/enterprise filters
5. **Environment Type Awareness** - Handles personal vs enterprise restrictions

### **Key Components**

```
roles/dotfiles/
├── vars/
│   └── conditional_deployment.yml     # Compatibility matrices and rules
├── tasks/
│   ├── conditional_deployment.yml     # Main conditional logic engine
│   ├── conditional_application_deployment.yml  # Application filtering
│   ├── deploy_application_dotfiles.yml # Individual app deployment
│   └── post_deploy/                   # App-specific post-deployment tasks
│       └── neovim.yml                 # Example: Neovim-specific tasks
```

## 🔍 Detection Capabilities

### **Enhanced Environment Detection**

The system detects:
- **Platform**: macOS, Windows, Arch Linux, Ubuntu, etc.
- **Display Server**: X11, Wayland, or headless
- **Window Manager**: i3, Hyprland, Sway, GNOME, KDE
- **Session Type**: GUI, SSH, container
- **Environment**: Personal vs Enterprise

### **Detection Methods**

```yaml
# Example detection logic
detected_display_server: >-
  {%- if has_wayland_session -%}
    wayland
  {%- elif has_gui_session -%}
    x11
  {%- else -%}
    none
  {%- endif -%}
```

## 📋 Compatibility Matrix

### **Application Categories**

1. **Universal**: git, neovim, tmux, zsh (work everywhere)
2. **Unix-like**: fish, alacritty (macOS + Linux)
3. **Linux-only**: i3, hyprland, polybar (Linux only)
4. **X11-specific**: i3, polybar, rofi (requires X11)
5. **Wayland-specific**: hyprland, sway, waybar (requires Wayland)
6. **Platform-specific**: hammerspoon (macOS), powershell (Windows)

### **Example Scenarios**

| Platform | Display Server | Window Manager | Deployed Apps |
|----------|----------------|----------------|---------------|
| macOS | Aqua | None | git, neovim, tmux, zsh, hammerspoon |
| Arch Linux | X11 | i3 | git, neovim, tmux, zsh, i3, polybar, rofi |
| Arch Linux | Wayland | Hyprland | git, neovim, tmux, zsh, hyprland, waybar, wofi |
| Windows | None | None | git, neovim, powershell, windows-terminal |
| Ubuntu Server | None | None | git, vim, tmux, zsh (minimal set) |

## 🚀 Usage Examples

### **Basic Execution with Conditional Logic**

```bash
# Automatic detection and deployment
./run-dotsible.sh --tags dotfiles

# Developer profile with conditional filtering
./run-dotsible.sh --profile developer --tags dotfiles

# Enterprise environment with restrictions
./run-dotsible.sh --profile enterprise --environment enterprise --tags dotfiles
```

### **Manual Override Options**

```bash
# Force specific window manager detection
./run-dotsible.sh -e "detected_window_manager=i3" --tags dotfiles

# Override display server detection
./run-dotsible.sh -e "detected_display_server=wayland" --tags dotfiles

# Skip conditional logic (deploy everything)
./run-dotsible.sh -e "skip_conditional_filtering=true" --tags dotfiles
```

## 📊 Clean Output Integration

### **Status Indicators**

The system integrates with dotsible's clean output system:

```
🧠 CONDITIONAL DEPLOYMENT ENGINE
📋 DEPLOYMENT PLAN
🎯 Platform: Darwin (macOS)
🖥️  Display Server: Aqua
👤 Profile: Developer
🏢 Environment: Personal

📦 Applications to Deploy (8):
• ✅ git
• ✅ neovim  
• ✅ tmux
• ✅ zsh
• ✅ starship
• ✅ alacritty
• ✅ ranger
• ✅ hammerspoon

⏭️ Excluded Applications (12):
• ❌ i3 (Linux-only application on Darwin)
• ❌ polybar (X11-only application with Aqua display server)
• ❌ hyprland (Wayland-only application with Aqua display server)
```

### **Application Deployment Status**

```
🚀 CONDITIONAL APPLICATION DEPLOYMENT
🔧 Neovim (Universal compatibility)
✅ FOUND: neovim dotfiles
✅ LINKED: neovim → ~/.config/nvim

🔧 i3 (Linux compatibility)  
⏭️ SKIPPED: i3 (Linux-only application on Darwin)
```

## 🔧 Configuration Examples

### **Profile-Specific Filtering**

```yaml
# Minimal profile - only essential tools
dotfiles_profile_applications:
  minimal:
    required: [git, vim, zsh]
    excluded: [window_managers, gui_applications]

# Developer profile - full development environment  
  developer:
    required: [git, neovim, tmux, zsh, starship]
    window_manager_support: true
    gui_applications: true

# Enterprise profile - security-focused
  enterprise:
    required: [git, neovim, tmux, zsh]
    security_focused: true
    restricted_configs: true
```

### **Platform-Specific Exclusions**

```yaml
dotfiles_platform_exclusions:
  Darwin:  # macOS
    exclude: [linux_only, x11_only, wayland_only, window_managers]
    include_alternatives: [hammerspoon, karabiner, rectangle]
  
  Windows:
    exclude: [linux_only, unix_like, x11_only, wayland_only, window_managers]
    include_alternatives: [powershell, windows_terminal]
```

### **Window Manager Dependencies**

```yaml
dotfiles_window_manager_dependencies:
  i3:
    requires: [x11]
    suggests: [polybar, rofi, picom, dunst]
    conflicts: [hyprland, sway, gnome, kde]
  
  hyprland:
    requires: [wayland]
    suggests: [waybar, wofi, mako, swaync]
    conflicts: [i3, sway, x11_only_apps]
```

## 🔄 Integration with Existing Roles

### **Application Role Integration**

The conditional system works with existing application roles:

```yaml
# site.yml integration
- role: applications/neovim
  when: "'neovim' in dotfiles_conditional_applications"
  tags: ['applications', 'neovim']

- role: applications/i3  
  when: 
    - "'i3' in dotfiles_conditional_applications"
    - "detected_window_manager == 'i3'"
  tags: ['applications', 'i3']
```

### **Backward Compatibility**

The system maintains full backward compatibility:
- Existing dotfiles continue to work
- Manual overrides available for all detection
- Fallback to traditional deployment if conditional logic fails

## 🛠️ Extensibility

### **Adding New Applications**

1. Add to compatibility matrix in `conditional_deployment.yml`
2. Create application-specific post-deployment tasks if needed
3. Update platform exclusions if necessary

### **Adding New Platforms**

1. Extend platform detection in `environment_detection.yml`
2. Add platform-specific paths in `vars/[platform].yml`
3. Update compatibility matrices

### **Adding New Window Managers**

1. Add detection logic in `environment_detection.yml`
2. Define dependencies in `conditional_deployment.yml`
3. Create application roles for WM-specific tools

## 🎉 Benefits

### **Intelligent Deployment**
- ✅ Only deploys compatible applications
- ✅ Prevents configuration conflicts
- ✅ Optimizes for specific environments

### **Maintainable Architecture**
- ✅ Centralized compatibility logic
- ✅ Extensible for new platforms/applications
- ✅ Clear separation of concerns

### **User Experience**
- ✅ Clean, informative output
- ✅ Automatic environment detection
- ✅ Manual override capabilities
- ✅ Preserves existing workflows

This conditional deployment system transforms dotsible from a simple dotfiles manager into an intelligent, context-aware configuration deployment platform that adapts to any environment while maintaining the clean, professional user experience you've established.
