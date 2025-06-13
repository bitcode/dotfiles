#!/bin/zsh

# GNU Stow Symlink Cleanup Script
# This script safely removes incorrect nested symlinks created by the previous broken implementation

set -e  # Exit on any error

echo "🧹 GNU Stow Symlink Cleanup Script"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="/Users/mdrozrosario/dotfiles/files/dotfiles"
HOME_DIR="$HOME"
CONFIG_DIR="$HOME/.config"

echo "📂 Configuration:"
echo "   Dotfiles directory: $DOTFILES_DIR"
echo "   Home directory: $HOME_DIR"
echo "   Config directory: $CONFIG_DIR"
echo ""

# Function to check if a path is a symlink
is_symlink() {
    [ -L "$1" ]
}

# Function to check if a path is a directory
is_directory() {
    [ -d "$1" ]
}

# Function to safely backup a file/directory
backup_path() {
    local path="$1"
    local backup_dir="$HOME/.dotsible/backups"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    
    mkdir -p "$backup_dir"
    
    if [ -e "$path" ]; then
        local basename=$(basename "$path")
        local backup_path="$backup_dir/${basename}.cleanup-backup.$timestamp"
        echo "🛡️  Backing up $path to $backup_path"
        cp -r "$path" "$backup_path"
        return 0
    fi
    return 1
}

echo "🔍 Step 1: Analyzing current symlink state"
echo "----------------------------------------"

# Check nvim symlink
if is_symlink "$CONFIG_DIR/nvim"; then
    target=$(readlink "$CONFIG_DIR/nvim")
    echo "📍 Found nvim symlink: $CONFIG_DIR/nvim -> $target"
    
    # Check if it's pointing to the wrong location (should point to nvim/.config/nvim, not just nvim)
    if [[ "$target" == */nvim ]] && [[ "$target" != */nvim/.config/nvim ]]; then
        echo "❌ INCORRECT SYMLINK: Points to nvim directory instead of nvim/.config/nvim"
        echo "   Current: $target"
        echo "   Should be: $DOTFILES_DIR/nvim/.config/nvim"
        NEEDS_CLEANUP=true
    else
        echo "✅ Symlink appears correct"
        NEEDS_CLEANUP=false
    fi
elif is_directory "$CONFIG_DIR/nvim"; then
    echo "📁 Found nvim directory (not symlink)"
    # Check for nested structure
    if [ -d "$CONFIG_DIR/nvim/.config" ]; then
        echo "❌ NESTED STRUCTURE DETECTED: $CONFIG_DIR/nvim/.config/ exists"
        NEEDS_CLEANUP=true
    else
        echo "✅ No nested structure in directory"
        NEEDS_CLEANUP=false
    fi
else
    echo "ℹ️  No nvim configuration found"
    NEEDS_CLEANUP=false
fi

echo ""

if [ "$NEEDS_CLEANUP" = "true" ]; then
    echo "🧹 Step 2: Performing cleanup"
    echo "----------------------------"
    
    # Backup current state
    if backup_path "$CONFIG_DIR/nvim"; then
        echo "✅ Backup completed"
    fi
    
    # Remove the incorrect symlink/directory
    echo "🗑️  Removing incorrect nvim configuration..."
    rm -rf "$CONFIG_DIR/nvim"
    echo "✅ Removed $CONFIG_DIR/nvim"
    
    echo ""
    echo "🔍 Step 3: Verification"
    echo "---------------------"
    
    if [ ! -e "$CONFIG_DIR/nvim" ]; then
        echo "✅ Successfully removed incorrect nvim configuration"
    else
        echo "❌ Failed to remove nvim configuration"
        exit 1
    fi
else
    echo "✅ No cleanup needed - symlinks appear correct"
fi

echo ""
echo "🔍 Step 4: Checking dotfiles structure"
echo "-------------------------------------"

# Verify the source structure is correct for GNU Stow
if [ -d "$DOTFILES_DIR/nvim/.config/nvim" ]; then
    echo "✅ Correct source structure: $DOTFILES_DIR/nvim/.config/nvim/"
    echo "📁 Contents:"
    ls -la "$DOTFILES_DIR/nvim/.config/nvim/" | head -5
else
    echo "❌ Source structure incorrect: $DOTFILES_DIR/nvim/.config/nvim/ not found"
    exit 1
fi

echo ""
echo "🎯 Step 5: Ready for correct deployment"
echo "--------------------------------------"

echo "✅ Cleanup completed successfully!"
echo ""
echo "🚀 Next steps:"
echo "1. Run: cd $DOTFILES_DIR"
echo "2. Test: stow --dry-run --target=$HOME nvim"
echo "3. Deploy: stow --target=$HOME nvim"
echo "4. Or run: ./run-dotsible.sh --profile enterprise --tags dotfiles --verbose"
echo ""
echo "Expected result:"
echo "   $DOTFILES_DIR/nvim/.config/nvim/ → ~/.config/nvim/"
echo ""
echo "🔍 Verification commands:"
echo "   ls -la ~/.config/nvim"
echo "   readlink ~/.config/nvim"
echo "   ls -la ~/.config/nvim/init.lua"
