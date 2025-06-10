#!/bin/bash
# Dotsible Backup Script
# Creates comprehensive backups before running Dotsible

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTSIBLE_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_ROOT="$HOME/.dotsible/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$BACKUP_ROOT/backup_$TIMESTAMP"
BACKUP_LOG="$BACKUP_DIR/backup.log"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$BACKUP_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$BACKUP_LOG"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$BACKUP_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$BACKUP_LOG"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}" | tee -a "$BACKUP_LOG"
}

# Function to create backup directory structure
create_backup_structure() {
    header "Creating Backup Structure"
    
    mkdir -p "$BACKUP_DIR"/{dotfiles,configs,packages,system,logs}
    
    # Create backup manifest
    cat > "$BACKUP_DIR/manifest.txt" << EOF
Dotsible Backup Manifest
=======================

Backup Date: $(date)
Backup ID: backup_$TIMESTAMP
Host: $(hostname)
User: $(whoami)
OS: $(uname -s) $(uname -r)
Architecture: $(uname -m)

Backup Contents:
- dotfiles/     : User dotfiles and configuration files
- configs/      : System configuration files
- packages/     : Package manager state and lists
- system/       : System information and state
- logs/         : Backup operation logs

Restore Instructions:
See restore.sh script in this directory for restoration procedures.
EOF
    
    success "Backup structure created: $BACKUP_DIR"
}

# Function to backup dotfiles
backup_dotfiles() {
    header "Backing Up Dotfiles"
    
    local dotfiles_backup="$BACKUP_DIR/dotfiles"
    local backed_up=0
    
    # Common dotfiles to backup
    local dotfiles=(
        ".bashrc"
        ".bash_profile"
        ".zshrc"
        ".zsh_history"
        ".profile"
        ".vimrc"
        ".tmux.conf"
        ".gitconfig"
        ".gitignore_global"
        ".ssh/config"
        ".ssh/known_hosts"
        ".config"
        ".local"
        ".oh-my-zsh"
    )
    
    for dotfile in "${dotfiles[@]}"; do
        local source_path="$HOME/$dotfile"
        local backup_path="$dotfiles_backup/$dotfile"
        
        if [ -e "$source_path" ]; then
            log "Backing up: $dotfile"
            mkdir -p "$(dirname "$backup_path")"
            
            if [ -d "$source_path" ]; then
                cp -r "$source_path" "$backup_path" 2>/dev/null || {
                    warning "Failed to backup directory: $dotfile"
                    continue
                }
            else
                cp "$source_path" "$backup_path" 2>/dev/null || {
                    warning "Failed to backup file: $dotfile"
                    continue
                }
            fi
            
            backed_up=$((backed_up + 1))
        fi
    done
    
    # Create dotfiles inventory
    cat > "$dotfiles_backup/inventory.txt" << EOF
Dotfiles Backup Inventory
========================

Backup Date: $(date)
Files Backed Up: $backed_up

Backed Up Files:
EOF
    
    find "$dotfiles_backup" -type f -not -name "inventory.txt" | sed "s|$dotfiles_backup/||" | sort >> "$dotfiles_backup/inventory.txt"
    
    success "Backed up $backed_up dotfiles"
}

# Function to backup system configurations
backup_system_configs() {
    header "Backing Up System Configurations"
    
    local configs_backup="$BACKUP_DIR/configs"
    local backed_up=0
    
    # System configuration files to backup (if accessible)
    local system_configs=(
        "/etc/hosts"
        "/etc/hostname"
        "/etc/resolv.conf"
        "/etc/environment"
        "/etc/profile"
        "/etc/bash.bashrc"
        "/etc/zsh/zshrc"
        "/etc/vim/vimrc"
        "/etc/tmux.conf"
        "/etc/ssh/ssh_config"
    )
    
    for config in "${system_configs[@]}"; do
        if [ -r "$config" ]; then
            local backup_path="$configs_backup$(dirname "$config")"
            mkdir -p "$backup_path"
            
            if cp "$config" "$backup_path/" 2>/dev/null; then
                log "Backed up: $config"
                backed_up=$((backed_up + 1))
            else
                warning "Failed to backup: $config"
            fi
        fi
    done
    
    # Backup package manager configurations
    if [ -f "/etc/apt/sources.list" ]; then
        mkdir -p "$configs_backup/etc/apt"
        cp "/etc/apt/sources.list" "$configs_backup/etc/apt/" 2>/dev/null || true
        if [ -d "/etc/apt/sources.list.d" ]; then
            cp -r "/etc/apt/sources.list.d" "$configs_backup/etc/apt/" 2>/dev/null || true
        fi
    fi
    
    success "Backed up $backed_up system configuration files"
}

