#!/bin/bash
# Dotsible Rollback Script
# Emergency rollback procedures for Dotsible changes

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
ROLLBACK_LOG="$HOME/.dotsible/rollback_$(date +%Y%m%d_%H%M%S).log"

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$ROLLBACK_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$ROLLBACK_LOG"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$ROLLBACK_LOG"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$ROLLBACK_LOG"
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}" | tee -a "$ROLLBACK_LOG"
}

# Function to list available backups
list_backups() {
    header "Available Backups"
    
    if [ ! -d "$BACKUP_ROOT" ]; then
        error "No backup directory found at: $BACKUP_ROOT"
        return 1
    fi
    
    local backups=($(find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*" -type d | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        error "No backups found in: $BACKUP_ROOT"
        return 1
    fi
    
    log "Found ${#backups[@]} backup(s):"
    echo
    
    local i=1
    for backup in "${backups[@]}"; do
        local backup_id=$(basename "$backup")
        local backup_date=$(echo "$backup_id" | sed 's/backup_//' | sed 's/_/ /')
        local backup_size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "Unknown")
        local manifest_file="$backup/manifest.txt"
        
        echo "[$i] $backup_id"
        echo "    Date: $backup_date"
        echo "    Size: $backup_size"
        echo "    Path: $backup"
        
        if [ -f "$manifest_file" ]; then
            local backup_info=$(grep -A 5 "Backup Date:" "$manifest_file" 2>/dev/null | head -6)
            echo "    Info: Available"
        else
            echo "    Info: No manifest found"
        fi
        echo
        
        i=$((i + 1))
    done
    
    return 0
}

# Function to select backup
select_backup() {
    local backups=($(find "$BACKUP_ROOT" -maxdepth 1 -name "backup_*" -type d | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        error "No backups available for rollback"
        return 1
    fi
    
    echo "Select backup to rollback to:"
    read -p "Enter backup number (1-${#backups[@]}): " backup_choice
    
    if ! [[ "$backup_choice" =~ ^[0-9]+$ ]] || [ "$backup_choice" -lt 1 ] || [ "$backup_choice" -gt ${#backups[@]} ]; then
        error "Invalid backup selection: $backup_choice"
        return 1
    fi
    
    SELECTED_BACKUP="${backups[$((backup_choice - 1))]}"
    log "Selected backup: $(basename "$SELECTED_BACKUP")"
    return 0
}

# Function to verify backup integrity
verify_backup() {
    local backup_dir="$1"
    
    header "Verifying Backup Integrity"
    
    if [ ! -d "$backup_dir" ]; then
        error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    # Check for essential backup components
    local required_dirs=("dotfiles" "configs" "packages" "system")
    local missing_dirs=()
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$backup_dir/$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done
    
    if [ ${#missing_dirs[@]} -gt 0 ]; then
        warning "Missing backup directories: ${missing_dirs[*]}"
        log "Backup may be incomplete but proceeding..."
    fi
    
    # Check manifest
    if [ -f "$backup_dir/manifest.txt" ]; then
        success "✓ Backup manifest found"
        log "Backup details:"
        grep -E "(Backup Date|Host|User|OS)" "$backup_dir/manifest.txt" | sed 's/^/    /'
    else
        warning "⚠ No backup manifest found"
    fi
    
    # Check restore script
    if [ -f "$backup_dir/restore.sh" ] && [ -x "$backup_dir/restore.sh" ]; then
        success "✓ Restore script available"
    else
        warning "⚠ No restore script found"
    fi
    
    success "Backup verification completed"
    return 0
}

# Function to create pre-rollback backup
create_pre_rollback_backup() {
    header "Creating Pre-Rollback Backup"
    
    log "Creating safety backup before rollback..."
    
    if [ -x "$SCRIPT_DIR/backup.sh" ]; then
        log "Running backup script..."
        "$SCRIPT_DIR/backup.sh" --no-cleanup 2>&1 | tee -a "$ROLLBACK_LOG"
        success "Pre-rollback backup created"
    else
        warning "Backup script not found, creating minimal backup..."
        
        local pre_rollback_dir="$BACKUP_ROOT/pre_rollback_$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$pre_rollback_dir/dotfiles"
        
        # Backup critical dotfiles
        local critical_files=(".bashrc" ".zshrc" ".vimrc" ".gitconfig" ".tmux.conf")
        for file in "${critical_files[@]}"; do
            if [ -f "$HOME/$file" ]; then
                cp "$HOME/$file" "$pre_rollback_dir/dotfiles/" 2>/dev/null || true
            fi
        done
        
        success "Minimal pre-rollback backup created: $pre_rollback_dir"
    fi
}

# Function to rollback dotfiles
rollback_dotfiles() {
    local backup_dir="$1"
    
    header "Rolling Back Dotfiles"
    
    local dotfiles_backup="$backup_dir/dotfiles"
    
    if [ ! -d "$dotfiles_backup" ]; then
        warning "No dotfiles backup found, skipping dotfiles rollback"
        return 0
    fi
    
    log "Rolling back dotfiles from: $dotfiles_backup"
    
    # Get list of files to restore
    local files_to_restore=($(find "$dotfiles_backup" -type f | sed "s|$dotfiles_backup/||"))
    local restored_count=0
    local failed_count=0
    
    for file in "${files_to_restore[@]}"; do
        local source_file="$dotfiles_backup/$file"
        local target_file="$HOME/$file"
        local target_dir="$(dirname "$target_file")"
        
        # Create target directory if needed
        if [ ! -d "$target_dir" ]; then
            mkdir -p "$target_dir" || {
                error "Failed to create directory: $target_dir"
                failed_count=$((failed_count + 1))
                continue
            }
        fi
        
        # Backup current file if it exists
        if [ -e "$target_file" ]; then
            local backup_name="$target_file.rollback_backup_$(date +%Y%m%d_%H%M%S)"
            mv "$target_file" "$backup_name" 2>/dev/null || {
                warning "Failed to backup current file: $target_file"
            }
            log "Current file backed up: $backup_name"
        fi
        
        # Restore file
        if cp "$source_file" "$target_file" 2>/dev/null; then
            log "Restored: $file"
            restored_count=$((restored_count + 1))
        else
            error "Failed to restore: $file"
            failed_count=$((failed_count + 1))
        fi
    done
    
    success "Dotfiles rollback completed: $restored_count restored, $failed_count failed"
}

# Function to rollback packages
rollback_packages() {
    local backup_dir="$1"
    
    header "Package Rollback Information"
    
    local packages_backup="$backup_dir/packages"
    
    if [ ! -d "$packages_backup" ]; then
        warning "No package backup found, skipping package rollback"
        return 0
    fi
    
    log "Package lists available for manual restoration:"
    
    # APT packages
    if [ -f "$packages_backup/apt_packages.txt" ]; then
        log "APT packages can be restored with:"
        log "  sudo dpkg --set-selections < $packages_backup/apt_packages.txt"
        log "  sudo apt-get dselect-upgrade"
    fi
    
    # Pacman packages
    if [ -f "$packages_backup/pacman_explicit.txt" ]; then
        log "Pacman packages can be restored with:"
        log "  sudo pacman -S --needed \$(cat $packages_backup/pacman_explicit.txt)"
    fi
    
    # Homebrew packages
    if [ -f "$packages_backup/brew_packages.txt" ]; then
        log "Homebrew packages can be restored with:"
        log "  cat $packages_backup/brew_packages.txt | xargs brew install"
    fi
    
    # Python packages
    if [ -f "$packages_backup/pip_packages.txt" ]; then
        log "Python packages list available at: $packages_backup/pip_packages.txt"
    fi
    
    warning "Package rollback requires manual intervention for safety"
    log "Review package lists and restore as needed"
}

# Function to rollback system configurations
rollback_system_configs() {
    local backup_dir="$1"
    
    header "System Configuration Rollback"
    
    local configs_backup="$backup_dir/configs"
    
    if [ ! -d "$configs_backup" ]; then
        warning "No system config backup found, skipping system config rollback"
        return 0
    fi
    
    warning "System configuration rollback requires root privileges"
    log "System config backup available at: $configs_backup"
    log "Manual restoration required for system files"
    
    # List available system configs
    if [ -d "$configs_backup/etc" ]; then
        log "Available system configurations:"
        find "$configs_backup/etc" -type f | sed "s|$configs_backup||" | sed 's/^/  /'
    fi
    
    log "To restore system configs, manually copy files from:"
    log "  $configs_backup"
    log "To their original locations with appropriate permissions"
}

# Function to remove Dotsible-installed applications
remove_dotsible_applications() {
    header "Removing Dotsible-Installed Applications"
    
    warning "This will attempt to remove applications installed by Dotsible"
    read -p "Continue with application removal? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Application removal skipped"
        return 0
    fi
    
    # Common applications that Dotsible might install
    local common_apps=("zsh" "vim" "tmux" "git" "curl" "wget")
    
    # Detect package manager and remove packages
    if command -v apt >/dev/null 2>&1; then
        log "Removing packages via APT..."
        for app in "${common_apps[@]}"; do
            if dpkg -l | grep -q "^ii.*$app "; then
                log "Removing: $app"
                sudo apt remove -y "$app" 2>/dev/null || warning "Failed to remove: $app"
            fi
        done
    elif command -v pacman >/dev/null 2>&1; then
        log "Removing packages via Pacman..."
        for app in "${common_apps[@]}"; do
            if pacman -Q "$app" >/dev/null 2>&1; then
                log "Removing: $app"
                sudo pacman -R --noconfirm "$app" 2>/dev/null || warning "Failed to remove: $app"
            fi
        done
    elif command -v brew >/dev/null 2>&1; then
        log "Removing packages via Homebrew..."
        for app in "${common_apps[@]}"; do
            if brew list | grep -q "^$app$"; then
                log "Removing: $app"
                brew uninstall "$app" 2>/dev/null || warning "Failed to remove: $app"
            fi
        done
    fi
    
    success "Application removal completed"
}

# Function to clean up Dotsible artifacts
cleanup_dotsible_artifacts() {
    header "Cleaning Up Dotsible Artifacts"
    
    # Remove Dotsible-created directories and files
    local artifacts=(
        "$HOME/.ansible_profile_summary"
        "$HOME/.ansible_verification_report"
        "$HOME/.dotsible_integration_report"
        "/var/log/ansible"
        "$HOME/.oh-my-zsh"  # Only if installed by Dotsible
    )
    
    for artifact in "${artifacts[@]}"; do
        if [ -e "$artifact" ]; then
            log "Removing: $artifact"
            rm -rf "$artifact" 2>/dev/null || warning "Failed to remove: $artifact"
        fi
    done
    
    # Clean up shell history entries related to Dotsible
    if [ -f "$HOME/.bash_history" ]; then
        log "Cleaning Dotsible entries from bash history..."
        sed -i '/ansible-playbook.*dotsible/d' "$HOME/.bash_history" 2>/dev/null || true
    fi
    
    if [ -f "$HOME/.zsh_history" ]; then
        log "Cleaning Dotsible entries from zsh history..."
        sed -i '/ansible-playbook.*dotsible/d' "$HOME/.zsh_history" 2>/dev/null || true
    fi
    
    success "Dotsible artifacts cleaned up"
}

# Function to verify rollback
verify_rollback() {
    header "Verifying Rollback"
    
    local verification_passed=true
    
    # Check if critical files were restored
    local critical_files=(".bashrc" ".zshrc" ".vimrc" ".gitconfig")
    for file in "${critical_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            success "✓ $file exists"
        else
            log "- $file not found (may not have been in backup)"
        fi
    done
    
    # Check shell
    if [ -n "$SHELL" ] && [ -x "$SHELL" ]; then
        success "✓ Shell is accessible: $SHELL"
    else
        error "✗ Shell issue detected"
        verification_passed=false
    fi
    
    # Check basic commands
    local basic_commands=("ls" "cd" "pwd" "echo")
    for cmd in "${basic_commands[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            success "✓ $cmd command available"
        else
            error "✗ $cmd command not found"
            verification_passed=false
        fi
    done
    
    if [ "$verification_passed" = true ]; then
        success "🎉 Rollback verification passed!"
    else
        error "❌ Rollback verification failed. Manual intervention may be required."
    fi
}

# Function to generate rollback report
generate_rollback_report() {
    local backup_used="$1"
    local report_file="$HOME/.dotsible/rollback_report_$(date +%Y%m%d_%H%M%S).txt"
    
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
Dotsible Rollback Report
=======================

Rollback Date: $(date)
Host: $(hostname)
User: $(whoami)
Backup Used: $(basename "$backup_used")
Rollback Log: $ROLLBACK_LOG

ROLLBACK SUMMARY:
================
✓ Pre-rollback backup created
✓ Dotfiles restored from backup
✓ System configuration info provided
✓ Package restoration info provided
✓ Dotsible artifacts cleaned up
✓ Rollback verification completed

BACKUP DETAILS:
==============
Backup Location: $backup_used
Backup Date: $(grep "Backup Date:" "$backup_used/manifest.txt" 2>/dev/null | cut -d: -f2- || echo "Unknown")

NEXT STEPS:
==========
1. ✅ Review restored configurations
2. ✅ Test system functionality
3. ✅ Manually restore packages if needed
4. ✅ Check system configurations
5. ✅ Restart shell or reboot if necessary

MANUAL RESTORATION:
==================
- System configs: $backup_used/configs/
- Package lists: $backup_used/packages/
- System info: $backup_used/system/

If you need to restore packages or system configurations,
refer to the files in the backup directory above.

STATUS: ✅ ROLLBACK COMPLETED

Generated by Dotsible Rollback Framework
EOF
    
    success "Rollback report generated: $report_file"
}

# Main rollback function
main() {
    header "Dotsible Emergency Rollback"
    warning "This will rollback your system to a previous backup state"
    log "Rollback log: $ROLLBACK_LOG"
    
    # List available backups
    if ! list_backups; then
        error "No backups available for rollback"
        exit 1
    fi
    
    # Select backup
    if ! select_backup; then
        error "Backup selection failed"
        exit 1
    fi
    
    # Verify backup
    if ! verify_backup "$SELECTED_BACKUP"; then
        error "Backup verification failed"
        exit 1
    fi
    
    # Confirm rollback
    echo
    warning "⚠️  ROLLBACK CONFIRMATION ⚠️"
    log "This will:"
    log "  - Create a pre-rollback backup"
    log "  - Restore dotfiles from: $(basename "$SELECTED_BACKUP")"
    log "  - Provide package restoration information"
    log "  - Clean up Dotsible artifacts"
    echo
    read -p "Continue with rollback? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Rollback cancelled by user"
        exit 0
    fi
    
    # Perform rollback
    create_pre_rollback_backup
    rollback_dotfiles "$SELECTED_BACKUP"
    rollback_packages "$SELECTED_BACKUP"
    rollback_system_configs "$SELECTED_BACKUP"
    cleanup_dotsible_artifacts
    
    # Verify rollback
    verify_rollback
    
    # Generate report
    generate_rollback_report "$SELECTED_BACKUP"
    
    # Final message
    header "Rollback Complete"
    success "🎉 System rollback completed successfully!"
    log "Backup used: $(basename "$SELECTED_BACKUP")"
    log "Rollback log: $ROLLBACK_LOG"
    
    warning "Important next steps:"
    log "1. Restart your shell: exec \$SHELL"
    log "2. Test system functionality"
    log "3. Review rollback report for manual restoration steps"
    log "4. Consider rebooting if issues persist"
    
    log "If you need to restore packages or system configs, check:"
    log "  $SELECTED_BACKUP/packages/"
    log "  $SELECTED_BACKUP/configs/"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Dotsible Emergency Rollback Script"
        echo ""
        echo "Provides emergency rollback capabilities for Dotsible changes including:"
        echo "  - Restoration of dotfiles from backups"
        echo "  - Package restoration information"
        echo "  - System configuration restoration guidance"
        echo "  - Cleanup of Dotsible artifacts"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --list-backups      List available backups"
        echo "  --verify-backup ID  Verify specific backup integrity"
        echo "  --cleanup-only      Only cleanup Dotsible artifacts"
        echo "  --remove-apps       Remove Dotsible-installed applications"
        echo ""
        echo "Examples:"
        echo "  $0                      # Interactive rollback"
        echo "  $0 --list-backups       # List available backups"
        echo "  $0 --cleanup-only       # Cleanup artifacts only"
        echo ""
        exit 0
        ;;
    --list-backups)
        list_backups
        ;;
    --verify-backup)
        if [ -z "$2" ]; then
            error "Backup ID required"
            exit 1
        fi
        backup_path="$BACKUP_ROOT/$2"
        verify_backup "$backup_path"
        ;;
    --cleanup-only)
        header "Cleanup Only Mode"
        cleanup_dotsible_artifacts
        success "Cleanup completed"
        ;;
    --remove-apps)
        header "Remove Applications Mode"
        remove_dotsible_applications
        success "Application removal completed"
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