# 📁 Dotsible Dotfiles Management Guide

A comprehensive guide for managing dotfiles within the dotsible conditional deployment system.

## 🏗️ Directory Structure

The dotsible conditional dotfiles system uses a well-organized structure in `files/dotfiles/` that maps to target locations based on platform-specific rules:

```
files/dotfiles/
├── nvim/                    # → ~/.config/nvim/ (Unix) | %LOCALAPPDATA%/nvim/ (Windows)
│   ├── init.lua            # Main Neovim configuration
│   └── lua/config/         # Additional Lua modules
├── git/                     # → Individual files mapped via dotfiles_file_mappings
│   └── .gitconfig          # → ~/.gitconfig
├── zsh/                     # → Individual files mapped via dotfiles_file_mappings  
│   └── .zshrc              # → ~/.zshrc
├── tmux/                    # → Individual files mapped via dotfiles_file_mappings
│   └── .tmux.conf          # → ~/.tmux.conf
├── alacritty/              # → ~/.config/alacritty/ (Unix) | %APPDATA%/alacritty/ (Windows)
│   └── alacritty.yml       # Terminal emulator configuration
├── starship/               # → Individual files mapped via dotfiles_file_mappings
│   └── starship.toml       # → ~/.config/starship.toml
├── i3/                     # → ~/.config/i3/ (Linux X11 only)
│   └── config              # i3 window manager configuration
├── hyprland/               # → ~/.config/hypr/ (Linux Wayland only)
├── sway/                   # → ~/.config/sway/ (Linux Wayland only)
└── [application]/          # → Platform-specific paths via mappings
```

## 🔧 Setting Up Your Dotfiles

### 1. **Backup Existing Configurations**

Before setting up new dotfiles, backup your existing configurations:

```bash
# Use the management script
./scripts/manage-dotfiles.sh backup

# Or manually backup specific files
mkdir -p ~/.dotsible_backup_$(date +%Y%m%d)
cp -r ~/.config/nvim ~/.dotsible_backup_$(date +%Y%m%d)/
cp ~/.gitconfig ~/.dotsible_backup_$(date +%Y%m%d)/
cp ~/.zshrc ~/.dotsible_backup_$(date +%Y%m%d)/
```

### 2. **Validate Dotfiles Structure**

Check that your dotfiles are properly organized:

```bash
# Validate structure
./scripts/manage-dotfiles.sh validate

# Check deployment mapping
./scripts/manage-dotfiles.sh mapping
```

### 3. **Test Before Deployment**

Always test your dotfiles before deploying:

```bash
# Test conditional deployment logic
./scripts/manage-dotfiles.sh test

# Dry run deployment
./scripts/manage-dotfiles.sh dry-run developer

# Test specific scenarios
./test-conditional-dotfiles.sh
```

## 🚀 Deployment Commands

### Basic Deployment

```bash
# Deploy with automatic detection
./run-dotsible.sh --tags dotfiles

# Deploy with specific profile
./run-dotsible.sh --profile developer --tags dotfiles

# Enterprise environment with restrictions
./run-dotsible.sh --profile enterprise --environment enterprise --tags dotfiles

# Dry run to see what would be deployed
./run-dotsible.sh --tags dotfiles --check
```

### Using the Management Script

```bash
# Deploy with developer profile
./scripts/manage-dotfiles.sh deploy developer

# Test deployment without changes
./scripts/manage-dotfiles.sh dry-run minimal

# Full workflow
./scripts/manage-dotfiles.sh backup
./scripts/manage-dotfiles.sh validate
./scripts/manage-dotfiles.sh test
./scripts/manage-dotfiles.sh deploy developer
```

## 📋 Platform-Specific Deployment

### 🍎 macOS Example

**Detected Environment**: macOS + Developer Profile + Personal Environment

```bash
./run-dotsible.sh --profile developer --tags dotfiles
```

**Deployed Applications**:
- ✅ Universal: git, neovim, tmux, zsh, starship, alacritty
- ✅ macOS-specific: hammerspoon, karabiner, rectangle, iterm2
- ❌ Excluded: i3, polybar, rofi (Linux window managers)

**File Mappings**:
- `files/dotfiles/nvim/` → `~/.config/nvim/`
- `files/dotfiles/git/.gitconfig` → `~/.gitconfig`
- `files/dotfiles/zsh/.zshrc` → `~/.zshrc`
- `files/dotfiles/tmux/.tmux.conf` → `~/.tmux.conf`

### 🐧 Linux with i3 Example

**Detected Environment**: Arch Linux + i3 + X11 + Developer Profile

```bash
./run-dotsible.sh --profile developer --tags dotfiles
# Auto-detects: detected_window_manager=i3, detected_display_server=x11
```

**Deployed Applications**:
- ✅ Universal: git, neovim, tmux, zsh, starship, alacritty
- ✅ Linux-specific: i3, polybar, rofi, picom, dunst
- ✅ X11-compatible: All X11-based applications
- ❌ Excluded: hyprland, waybar, wofi (Wayland-only)

**Additional Mappings**:
- `files/dotfiles/i3/` → `~/.config/i3/`
- `files/dotfiles/polybar/` → `~/.config/polybar/`

### 🪟 Windows Example

**Detected Environment**: Windows + Enterprise Profile + Enterprise Environment

```bash
./run-dotsible.sh --profile enterprise --environment enterprise --tags dotfiles
```

**Deployed Applications**:
- ✅ Universal: git, neovim (Windows paths)
- ✅ Windows-specific: powershell, windows-terminal
- ✅ Enterprise-hardened: Compliance mode enabled
- ❌ Excluded: All Linux/macOS window managers

