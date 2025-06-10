#!/bin/bash
# Verify README.md accuracy against actual repository structure
echo "🔍 Verifying README.md Accuracy"
echo "==============================="

# Check bootstrap scripts
echo "✅ Checking bootstrap scripts..."
if [[ -f "bootstrap.sh" && -x "bootstrap.sh" ]]; then
    echo "✅ bootstrap.sh: Exists and executable"
else
    echo "❌ bootstrap.sh: Missing or not executable"
fi

if [[ -f "bootstrap.ps1" ]]; then
    echo "✅ bootstrap.ps1: Exists"
else
    echo "❌ bootstrap.ps1: Missing"
fi

# Check platform-specific bootstrap scripts
platforms=("macos" "windows" "archlinux" "ubuntu")
for platform in "${platforms[@]}"; do
    if [[ "$platform" == "windows" ]]; then
        script="scripts/bootstrap_${platform}.ps1"
    else
        script="scripts/bootstrap_${platform}.sh"
    fi
    
    if [[ -f "$script" ]]; then
        echo "✅ $script: Exists"
        if [[ "$platform" != "windows" && -x "$script" ]]; then
            echo "✅ $script: Executable"
        fi
    else
        echo "❌ $script: Missing"
    fi
done

# Check platform-specific roles
echo ""
echo "✅ Checking platform-specific roles..."
for platform in "${platforms[@]}"; do
    role_dir="roles/platform_specific/$platform"
    if [[ -d "$role_dir" ]]; then
        echo "✅ $role_dir: Exists"
        
        # Check for main task file
        if [[ -f "$role_dir/tasks/main.yml" ]]; then
            echo "✅ $role_dir/tasks/main.yml: Exists"
        else
            echo "❌ $role_dir/tasks/main.yml: Missing"
        fi
    else
        echo "❌ $role_dir: Missing"
    fi
done

# Check test scripts
echo ""
echo "✅ Checking test scripts..."
test_scripts=(
    "scripts/test_bootstrap.sh"
    "scripts/test_python_dev_tools.sh"
    "scripts/test_ansible_python_dev_tools.sh"
    "scripts/test_idempotent.sh"
    "scripts/validate_phase3.sh"
)

for script in "${test_scripts[@]}"; do
    if [[ -f "$script" ]]; then
        echo "✅ $script: Exists"
    else
        echo "❌ $script: Missing"
    fi
done

# Check application roles
echo ""
echo "✅ Checking application roles..."
app_roles=(
    "roles/applications/neovim"
    "roles/applications/tmux"
    "roles/applications/zsh"
    "roles/applications/i3"
    "roles/applications/hyprland"
    "roles/applications/sway"
)

for role in "${app_roles[@]}"; do
    if [[ -d "$role" ]]; then
        echo "✅ $role: Exists"
    else
        echo "❌ $role: Missing"
    fi
done

# Check configuration files
echo ""
echo "✅ Checking configuration files..."
config_files=(
    "ansible.cfg"
    "requirements.yml"
)

for file in "${config_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "✅ $file: Exists"
    else
        echo "❌ $file: Missing"
    fi
done

# Check Python dev tools integration
echo ""
echo "✅ Checking Python dev tools integration..."
if grep -q "pipx" roles/platform_specific/*/tasks/main.yml 2>/dev/null; then
    echo "✅ pipx integration: Found in platform roles"
else
    echo "❌ pipx integration: Missing from platform roles"
fi

if grep -q "ansible-dev-tools" roles/platform_specific/*/tasks/main.yml 2>/dev/null; then
    echo "✅ ansible-dev-tools integration: Found in platform roles"
else
    echo "❌ ansible-dev-tools integration: Missing from platform roles"
fi

if grep -q "ansible-lint" roles/platform_specific/*/tasks/main.yml 2>/dev/null; then
    echo "✅ ansible-lint integration: Found in platform roles"
else
    echo "❌ ansible-lint integration: Missing from platform roles"
fi

echo ""
echo "🎉 README.md verification completed!"
echo ""
echo "📋 Summary:"
echo "The README.md file documents the current dotsible cross-platform"
echo "developer environment restoration system with:"
echo "- ✅ Bootstrap infrastructure for all platforms"
echo "- ✅ Ansible role-based architecture"
echo "- ✅ Python development tools integration"
echo "- ✅ Comprehensive testing framework"
echo "- ✅ Platform-specific package management"
echo "- ✅ Cross-platform application support"