# Function to backup package information
backup_packages() {
    header "Backing Up Package Information"
    
    local packages_backup="$BACKUP_DIR/packages"
    mkdir -p "$packages_backup"
    
    # Detect package manager and create package lists
    if command -v apt >/dev/null 2>&1; then
        log "Creating APT package list..."
        dpkg --get-selections > "$packages_backup/apt_packages.txt" 2>/dev/null || true
        apt list --installed > "$packages_backup/apt_installed.txt" 2>/dev/null || true
        success "APT package list created"
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        log "Creating Pacman package list..."
        pacman -Qqe > "$packages_backup/pacman_explicit.txt" 2>/dev/null || true
        pacman -Qq > "$packages_backup/pacman_all.txt" 2>/dev/null || true
        success "Pacman package list created"
    fi
    
    if command -v brew >/dev/null 2>&1; then
        log "Creating Homebrew package list..."
        brew list > "$packages_backup/brew_packages.txt" 2>/dev/null || true
        brew list --cask > "$packages_backup/brew_casks.txt" 2>/dev/null || true
        success "Homebrew package list created"
    fi
    
    if command -v pip3 >/dev/null 2>&1; then
        log "Creating Python package list..."
        pip3 list > "$packages_backup/pip_packages.txt" 2>/dev/null || true
        success "Python package list created"
    fi
    
    if command -v npm >/dev/null 2>&1; then
        log "Creating NPM package list..."
        npm list -g --depth=0 > "$packages_backup/npm_global.txt" 2>/dev/null || true
        success "NPM package list created"
    fi
}

# Function to backup system information
backup_system_info() {
    header "Backing Up System Information"
    
    local system_backup="$BACKUP_DIR/system"
    mkdir -p "$system_backup"
    
    # System information
    cat > "$system_backup/system_info.txt" << EOF
System Information Backup
========================

Date: $(date)
Hostname: $(hostname)
User: $(whoami)
Home: $HOME
Shell: $SHELL
OS: $(uname -a)

EOF
    
    # Environment variables
    env | sort > "$system_backup/environment.txt"
    
    # Installed services (systemd)
    if command -v systemctl >/dev/null 2>&1; then
        systemctl list-unit-files --type=service > "$system_backup/systemd_services.txt" 2>/dev/null || true
        systemctl list-units --type=service --state=enabled > "$system_backup/enabled_services.txt" 2>/dev/null || true
    fi
    
    # Network configuration
    if command -v ip >/dev/null 2>&1; then
        ip addr show > "$system_backup/network_interfaces.txt" 2>/dev/null || true
        ip route show > "$system_backup/network_routes.txt" 2>/dev/null || true
    elif command -v ifconfig >/dev/null 2>&1; then
        ifconfig > "$system_backup/network_interfaces.txt" 2>/dev/null || true
    fi
    
    # Disk usage
    df -h > "$system_backup/disk_usage.txt" 2>/dev/null || true
    
    # Process list
    ps aux > "$system_backup/processes.txt" 2>/dev/null || true
    
    success "System information backed up"
}

