# macOS Enterprise Management Guide

This guide explains how to use Dotsible's enterprise-friendly macOS features, including MDM compatibility and desktop icon layout preservation.

## Overview

Dotsible's macOS enterprise management provides:

- **MDM Compatibility**: Automatic detection and respect for enterprise management systems
- **Desktop Layout Management**: Backup and restore desktop icon arrangements
- **Enterprise Tools**: Compliance checking, system reporting, and management utilities
- **Safe Configuration**: User-level preferences that don't conflict with enterprise policies

## Features

### MDM Detection and Compatibility

Automatically detects and works with:
- **Jamf Pro** (most common enterprise MDM)
- **Microsoft Intune** 
- **VMware Workspace ONE**
- **Kandji**
- **Mosyle**
- **Addigy**
- **Configuration Profiles** (any MDM solution)

### Desktop Icon Layout Management

- Backup current desktop icon arrangements
- Restore previously saved layouts
- Support for multiple layout profiles
- Automatic backup scheduling (optional)
- Cross-user and cross-system compatibility

### Enterprise Tools

- System information reporting
- Compliance status checking
- MDM detection utilities
- Desktop management commands
- Enterprise policy validation

## Quick Start

### 1. Basic Enterprise Setup

```bash
# Run with enterprise features enabled
ansible-playbook site.yml -e "profile=developer"

# The system will automatically:
# - Detect any MDM management
# - Skip conflicting operations
# - Install enterprise management tools
```

### 2. Desktop Layout Management

```bash
# Capture your current desktop layout
dotsible-capture-desktop

# Later, restore the layout
dotsible-restore-desktop

# List available backups
dotsible-list-desktop-backups
```

### 3. Enterprise Information

```bash
# Check MDM status
dotsible-detect-mdm

# View system information
dotsible-system-info

# Check compliance
dotsible-compliance-check
```

## Configuration Variables

### MDM Configuration

```yaml
# Enable/disable MDM detection (default: true)
macos_detect_mdm: true

# Respect MDM restrictions (default: true)
macos_respect_mdm: true

# Force ignore MDM (use with caution, default: false)
macos_force_ignore_mdm: false
```

### Desktop Layout Configuration

```yaml
# Enable desktop layout management (default: true)
macos_desktop_layout_enabled: true

# Backup current layout during playbook run
macos_backup_desktop_layout: true

# Restore a specific layout
macos_restore_desktop_layout: true
macos_desktop_backup_timestamp: "20240101T120000"

# Apply a desktop profile
macos_apply_desktop_profile: true
macos_desktop_layout_profile: "developer"  # options: default, developer, minimal

# Enable automatic backups
macos_auto_backup_desktop: true
```

### System Preferences

```yaml
# Apply developer-friendly preferences
macos_apply_developer_preferences: true

# Apply system-level preferences (only if no MDM conflicts)
macos_apply_system_preferences: false

# Set hostname (only if no MDM conflicts)
macos_set_hostname: false

# Backup before restoring layout
macos_backup_before_restore: true
```

## Usage Examples

### Enterprise Workstation Setup

```bash
# Complete enterprise workstation setup
ansible-playbook site.yml \
  -e "profile=developer" \
  -e "macos_backup_desktop_layout=true" \
  -e "macos_apply_developer_preferences=true"
```

### Desktop Layout Workflow

```bash
# 1. Initial setup and capture
ansible-playbook site.yml -e "profile=developer"
# Manually arrange desktop icons as desired
dotsible-capture-desktop

# 2. Later restoration
ansible-playbook site.yml \
  -e "macos_restore_desktop_layout=true" \
  -e "macos_desktop_backup_timestamp=20240101T120000"

# Or use command line
dotsible-restore-desktop 20240101T120000
```

### Override MDM Restrictions (Advanced)

```bash
# Use with caution in enterprise environments
ansible-playbook site.yml \
  -e "profile=developer" \
  -e "macos_force_ignore_mdm=true" \
  -e "macos_apply_system_preferences=true"
```

## Desktop Layout Profiles

### Default Profile
- Standard icon size (64px)
- Normal grid spacing
- Bottom labels
- No automatic arrangement

### Developer Profile  
- Smaller icons (48px)
- Tighter grid spacing
- Arranged by kind
- Optimized for development workflow

### Minimal Profile
- Small icons (32px)
- Compact spacing
- Right-side labels
- Arranged by name

