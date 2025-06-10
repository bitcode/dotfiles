# Arch Linux Package Management with Ansible

This guide covers comprehensive package management for Arch Linux using Ansible, including official packages, AUR packages, custom repositories, and source compilation.

## Table of Contents

1. [Package Management Scope](#package-management-scope)
2. [Source Compilation](#source-compilation)
3. [Version Management](#version-management)
4. [Best Practices](#best-practices)
5. [Examples](#examples)
6. [Troubleshooting](#troubleshooting)

## Package Management Scope

### 1. Official Pacman Packages

Ansible handles official Arch Linux packages through the `pacman` module:

```yaml
- name: Install official packages
  pacman:
    name:
      - git
      - vim
      - htop
    state: present
    update_cache: yes
```

**Capabilities:**
- ✅ Full pacman functionality
- ✅ Repository management (core, extra, community, multilib)
- ✅ Custom repositories
- ✅ Package verification
- ✅ Cache management

### 2. AUR Packages

AUR (Arch User Repository) packages are supported through AUR helpers:

```yaml
- name: Install AUR packages
  command: "yay -S --noconfirm {{ item }}"
  loop:
    - visual-studio-code-bin
    - spotify
    - discord
  become: no  # Important: AUR packages should not be installed as root
```

**Capabilities:**
- ✅ Automatic AUR helper installation (yay, paru)
- ✅ AUR package installation and updates
- ✅ Custom PKGBUILD modifications
- ✅ Build dependency management

### 3. Custom Repositories

Add third-party repositories to pacman:

```yaml
- name: Add custom repository
  blockinfile:
    path: /etc/pacman.conf
    block: |
      [chaotic-aur]
      Include = /etc/pacman.d/chaotic-mirrorlist
    marker: "# {mark} ANSIBLE MANAGED BLOCK - chaotic-aur"
```

### 4. Manual Installations

For packages not available through standard channels:

```yaml
- name: Download and install manual package
  get_url:
    url: "https://example.com/package.pkg.tar.xz"
    dest: "/tmp/package.pkg.tar.xz"
  
- name: Install manual package
  command: "pacman -U --noconfirm /tmp/package.pkg.tar.xz"
```

## Source Compilation

### Supported Build Systems

1. **Autotools/Autoconf**
2. **CMake**
3. **Cargo (Rust)**
4. **Custom build scripts**

### Configuration Example

```yaml
archlinux_source_packages:
  - name: "neovim"
    repo: "https://github.com/neovim/neovim.git"
    track_latest: true
    build_system: "cmake"
    cmake_args: "-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local"
    binary_name: "nvim"
    version_command: "nvim --version"
    build_deps:
      - cmake
      - unzip
      - ninja
      - tree-sitter
      - curl
```

### Build Process

1. **Dependency Installation**: Automatically installs build dependencies
2. **Source Download**: Clones Git repositories or downloads archives
3. **Version Detection**: Tracks latest tags or commits
4. **Configuration**: Runs configure scripts or CMake
5. **Compilation**: Builds with appropriate tools
6. **Installation**: Installs to specified prefix
7. **Verification**: Checks installation success

## Version Management

### Latest Version Tracking

For software without semantic versioning:

```yaml
- name: "custom-tool"
  repo: "https://github.com/user/tool.git"
  track_latest: true  # Always use latest commit/tag
  version: "latest"   # Or specify branch/tag
```

### Version Detection Strategies

1. **Git Tags**: `git describe --tags --abbrev=0`
2. **Git Commits**: `git rev-parse --short HEAD`
3. **Custom Commands**: User-defined version detection
4. **Manual Specification**: Fixed versions

### Update Management

```bash
# Update all source packages
ansible-playbook site.yml --tags "source,update"

# Update specific packages
ansible-playbook site.yml -e "packages_to_update=['neovim','tmux']"

# Force rebuild all
ansible-playbook site.yml -e "force_update=true"
```

### Version Tracking File

Ansible maintains a version tracking file at `~/.ansible_source_versions.yml`:

```yaml
neovim:
  version: latest
  last_updated: 2024-01-15T10:30:00Z
  source: https://github.com/neovim/neovim.git
  build_system: cmake
  binary_path: /usr/local/bin/nvim
  tracking: latest
```

## Best Practices

### 1. Package Organization

```yaml
# Organize by purpose
archlinux_packages:
  essential:
    - base-devel
    - git
    - curl
  
  development:
    - python
    - nodejs
    - rust
  
  gui:
    - firefox
    - alacritty
    - code
```

### 2. AUR Package Management

```yaml
# Separate AUR packages by category
archlinux_aur_packages:
  development:
    - visual-studio-code-bin
    - postman-bin
  
  media:
    - spotify
    - discord
```

### 3. Source Compilation Strategy

- Use source compilation for:
  - Latest features not in packages
  - Custom build configurations
  - Performance optimizations
  - Development versions

- Prefer packages for:
  - Stable, well-maintained software
  - Complex dependencies
  - System-critical components

### 4. Cross-Platform Compatibility

```yaml
# Maintain compatibility with Ubuntu
- name: Install development tools
  package:
    name: "{{ dev_packages[ansible_os_family] }}"
    state: present

vars:
  dev_packages:
    Archlinux:
      - base-devel
      - python
    Debian:
      - build-essential
      - python3
```

## Examples

### Complete Developer Setup

```bash
# Run comprehensive Arch Linux setup
ansible-playbook -i inventories/local/hosts.yml examples/archlinux-comprehensive-setup.yml

# Install only development packages
ansible-playbook site.yml --tags "packages" -e "package_categories=['development']"

# Install AUR packages for development
ansible-playbook site.yml --tags "aur" -e "aur_categories=['development']"

# Compile specific tools from source
ansible-playbook site.yml --tags "source" -e "source_packages=['neovim','tmux']"
```

### Custom Package Lists

```yaml
# In group_vars/all/custom.yml
custom_packages:
  official:
    - neofetch
    - bat
    - exa
  
  aur:
    - brave-bin
    - zoom
  
  source:
    - name: "starship"
      repo: "https://github.com/starship/starship.git"
      build_system: "cargo"
```

### Maintenance Tasks

```bash
# Update system and AUR packages
ansible-playbook maintenance.yml --tags "update"

# Check for source package updates
ansible-playbook maintenance.yml --tags "source,check"

# Clean package caches
ansible-playbook maintenance.yml --tags "cleanup"
```

## Integration with Existing Setup

Your current dotfiles configuration already includes:

1. **Display Server Support**: X11 and Wayland packages
2. **Profile-based Installation**: Developer, server, gaming profiles
3. **Service Management**: Systemd service configuration
4. **Cross-platform Compatibility**: Ubuntu and macOS support

The new Arch Linux package management extends this with:

1. **Enhanced AUR Support**: Comprehensive AUR package management
2. **Source Compilation**: Automated building from source
3. **Version Tracking**: Intelligent update management
4. **Custom Repositories**: Third-party repository support

## Troubleshooting

### Common Issues

1. **AUR Build Failures**
   ```bash
   # Check build logs
   journalctl -u ansible-aur-build
   
   # Manual build for debugging
   cd /tmp/ansible_source_builds/package_name
   makepkg -si
   ```

2. **Source Compilation Errors**
   ```bash
   # Check dependencies
   ansible-playbook site.yml --tags "source,deps" --check
   
   # Verify build environment
   pacman -Q base-devel cmake make gcc
   ```

3. **Version Conflicts**
   ```bash
   # Check installed versions
   cat ~/.ansible_source_versions.yml
   
   # Force reinstall
   ansible-playbook site.yml -e "force_update=true"
   ```

### Performance Optimization

1. **Parallel Builds**: Configure `makepkg.conf` for multi-core builds
2. **Cache Management**: Regular cleanup of build directories
3. **Incremental Updates**: Only rebuild when necessary

This comprehensive package management system provides full control over your Arch Linux environment while maintaining compatibility with your existing Ubuntu and macOS configurations.
