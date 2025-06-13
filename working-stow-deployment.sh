#!/bin/zsh

# Working GNU Stow Deployment Script
# This script will actually create the expected symlinks

set -e

echo "🚀 WORKING GNU STOW DEPLOYMENT"
echo "=============================="
echo ""

# Configuration
DOTFILES_ROOT="/Users/mdrozrosario/dotfiles/files/dotfiles"
HOME_DIR="$HOME"
STOW_CMD="/opt/homebrew/bin/stow"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "📋 Configuration:"
echo "  Dotfiles root: $DOTFILES_ROOT"
echo "  Target home: $HOME_DIR"
echo "  Stow command: $STOW_CMD"
echo ""

echo "📋 STEP 1: Verify Prerequisites"
echo "-------------------------------"

# Check stow is available
if [ -x "$STOW_CMD" ]; then
    echo "✅ GNU Stow found: $STOW_CMD"
    echo "   Version: $($STOW_CMD --version | head -1)"
else
    echo "❌ GNU Stow not found at: $STOW_CMD"
    exit 1
fi

# Check dotfiles directory
if [ -d "$DOTFILES_ROOT" ]; then
    echo "✅ Dotfiles directory exists: $DOTFILES_ROOT"
else
    echo "❌ Dotfiles directory not found: $DOTFILES_ROOT"
    exit 1
fi

# Ensure .config directory exists
mkdir -p "$HOME_DIR/.config"
echo "✅ Config directory ready: $HOME_DIR/.config"
echo ""

echo "📋 STEP 2: Backup Existing Files"
echo "--------------------------------"
backup_dir="$HOME_DIR/.dotsible/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

# Backup existing files that would conflict
for file in .zshrc .gitconfig .tmux.conf; do
    if [ -f "$HOME_DIR/$file" ] && [ ! -L "$HOME_DIR/$file" ]; then
        echo "📦 Backing up existing $file"
        cp "$HOME_DIR/$file" "$backup_dir/"
        rm "$HOME_DIR/$file"
    fi
done

# Backup existing config directories
for dir in nvim alacritty starship.toml; do
    if [ -e "$HOME_DIR/.config/$dir" ] && [ ! -L "$HOME_DIR/.config/$dir" ]; then
        echo "📦 Backing up existing .config/$dir"
        mv "$HOME_DIR/.config/$dir" "$backup_dir/"
    fi
done

echo "✅ Backups completed in: $backup_dir"
echo ""

echo "📋 STEP 3: Deploy Applications with GNU Stow"
echo "--------------------------------------------"

cd "$DOTFILES_ROOT"
echo "Working directory: $(pwd)"
echo ""

# Applications to deploy
apps=("zsh" "nvim" "alacritty" "starship" "tmux")

for app in "${apps[@]}"; do
    if [ -d "$app" ]; then
        echo "🔗 Deploying $app..."
        echo "   Command: $STOW_CMD --target=$HOME_DIR $app"
        
        # Run stow command
        if $STOW_CMD --target="$HOME_DIR" "$app" 2>&1; then
            echo "   ✅ SUCCESS: $app deployed"
            
            # Verify deployment
            case $app in
                "zsh")
                    if [ -L "$HOME_DIR/.zshrc" ]; then
                        target=$(readlink "$HOME_DIR/.zshrc")
                        echo "   ✅ Verified: ~/.zshrc → $target"
                    else
                        echo "   ❌ Failed: ~/.zshrc not created"
                    fi
                    ;;
                "nvim")
                    if [ -L "$HOME_DIR/.config/nvim" ]; then
                        target=$(readlink "$HOME_DIR/.config/nvim")
                        echo "   ✅ Verified: ~/.config/nvim → $target"
                    else
                        echo "   ❌ Failed: ~/.config/nvim not created"
                    fi
                    ;;
                "alacritty")
                    if [ -L "$HOME_DIR/.config/alacritty" ]; then
                        target=$(readlink "$HOME_DIR/.config/alacritty")
                        echo "   ✅ Verified: ~/.config/alacritty → $target"
                    else
                        echo "   ❌ Failed: ~/.config/alacritty not created"
                    fi
                    ;;
                "starship")
                    if [ -L "$HOME_DIR/.config/starship.toml" ]; then
                        target=$(readlink "$HOME_DIR/.config/starship.toml")
                        echo "   ✅ Verified: ~/.config/starship.toml → $target"
                    else
                        echo "   ❌ Failed: ~/.config/starship.toml not created"
                    fi
                    ;;
                "tmux")
                    if [ -L "$HOME_DIR/.tmux.conf" ]; then
                        target=$(readlink "$HOME_DIR/.tmux.conf")
                        echo "   ✅ Verified: ~/.tmux.conf → $target"
                    else
                        echo "   ❌ Failed: ~/.tmux.conf not created"
                    fi
                    ;;
            esac
        else
            echo "   ❌ FAILED: $app deployment failed"
        fi
        echo ""
    else
        echo "⚠️  Skipping $app (directory not found)"
        echo ""
    fi
done

echo "📋 STEP 4: Final Verification"
echo "-----------------------------"
echo "🔍 Checking all expected symlinks:"

expected_symlinks=(
    "$HOME_DIR/.zshrc:$DOTFILES_ROOT/zsh/.zshrc"
    "$HOME_DIR/.config/nvim:$DOTFILES_ROOT/nvim/.config/nvim"
    "$HOME_DIR/.config/alacritty:$DOTFILES_ROOT/alacritty/.config/alacritty"
    "$HOME_DIR/.config/starship.toml:$DOTFILES_ROOT/starship/.config/starship.toml"
    "$HOME_DIR/.tmux.conf:$DOTFILES_ROOT/tmux/.tmux.conf"
)

success_count=0
total_count=${#expected_symlinks[@]}

for symlink_spec in "${expected_symlinks[@]}"; do
    symlink_path="${symlink_spec%%:*}"
    expected_target="${symlink_spec##*:}"
    
    if [ -L "$symlink_path" ]; then
        actual_target=$(readlink "$symlink_path")
        if [ "$actual_target" = "$expected_target" ]; then
            echo "✅ CORRECT: $symlink_path → $actual_target"
            success_count=$((success_count + 1))
        else
            echo "❌ WRONG TARGET: $symlink_path → $actual_target (expected: $expected_target)"
        fi
    else
        echo "❌ MISSING: $symlink_path"
    fi
done

echo ""
echo "📊 DEPLOYMENT SUMMARY:"
echo "====================="
echo "✅ Successful symlinks: $success_count/$total_count"
echo "📦 Backups location: $backup_dir"
echo ""

if [ $success_count -eq $total_count ]; then
    echo "🎉 DEPLOYMENT SUCCESS: All symlinks created correctly!"
    echo ""
    echo "🔄 Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Your dotfiles are now active and synchronized"
    echo "  3. Any changes to files in $DOTFILES_ROOT will be reflected immediately"
else
    echo "⚠️  PARTIAL SUCCESS: Some symlinks were not created correctly"
    echo "   Check the output above for specific issues"
fi

echo ""
echo "✅ Working deployment completed!"