## Command Reference

### Desktop Management
```bash
dotsible-capture-desktop      # Capture current layout
dotsible-backup-desktop       # Create backup
dotsible-restore-desktop      # Restore layout
dotsible-list-desktop-backups # List backups
```

### Enterprise Tools
```bash
dotsible-detect-mdm          # Detect MDM management
dotsible-system-info         # System information
dotsible-compliance-check    # Compliance status
dotsible-help               # Show help
```

### Shell Aliases
```bash
capture-desktop             # = dotsible-capture-desktop
backup-desktop             # = dotsible-backup-desktop
restore-desktop            # = dotsible-restore-desktop
detect-mdm                 # = dotsible-detect-mdm
system-info               # = dotsible-system-info
compliance-check          # = dotsible-compliance-check
```

## File Locations

### Configuration
- `~/.dotsible/` - Main configuration directory
- `~/.dotsible/desktop_layouts/` - Desktop layout backups
- `~/.dotsible/scripts/` - Management scripts
- `~/.local/bin/dotsible-*` - Command-line tools

### Backups and Reports
- `~/.dotsible/desktop_layouts/latest` - Latest desktop backup
- `~/.dotsible/mdm_detection_report.txt` - MDM detection results
- `~/.dotsible/enterprise_verification_*.txt` - Verification reports
- `~/.dotsible/README.md` - Enterprise documentation

### System Files (Managed)
- `~/Library/Preferences/com.apple.finder.plist` - Finder preferences
- `~/Library/Preferences/com.apple.dock.plist` - Dock configuration
- `~/Library/Preferences/.GlobalPreferences.plist` - Global preferences

## Troubleshooting

### MDM Detection Issues

**Problem**: MDM not detected when it should be
```bash
# Manual check
dotsible-detect-mdm

# Force detection
ansible-playbook site.yml -e "macos_detect_mdm=true"
```

**Problem**: Too many restrictions applied
```bash
# Override (use carefully)
ansible-playbook site.yml -e "macos_respect_mdm=false"
```

### Desktop Layout Issues

**Problem**: Layout not restoring correctly
```bash
# Check available backups
dotsible-list-desktop-backups

# Try latest backup
dotsible-restore-desktop latest

# Manual verification
defaults read com.apple.finder DesktopViewSettings
```

**Problem**: Permission denied on plist files
```bash
# Check file permissions
ls -la ~/Library/Preferences/com.apple.finder.plist

# Reset permissions if needed
chmod 644 ~/Library/Preferences/com.apple.finder.plist
```

### Script Issues

**Problem**: Commands not found
```bash
# Check PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "OK" || echo "Missing"

# Add to PATH manually
export PATH="$HOME/.local/bin:$PATH"

# Restart shell
exec $SHELL
```

## Best Practices

### Enterprise Environments
1. **Always test** in a non-production environment first
2. **Respect MDM policies** - don't override unless necessary
3. **Document changes** for IT compliance
4. **Use user-level preferences** when possible
5. **Coordinate with IT** for system-level changes

### Desktop Layout Management
1. **Capture layouts** after manual arrangement
2. **Test restoration** before relying on backups
3. **Use descriptive backup names** for multiple layouts
4. **Regular backups** for important arrangements
5. **Cross-system compatibility** may require adjustment

### Security Considerations
1. **Backup sensitive data** before major changes
2. **Verify compliance** after configuration
3. **Monitor for policy violations** in enterprise environments
4. **Use secure channels** for configuration distribution
5. **Regular audits** of system configuration

## Integration with Profiles

The enterprise features integrate seamlessly with existing Dotsible profiles:

```yaml
# In group_vars/all/profiles.yml
developer:
  features:
    - display_server_support
    - development_tools
    - macos_enterprise_management  # New feature
  
  macos_enterprise:
    desktop_layout_profile: "developer"
    auto_backup_enabled: true
    respect_mdm: true
```

## Support

### Getting Help
- Run `dotsible-help` for command reference
- Check `~/.dotsible/README.md` for local documentation
- Review verification reports in `~/.dotsible/`
- Contact IT administrator for enterprise policy questions

### Reporting Issues
- Include output from `dotsible-system-info`
- Provide MDM detection results from `dotsible-detect-mdm`
- Include relevant log files from `~/.dotsible/`
- Specify macOS version and enterprise environment details
