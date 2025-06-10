# Display Server Configuration Guide

This guide explains how to configure and use the display server selection functionality in Dotsible, allowing you to choose between X11 and Wayland/Sway display servers for your Ubuntu and Arch Linux systems.

## Overview

Dotsible now supports configuring different display servers to meet your specific needs:

- **X11**: Traditional display server with broad compatibility
- **Wayland**: Modern display server with better security and performance
- **Sway**: Wayland compositor with i3-like tiling window manager

## Configuration Variables

### Global Configuration

Set these variables when running the playbook to specify your display server preference:

```bash
# For X11 (default)
ansible-playbook site.yml -e "display_server_preference=x11"

# For Wayland
ansible-playbook site.yml -e "display_server_preference=wayland"

# With specific desktop environment
ansible-playbook site.yml -e "display_server_preference=wayland desktop_environment=gnome"
```

### Supported Display Servers

#### X11
- **Description**: Traditional X Window System
- **Best for**: Maximum compatibility, older applications, gaming
- **Supported on**: Ubuntu, Arch Linux
- **Desktop Environments**: GNOME, KDE, XFCE, i3, Awesome, OpenBox

#### Wayland
- **Description**: Modern display server protocol
- **Best for**: Security, performance, modern applications
- **Supported on**: Ubuntu, Arch Linux
- **Desktop Environments**: GNOME, KDE, Sway, Hyprland (Arch only)

## Desktop Environment Compatibility

### Ubuntu

| Desktop Environment | X11 Support | Wayland Support | Default Session |
|-------------------|-------------|-----------------|----------------|
| GNOME             | ✅          | ✅              | Wayland        |
| KDE               | ✅          | ✅              | X11            |
| XFCE              | ✅          | ❌              | X11            |
| i3                | ✅          | ❌              | X11            |
| Sway              | ❌          | ✅              | Wayland        |

### Arch Linux

| Desktop Environment | X11 Support | Wayland Support | Default Session |
|-------------------|-------------|-----------------|----------------|
| GNOME             | ✅          | ✅              | Wayland        |
| KDE               | ✅          | ✅              | X11            |
| XFCE              | ✅          | ❌              | X11            |
| i3                | ✅          | ❌              | X11            |
| Sway              | ❌          | ✅              | Wayland        |
| Hyprland          | ❌          | ✅              | Wayland        |

## Usage Examples

### Basic Usage

1. **Default X11 setup** (no extra configuration needed):
   ```bash
   ansible-playbook site.yml --extra-vars "profile=developer"
   ```

2. **Wayland with GNOME**:
   ```bash
   ansible-playbook site.yml --extra-vars "profile=developer display_server_preference=wayland desktop_environment=gnome"
   ```

3. **Sway tiling window manager**:
   ```bash
   ansible-playbook site.yml --extra-vars "profile=developer display_server_preference=wayland desktop_environment=sway"
   ```

### Advanced Configuration

You can also set these preferences in your inventory files:

```yaml
# inventories/local/group_vars/workstations.yml
display_server_preference: wayland
desktop_environment: gnome

# Or in host-specific variables
# inventories/local/host_vars/my-laptop.yml
display_server_preference: x11
desktop_environment: i3
```

## Package Installation

The system automatically installs the appropriate packages based on your display server choice:

### X11 Packages
- Core X11 server and utilities
- Window managers (i3, awesome, openbox, etc.)
- Display managers (lightdm, gdm, sddm)
- X11-specific utilities (xclip, arandr, redshift)

### Wayland Packages
- Wayland core protocols and utilities
- Wayland compositors (sway, wayfire, hyprland)
- Wayland-specific utilities (wl-clipboard, grim, slurp)
- Display managers with Wayland support

## Service Configuration

Services are automatically configured based on your display server choice:

- **X11**: Enables appropriate display managers (lightdm, gdm, sddm)
- **Wayland**: Configures Wayland-compatible display managers
- **Sway**: No display manager required (direct login)

## Profile Integration

All GUI-enabled profiles now support display server selection:

- **Developer**: Full development environment with GUI applications
- **Gaming**: Optimized for gaming (typically X11 for compatibility)
- **Designer**: Creative tools with proper graphics acceleration

## Troubleshooting

### Common Issues

1. **Application compatibility**: Some applications may not work properly with Wayland
   - Solution: Use X11 for maximum compatibility

2. **Gaming performance**: Some games perform better on X11
   - Solution: Use X11 for gaming setups

3. **Screen sharing**: May not work properly in Wayland
   - Solution: Use X11 or check application-specific Wayland support

### Switching Display Servers

To switch between display servers after installation:

1. **Re-run the playbook** with different settings:
   ```bash
   ansible-playbook site.yml --extra-vars "display_server_preference=wayland"
   ```

2. **Manual switching** at login screen:
   - Look for session options in your display manager
   - Choose between X11 and Wayland sessions

## Best Practices

1. **For new users**: Start with X11 for maximum compatibility
2. **For security-conscious users**: Use Wayland for better isolation
3. **For gaming**: Use X11 for best compatibility
4. **For development**: Either works, choose based on your needs
5. **For servers**: Display server configuration is not applicable

## Configuration Files

The display server configuration affects these files:

- `group_vars/ubuntu.yml`: Ubuntu-specific display server packages and services
- `group_vars/archlinux.yml`: Arch Linux-specific display server packages and services
- `group_vars/all/profiles.yml`: Profile-specific display server preferences

## Future Enhancements

Planned improvements include:

- Support for additional Wayland compositors
- Automatic display server detection and recommendation
- Per-application display server preferences
- Integration with dotfiles for display server-specific configurations
