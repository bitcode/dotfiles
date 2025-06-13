#!/bin/zsh

# Comprehensive GNU Stow Diagnostic Script
# This script will identify exactly why no symlinks are being created

set -e

echo "🔍 COMPREHENSIVE GNU STOW DIAGNOSTIC"
echo "===================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

DOTFILES_ROOT="/Users/mdrozrosario/dotfiles/files/dotfiles"
HOME_DIR="$HOME"

echo "📋 STEP 1: Environment Check"
echo "----------------------------"
echo "User: $(whoami)"
echo "Home: $HOME_DIR"
echo "Current directory: $(pwd)"
echo "Dotfiles root: $DOTFILES_ROOT"
echo ""

echo "📋 STEP 2: GNU Stow Installation Check"
echo "--------------------------------------"
if command -v stow >/dev/null 2>&1; then
    echo "✅ GNU Stow is installed: $(which stow)"
    echo "Version: $(stow --version | head -1)"
else
    echo "❌ GNU Stow is NOT installed"
    echo "Installing GNU Stow..."
    if command -v brew >/dev/null 2>&1; then
        brew install stow
        echo "✅ GNU Stow installed via Homebrew"
    else
        echo "❌ Homebrew not available, cannot install GNU Stow"
        exit 1
    fi
fi
echo ""

echo "📋 STEP 3: Dotfiles Directory Structure Check"
echo "---------------------------------------------"
if [ -d "$DOTFILES_ROOT" ]; then
    echo "✅ Dotfiles root exists: $DOTFILES_ROOT"
    echo ""
    echo "📁 Available applications:"
    cd "$DOTFILES_ROOT"
    for app in */; do
        if [ -d "$app" ]; then
            app_name=$(basename "$app")
            echo "  📦 $app_name"
            
            # Check internal structure
            if [ -d "$app/.config" ]; then
                echo "    └── .config/ structure:"
                ls -la "$app/.config/" | head -3 | sed 's/^/        /'
            else
                echo "    └── Direct files:"
                ls -la "$app" | head -3 | sed 's/^/        /'
            fi
        fi
    done
else
    echo "❌ Dotfiles root does NOT exist: $DOTFILES_ROOT"
    exit 1
fi
echo ""

echo "📋 STEP 4: Current Symlink State Check"
echo "--------------------------------------"
echo "🔍 Checking ~/.zshrc:"
if [ -L "$HOME_DIR/.zshrc" ]; then
    target=$(readlink "$HOME_DIR/.zshrc")
    echo "  ✅ Symlink exists: ~/.zshrc → $target"
elif [ -f "$HOME_DIR/.zshrc" ]; then
    echo "  ⚠️  Regular file exists (not symlink)"
else
    echo "  ❌ Does not exist"
fi

echo "🔍 Checking ~/.config/nvim:"
if [ -L "$HOME_DIR/.config/nvim" ]; then
    target=$(readlink "$HOME_DIR/.config/nvim")
    echo "  ✅ Symlink exists: ~/.config/nvim → $target"
elif [ -d "$HOME_DIR/.config/nvim" ]; then
    echo "  ⚠️  Regular directory exists (not symlink)"
else
    echo "  ❌ Does not exist"
fi

echo "🔍 Checking ~/.config/alacritty:"
if [ -L "$HOME_DIR/.config/alacritty" ]; then
    target=$(readlink "$HOME_DIR/.config/alacritty")
    echo "  ✅ Symlink exists: ~/.config/alacritty → $target"
elif [ -d "$HOME_DIR/.config/alacritty" ]; then
    echo "  ⚠️  Regular directory exists (not symlink)"
else
    echo "  ❌ Does not exist"
fi

echo "🔍 Checking ~/.config/starship.toml:"
if [ -L "$HOME_DIR/.config/starship.toml" ]; then
    target=$(readlink "$HOME_DIR/.config/starship.toml")
    echo "  ✅ Symlink exists: ~/.config/starship.toml → $target"
elif [ -f "$HOME_DIR/.config/starship.toml" ]; then
    echo "  ⚠️  Regular file exists (not symlink)"
else
    echo "  ❌ Does not exist"
fi
echo ""

echo "📋 STEP 5: Manual GNU Stow Test"
echo "-------------------------------"
cd "$DOTFILES_ROOT"
echo "Working directory: $(pwd)"
echo ""

echo "🧪 Testing stow dry-run for each application:"
for app in zsh nvim alacritty starship; do
    if [ -d "$app" ]; then
        echo "  Testing $app:"
        echo "    Command: stow --dry-run --target=$HOME_DIR $app"
        stow_output=$(stow --dry-run --target="$HOME_DIR" "$app" 2>&1)
        stow_rc=$?
        echo "    Exit code: $stow_rc"
        echo "    Output:"
        echo "$stow_output" | sed 's/^/      /'
        echo ""
    else
        echo "  ❌ $app directory not found"
    fi
done

echo "📋 STEP 6: Actual Stow Deployment Test"
echo "--------------------------------------"
echo "🚀 Attempting to deploy zsh with stow:"
cd "$DOTFILES_ROOT"
echo "Working directory: $(pwd)"
echo "Command: stow --target=$HOME_DIR zsh"

if stow --target="$HOME_DIR" zsh 2>&1; then
    echo "✅ Stow command succeeded"
    
    echo "🔍 Verifying deployment:"
    if [ -L "$HOME_DIR/.zshrc" ]; then
        target=$(readlink "$HOME_DIR/.zshrc")
        echo "  ✅ SUCCESS: ~/.zshrc → $target"
    else
        echo "  ❌ FAILED: ~/.zshrc was not created as symlink"
    fi
else
    echo "❌ Stow command failed"
fi
echo ""

echo "📋 STEP 7: Diagnosis Summary"
echo "----------------------------"
echo "This diagnostic will show exactly what's preventing symlink creation."
echo "Check the output above for specific error messages and missing components."
echo ""
echo "✅ Diagnostic completed!"