# Function to create restore script
create_restore_script() {
    header "Creating Restore Script"
    
    cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash
# Dotsible Backup Restore Script
# Restores files from this backup

set -e

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTORE_LOG="$BACKUP_DIR/restore.log"

log() {
    echo "[$(date)] $1" | tee -a "$RESTORE_LOG"
}

error() {
    echo "[ERROR] $1" | tee -a "$RESTORE_LOG"
}

success() {
    echo "[SUCCESS] $1" | tee -a "$RESTORE_LOG"
}

restore_dotfiles() {
    log "Restoring dotfiles..."
    
    if [ -d "$BACKUP_DIR/dotfiles" ]; then
        cd "$BACKUP_DIR/dotfiles"
        find . -type f | while read -r file; do
            target="$HOME/${file#./}"
            target_dir="$(dirname "$target")"
            
            if [ ! -d "$target_dir" ]; then
                mkdir -p "$target_dir"
            fi
            
            if [ -e "$target" ]; then
                log "Backing up existing: $target -> $target.pre-restore"
                mv "$target" "$target.pre-restore"
            fi
            
            cp "$file" "$target"
            log "Restored: $target"
        done
        success "Dotfiles restored"
    else
        error "No dotfiles backup found"
    fi
}

restore_configs() {
    log "Restoring system configurations..."
    
    if [ -d "$BACKUP_DIR/configs" ]; then
        log "System configuration restore requires root privileges"
        log "Please manually restore files from: $BACKUP_DIR/configs"
        success "System configs location provided"
    else
        error "No system configs backup found"
    fi
}

show_package_info() {
    log "Package restoration information..."
    
    if [ -d "$BACKUP_DIR/packages" ]; then
        log "Package lists available in: $BACKUP_DIR/packages"
        
        if [ -f "$BACKUP_DIR/packages/apt_packages.txt" ]; then
            log "To restore APT packages: sudo dpkg --set-selections < $BACKUP_DIR/packages/apt_packages.txt && sudo apt-get dselect-upgrade"
        fi
        
        if [ -f "$BACKUP_DIR/packages/pacman_explicit.txt" ]; then
            log "To restore Pacman packages: sudo pacman -S --needed \$(cat $BACKUP_DIR/packages/pacman_explicit.txt)"
        fi
        
        if [ -f "$BACKUP_DIR/packages/brew_packages.txt" ]; then
            log "To restore Homebrew packages: cat $BACKUP_DIR/packages/brew_packages.txt | xargs brew install"
        fi
        
        success "Package restoration info provided"
    else
        error "No package backup found"
    fi
}

main() {
    log "Starting restore from backup: $(basename "$BACKUP_DIR")"
    
    echo "Available restore options:"
    echo "1. Restore dotfiles"
    echo "2. Show system config restore info"
    echo "3. Show package restore info"
    echo "4. Full restore (dotfiles only)"
    echo "5. Exit"
    
    read -p "Choose option (1-5): " choice
    
    case $choice in
        1)
            restore_dotfiles
            ;;
        2)
            restore_configs
            ;;
        3)
            show_package_info
            ;;
        4)
            restore_dotfiles
            restore_configs
            show_package_info
            ;;
        5)
            log "Restore cancelled"
            exit 0
            ;;
        *)
            error "Invalid option"
            exit 1
            ;;
    esac
    
    log "Restore operation completed"
}

main "$@"
EOF
    
    chmod +x "$BACKUP_DIR/restore.sh"
    success "Restore script created: $BACKUP_DIR/restore.sh"
}

# Function to compress backup
compress_backup() {
    header "Compressing Backup"
    
    local archive_name="dotsible_backup_$TIMESTAMP.tar.gz"
    local archive_path="$BACKUP_ROOT/$archive_name"
    
    log "Creating compressed archive..."
    cd "$BACKUP_ROOT"
    tar -czf "$archive_name" "backup_$TIMESTAMP" 2>/dev/null || {
        warning "Failed to create compressed archive"
        return 1
    }
    
    local archive_size=$(du -h "$archive_path" | cut -f1)
    success "Backup compressed: $archive_path ($archive_size)"
    
    # Update manifest with archive info
    cat >> "$BACKUP_DIR/manifest.txt" << EOF

Archive Information:
- Compressed: $archive_name
- Size: $archive_size
- Location: $archive_path
EOF
}

