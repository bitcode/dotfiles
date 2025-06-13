#!/bin/zsh

# GNU Stow Diagnostic Script
# Analyzes the current symlink structure and identifies inconsistencies

set -e

echo "🔍 GNU Stow Symlink Structure Diagnostic"
echo "========================================"
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

echo "🔍 Step 1: Analyzing dotfiles source structure"
echo "---------------------------------------------"

# Check each application's structure
for app in nvim starship alacritty zsh tmux git; do
    if [ -d "$DOTFILES_DIR/$app" ]; then
        echo "📁 $app:"
        echo "   Source: $DOTFILES_DIR/$app"
        
        # Check internal structure
        if [ -d "$DOTFILES_DIR/$app/.config" ]; then
            echo "   Structure: .config/ subdirectory found"
            ls -la "$DOTFILES_DIR/$app/.config/" | head -3 | sed 's/^/     /'
        else
            echo "   Structure: Direct files"
            ls -la "$DOTFILES_DIR/$app/" | head -3 | sed 's/^/     /'
        fi
        echo ""
    else
        echo "❌ $app: Source directory not found"
        echo ""
    fi
done

echo "🔍 Step 2: Analyzing current symlink state"
echo "-----------------------------------------"

# Check ~/.config/ symlinks
echo "📁 ~/.config/ directory contents:"
ls -la "$CONFIG_DIR/" | grep -E "(nvim|starship|alacritty|git)" || echo "   No relevant symlinks found"
echo ""

# Check home directory symlinks
echo "📁 ~/ directory symlinks:"
ls -la "$HOME_DIR/" | grep -E "(\.zshrc|\.gitconfig|\.tmux\.conf)" || echo "   No relevant symlinks found"
echo ""

echo "🔍 Step 3: Identifying inconsistencies"
echo "-------------------------------------"

# Check nvim
if [ -L "$CONFIG_DIR/nvim" ]; then
    target=$(readlink "$CONFIG_DIR/nvim")
    echo "✅ nvim: Symlink exists → $target"
elif [ -d "$CONFIG_DIR/nvim" ]; then
    echo "⚠️  nvim: Directory exists (not symlink)"
else
    echo "❌ nvim: Missing (should be symlinked)"
fi

# Check starship
if [ -L "$CONFIG_DIR/starship.toml" ]; then
    target=$(readlink "$CONFIG_DIR/starship.toml")
    echo "✅ starship.toml: Symlink exists → $target"
elif [ -f "$CONFIG_DIR/starship.toml" ]; then
    echo "❌ starship.toml: Regular file (should be symlink)"
else
    echo "❌ starship.toml: Missing"
fi

# Check alacritty
if [ -L "$CONFIG_DIR/alacritty" ]; then
    target=$(readlink "$CONFIG_DIR/alacritty")
    echo "✅ alacritty: Symlink exists → $target"
    
    # Check if target path is consistent
    if [[ "$target" == *"/Users/mdrozrosario/dotfiles/"* ]]; then
        echo "   ✅ Path consistency: Correct dotfiles path"
    elif [[ "$target" == *"/Users/mdrozrosario/dotsible/"* ]]; then
        echo "   ❌ Path consistency: Wrong path (dotsible instead of dotfiles)"
    else
        echo "   ⚠️  Path consistency: Unexpected path format"
    fi
else
    echo "❌ alacritty: Missing or not symlink"
fi

# Check git
if [ -L "$CONFIG_DIR/git" ]; then
    target=$(readlink "$CONFIG_DIR/git")
    echo "✅ git: Symlink exists → $target"
    
    # Check if target path is consistent
    if [[ "$target" == *"/Users/mdrozrosario/dotfiles/"* ]]; then
        echo "   ✅ Path consistency: Correct dotfiles path"
    elif [[ "$target" == *"/Users/mdrozrosario/dotsible/"* ]]; then
        echo "   ❌ Path consistency: Wrong path (dotsible instead of dotfiles)"
    else
        echo "   ⚠️  Path consistency: Unexpected path format"
    fi
else
    echo "❌ git: Missing or not symlink"
fi

echo ""
echo "🔍 Step 4: GNU Stow dry-run analysis"
echo "-----------------------------------"

cd "$DOTFILES_DIR"

for app in nvim starship alacritty zsh; do
    if [ -d "$app" ]; then
        echo "🧪 Testing stow dry-run for $app:"
        stow --dry-run --target="$HOME" "$app" 2>&1 | head -5 | sed 's/^/   /'
        echo ""
    fi
done

echo "🎯 Step 5: Recommended fixes"
echo "----------------------------"

echo "1. Remove inconsistent symlinks:"
echo "   rm ~/.config/git ~/.config/starship.toml"
echo ""
echo "2. Clean up backup files:"
echo "   rm ~/.config/starship.toml.*"
echo ""
echo "3. Re-deploy with correct paths:"
echo "   cd $DOTFILES_DIR"
echo "   stow --target=$HOME nvim starship alacritty zsh"
echo ""
echo "4. Verify deployment:"
echo "   ls -la ~/.config/nvim ~/.config/starship.toml ~/.config/alacritty"
echo ""

echo "✅ Diagnostic completed!"