**Windows-Specific Mappings**:
- `files/dotfiles/nvim/` → `%LOCALAPPDATA%/nvim/`
- `files/dotfiles/git/.gitconfig` → `%USERPROFILE%/.gitconfig`
- `files/dotfiles/alacritty/` → `%APPDATA%/alacritty/`

## 🔧 Understanding the Deployment Mapping

### Directory Mappings

Applications with complex configurations use directory-level mappings:

```yaml
# From roles/dotfiles/vars/darwin.yml
dotfiles_directory_mappings:
  "nvim": "/Users/{{ ansible_user }}/.config/nvim"
  "i3": "/Users/{{ ansible_user }}/.config/i3"
  "hyprland": "/Users/{{ ansible_user }}/.config/hypr"
  "alacritty": "/Users/{{ ansible_user }}/.config/alacritty"
```

### File Mappings

Single configuration files use file-level mappings:

```yaml
# From roles/dotfiles/vars/darwin.yml
dotfiles_file_mappings:
  "zsh/.zshrc": "{{ dotfiles_os_paths.zshrc }}"
  "git/.gitconfig": "/Users/{{ ansible_user }}/.gitconfig"
  "tmux/.tmux.conf": "/Users/{{ ansible_user }}/.tmux.conf"
  "starship/starship.toml": "/Users/{{ ansible_user }}/.config/starship.toml"
```

### Bidirectional Editing

The system supports bidirectional editing through symlinks (Unix/macOS) or copy strategies (Windows):

- **Unix/macOS**: Directory-level symlinks (`~/.config/nvim` → `~/dotsible/files/dotfiles/nvim`)
- **Windows**: Copy with backup strategy due to symlink limitations
- **Result**: Edit configs in either location, changes reflect in both

## 🧪 Testing and Validation

### Comprehensive Testing

```bash
# Test all scenarios
./test-conditional-dotfiles.sh

# Test specific conditional logic
ansible-playbook test-conditional-only.yml --check

# Validate with different profiles
./run-dotsible.sh --profile minimal --tags dotfiles --check
./run-dotsible.sh --profile developer --tags dotfiles --check
./run-dotsible.sh --profile enterprise --tags dotfiles --check
```

### Manual Validation

```bash
# Check if files are properly linked/copied
ls -la ~/.config/nvim
ls -la ~/.gitconfig
ls -la ~/.zshrc

# Verify symlinks (Unix/macOS)
readlink ~/.config/nvim
readlink ~/.gitconfig

# Test application functionality
nvim --version
git --version
zsh --version
```

## 🔄 Backup and Restore Workflow

### Creating Backups

```bash
# Automated backup
./scripts/manage-dotfiles.sh backup

# Manual backup with timestamp
BACKUP_DIR="$HOME/.dotsible_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r ~/.config/nvim "$BACKUP_DIR/"
cp ~/.gitconfig "$BACKUP_DIR/"
cp ~/.zshrc "$BACKUP_DIR/"
```

### Restoring from Backup

```bash
# Find your backup
ls -la ~/.dotsible_backup_*

# Restore specific files
BACKUP_DIR="$HOME/.dotsible_backup_20241201_120000"
cp -r "$BACKUP_DIR/.config/nvim" ~/.config/
cp "$BACKUP_DIR/.gitconfig" ~/
cp "$BACKUP_DIR/.zshrc" ~/

# Remove dotsible symlinks first (if needed)
rm ~/.config/nvim  # Remove symlink
cp -r "$BACKUP_DIR/.config/nvim" ~/.config/  # Restore original
```

## 🎛️ Customization and Extension

### Adding New Applications

1. **Create application directory**:
   ```bash
   mkdir -p files/dotfiles/myapp
   ```

2. **Add configuration files**:
   ```bash
   # For directory-based configs
   files/dotfiles/myapp/config.yml
   files/dotfiles/myapp/themes/
   
   # For single file configs
   files/dotfiles/myapp/.myapprc
   ```

3. **Update platform mappings** in `roles/dotfiles/vars/[platform].yml`:
   ```yaml
   dotfiles_directory_mappings:
     "myapp": "{{ ansible_user_dir }}/.config/myapp"
   
   # OR for single files
   dotfiles_file_mappings:
     "myapp/.myapprc": "{{ ansible_user_dir }}/.myapprc"
   ```

4. **Add to conditional deployment** in `roles/dotfiles/vars/conditional_deployment.yml`:
   ```yaml
   dotfiles_application_compatibility:
     universal:
       - myapp
   ```

### Profile-Specific Configurations

Applications can have profile-specific behavior through environment variables and conditional logic in their configuration files.

## 🚨 Troubleshooting

### Common Issues

1. **Symlink conflicts**:
   ```bash
   # Remove existing file/directory
   rm ~/.config/nvim
   # Re-run deployment
   ./run-dotsible.sh --tags dotfiles
   ```

2. **Permission issues**:
   ```bash
   # Fix ownership
   sudo chown -R $USER:$USER ~/.config/nvim
   # Fix permissions
   chmod -R 755 ~/.config/nvim
   ```

3. **Missing dependencies**:
   ```bash
   # Install required applications first
   ./run-dotsible.sh --tags applications
   # Then deploy dotfiles
   ./run-dotsible.sh --tags dotfiles
   ```

### Debug Mode

```bash
# Verbose output
./run-dotsible.sh --tags dotfiles -vvv

# Check specific application deployment
ansible-playbook site.yml --tags dotfiles -e "app_name=nvim" --check
```

This guide provides everything you need to effectively manage dotfiles within the dotsible conditional deployment system. The system automatically handles platform differences, profile requirements, and environment restrictions while maintaining the flexibility to customize and extend as needed.