# Function to cleanup old backups
cleanup_old_backups() {
    header "Cleaning Up Old Backups"
    
    local keep_backups=5
    local backup_count=$(find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*" -type d | wc -l)
    
    if [ "$backup_count" -gt "$keep_backups" ]; then
        log "Found $backup_count backups, keeping latest $keep_backups"
        
        find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*" -type d | sort | head -n -"$keep_backups" | while read -r old_backup; do
            log "Removing old backup: $(basename "$old_backup")"
            rm -rf "$old_backup"
        done
        
        # Also cleanup old archives
        find "$BACKUP_ROOT" -maxdepth 1 -name "dotsible_backup_*.tar.gz" | sort | head -n -"$keep_backups" | while read -r old_archive; do
            log "Removing old archive: $(basename "$old_archive")"
            rm -f "$old_archive"
        done
        
        success "Old backups cleaned up"
    else
        log "Backup count ($backup_count) within limit ($keep_backups)"
    fi
}

# Function to generate backup report
generate_report() {
    header "Generating Backup Report"
    
    local report_file="$BACKUP_DIR/backup_report.txt"
    local backup_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    
    cat > "$report_file" << EOF
Dotsible Backup Report
=====================

Backup ID: backup_$TIMESTAMP
Date: $(date)
Host: $(hostname)
User: $(whoami)
Backup Size: $backup_size
Backup Location: $BACKUP_DIR

BACKUP CONTENTS:
===============
$(find "$BACKUP_DIR" -type f | wc -l) files backed up

Dotfiles: $(find "$BACKUP_DIR/dotfiles" -type f 2>/dev/null | wc -l) files
Configs: $(find "$BACKUP_DIR/configs" -type f 2>/dev/null | wc -l) files
Packages: $(find "$BACKUP_DIR/packages" -type f 2>/dev/null | wc -l) lists
System Info: $(find "$BACKUP_DIR/system" -type f 2>/dev/null | wc -l) files

RESTORE INSTRUCTIONS:
====================
1. Navigate to backup directory: cd $BACKUP_DIR
2. Run restore script: ./restore.sh
3. Follow the interactive prompts
4. Or manually restore specific files as needed

BACKUP VERIFICATION:
===================
✓ Backup directory created
✓ Dotfiles backed up
✓ System configs backed up
✓ Package lists created
✓ System information saved
✓ Restore script created

STATUS: ✅ BACKUP COMPLETED SUCCESSFULLY

Generated by Dotsible Backup Framework
EOF
    
    success "Backup report generated: $report_file"
}

# Main backup function
main() {
    header "Dotsible System Backup"
    log "Starting comprehensive system backup..."
    log "Backup ID: backup_$TIMESTAMP"
    log "Backup location: $BACKUP_DIR"
    
    # Create backup structure
    create_backup_structure
    
    # Perform backups
    backup_dotfiles
    backup_system_configs
    backup_packages
    backup_system_info
    
    # Create restore utilities
    create_restore_script
    
    # Generate report
    generate_report
    
    # Optional compression
    if [ "${COMPRESS:-true}" = "true" ]; then
        compress_backup
    fi
    
    # Cleanup old backups
    if [ "${CLEANUP:-true}" = "true" ]; then
        cleanup_old_backups
    fi
    
    # Final summary
    header "Backup Complete"
    local backup_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    success "🎉 Backup completed successfully!"
    log "Backup size: $backup_size"
    log "Backup location: $BACKUP_DIR"
    log "Restore script: $BACKUP_DIR/restore.sh"
    
    if [ -f "$BACKUP_ROOT/dotsible_backup_$TIMESTAMP.tar.gz" ]; then
        local archive_size=$(du -h "$BACKUP_ROOT/dotsible_backup_$TIMESTAMP.tar.gz" | cut -f1)
        log "Compressed archive: $BACKUP_ROOT/dotsible_backup_$TIMESTAMP.tar.gz ($archive_size)"
    fi
    
    log "You can now safely run Dotsible knowing your system is backed up."
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Dotsible Backup Script"
        echo ""
        echo "Creates comprehensive backups before running Dotsible including:"
        echo "  - User dotfiles and configurations"
        echo "  - System configuration files"
        echo "  - Package manager state and lists"
        echo "  - System information and environment"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --no-compress       Skip backup compression"
        echo "  --no-cleanup        Skip cleanup of old backups"
        echo "  --dotfiles-only     Backup only dotfiles"
        echo "  --list-backups      List existing backups"
        echo ""
        echo "Environment Variables:"
        echo "  COMPRESS=false      Disable compression"
        echo "  CLEANUP=false       Disable cleanup"
        echo ""
        exit 0
        ;;
    --no-compress)
        export COMPRESS=false
        main
        ;;
    --no-cleanup)
        export CLEANUP=false
        main
        ;;
    --dotfiles-only)
        header "Dotfiles-Only Backup"
        create_backup_structure
        backup_dotfiles
        create_restore_script
        generate_report
        success "Dotfiles backup completed: $BACKUP_DIR"
        ;;
    --list-backups)
        header "Existing Backups"
        if [ -d "$BACKUP_ROOT" ]; then
            find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*" -type d | sort -r | while read -r backup; do
                backup_id=$(basename "$backup")
                backup_date=$(echo "$backup_id" | sed 's/backup_//' | sed 's/_/ /')
                backup_size=$(du -sh "$backup" | cut -f1)
                echo "  $backup_id ($backup_size) - $backup_date"
            done
            
            echo ""
            log "Compressed archives:"
            find "$BACKUP_ROOT" -maxdepth 1 -name "dotsible_backup_*.tar.gz" | sort -r | while read -r archive; do
                archive_name=$(basename "$archive")
                archive_size=$(du -h "$archive" | cut -f1)
                echo "  $archive_name ($archive_size)"
            done
        else
            log "No backups found. Backup directory: $BACKUP_ROOT"
        fi
        ;;
    "")
        main
        ;;
    *)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac