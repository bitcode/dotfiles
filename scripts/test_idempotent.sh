#!/bin/bash
echo "🔍 Testing Idempotent Package Management"
echo "========================================"

# Test syntax
echo "✅ Testing site.yml syntax..."
ansible-playbook --syntax-check site.yml

echo ""
echo "✅ Checking platform roles for idempotent patterns..."

# Check macOS
if grep -q "brew list" roles/platform_specific/macos/tasks/main.yml; then
    echo "✅ macOS: Has brew list check"
else
    echo "❌ macOS: Missing brew list check"
fi

# Check Windows  
if grep -q "choco list --local-only" roles/platform_specific/windows/tasks/main.yml; then
    echo "✅ Windows: Has choco list check"
else
    echo "❌ Windows: Missing choco list check"
fi

# Check Arch Linux
if grep -q "pacman -Q" roles/platform_specific/archlinux/tasks/main.yml; then
    echo "✅ Arch Linux: Has pacman -Q check"
else
    echo "❌ Arch Linux: Missing pacman -Q check"
fi

# Check Ubuntu
if grep -q "dpkg -l" roles/platform_specific/ubuntu/tasks/main.yml; then
    echo "✅ Ubuntu: Has dpkg -l check"
else
    echo "❌ Ubuntu: Missing dpkg -l check"
fi

echo ""
echo "🎉 Idempotent package management validation complete!"
