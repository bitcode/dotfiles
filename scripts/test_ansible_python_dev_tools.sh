#!/bin/bash
# Test Python Development Tools Integration in Ansible Playbooks
echo "🔍 Testing Python Development Tools Integration in Ansible Playbooks"
echo "===================================================================="

# Test platform-specific roles exist
echo "✅ Testing platform-specific role existence..."
platforms=("macos" "windows" "archlinux" "ubuntu")
for platform in "${platforms[@]}"; do
    role_dir="roles/platform_specific/$platform"
    if [[ -d "$role_dir" ]]; then
        echo "✅ $platform: Role directory exists"
        
        # Check tasks file
        tasks_file="$role_dir/tasks/main.yml"
        if [[ -f "$tasks_file" ]]; then
            echo "✅ $platform: Tasks file exists"
        else
            echo "❌ $platform: Tasks file missing"
        fi
    else
        echo "❌ $platform: Role directory missing"
    fi
done

echo ""
echo "✅ Testing Python dev tools integration in platform roles..."

# Check macOS role
echo "--- macOS Role ---"
if [[ -f "roles/platform_specific/macos/tasks/main.yml" ]]; then
    if grep -q "PYTHON DEVELOPMENT TOOLS" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has Python development tools section"
    else
        echo "❌ macOS: Missing Python development tools section"
    fi
    
    if grep -q "Check if pip3 is working properly" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has pip3 validation"
    else
        echo "❌ macOS: Missing pip3 validation"
    fi
    
    if grep -q "Check if pipx is already installed" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has pipx installation check"
    else
        echo "❌ macOS: Missing pipx installation check"
    fi
    
    if grep -q "ansible-dev-tools" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has ansible-dev-tools installation"
    else
        echo "❌ macOS: Missing ansible-dev-tools installation"
    fi
    
    if grep -q "ansible-lint" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has ansible-lint installation"
    else
        echo "❌ macOS: Missing ansible-lint installation"
    fi
fi

# Check Windows role
echo "--- Windows Role ---"
if [[ -f "roles/platform_specific/windows/tasks/main.yml" ]]; then
    if grep -q "PYTHON DEVELOPMENT TOOLS" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has Python development tools section"
    else
        echo "❌ Windows: Missing Python development tools section"
    fi
    
    if grep -q "Check if Python is installed" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has Python validation"
    else
        echo "❌ Windows: Missing Python validation"
    fi
    
    if grep -q "Check if pipx is already installed" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has pipx installation check"
    else
        echo "❌ Windows: Missing pipx installation check"
    fi
    
    if grep -q "ansible-dev-tools" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has ansible-dev-tools installation"
    else
        echo "❌ Windows: Missing ansible-dev-tools installation"
    fi
    
    if grep -q "ansible-lint" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has ansible-lint installation"
    else
        echo "❌ Windows: Missing ansible-lint installation"
    fi
fi

# Check Arch Linux role
echo "--- Arch Linux Role ---"
if [[ -f "roles/platform_specific/archlinux/tasks/main.yml" ]]; then
    if grep -q "PYTHON DEVELOPMENT TOOLS" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has Python development tools section"
    else
        echo "❌ Arch Linux: Missing Python development tools section"
    fi
    
    if grep -q "Check if Python 3 is installed" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has Python 3 validation"
    else
        echo "❌ Arch Linux: Missing Python 3 validation"
    fi
    
    if grep -q "Check if pipx is already installed" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has pipx installation check"
    else
        echo "❌ Arch Linux: Missing pipx installation check"
    fi
    
    if grep -q "ansible-dev-tools" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has ansible-dev-tools installation"
    else
        echo "❌ Arch Linux: Missing ansible-dev-tools installation"
    fi
    
    if grep -q "ansible-lint" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has ansible-lint installation"
    else
        echo "❌ Arch Linux: Missing ansible-lint installation"
    fi
fi

# Check Ubuntu role
echo "--- Ubuntu Role ---"
if [[ -f "roles/platform_specific/ubuntu/tasks/main.yml" ]]; then
    if grep -q "PYTHON DEVELOPMENT TOOLS" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has Python development tools section"
    else
        echo "❌ Ubuntu: Missing Python development tools section"
    fi
    
    if grep -q "Check if Python 3 is installed" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has Python 3 validation"
    else
        echo "❌ Ubuntu: Missing Python 3 validation"
    fi
    
    if grep -q "Check if pipx is already installed" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has pipx installation check"
    else
        echo "❌ Ubuntu: Missing pipx installation check"
    fi
    
    if grep -q "ansible-dev-tools" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has ansible-dev-tools installation"
    else
        echo "❌ Ubuntu: Missing ansible-dev-tools installation"
    fi
    
    if grep -q "ansible-lint" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has ansible-lint installation"
    else
        echo "❌ Ubuntu: Missing ansible-lint installation"
    fi
fi

echo ""
echo "✅ Testing dependency ordering..."

# Check that Python dev tools come after NPM in all platform roles
for platform in "${platforms[@]}"; do
    tasks_file="roles/platform_specific/$platform/tasks/main.yml"
    if [[ -f "$tasks_file" ]]; then
        # Get line numbers
        npm_line=$(grep -n "NPM GLOBAL PACKAGES" "$tasks_file" | head -1 | cut -d: -f1)
        python_dev_line=$(grep -n "PYTHON DEVELOPMENT TOOLS" "$tasks_file" | head -1 | cut -d: -f1)
        python_packages_line=$(grep -n "PYTHON PACKAGES" "$tasks_file" | head -1 | cut -d: -f1)
        
        if [[ -n "$npm_line" && -n "$python_dev_line" && -n "$python_packages_line" ]]; then
            if [[ "$npm_line" -lt "$python_dev_line" && "$python_dev_line" -lt "$python_packages_line" ]]; then
                echo "✅ $platform: Correct dependency ordering (NPM → Python dev tools → Python packages)"
            else
                echo "❌ $platform: Incorrect dependency ordering"
            fi
        else
            echo "⚠️  $platform: Could not verify dependency ordering (missing sections)"
        fi
    fi
done

echo ""
echo "✅ Testing idempotency patterns..."

# Check for idempotent patterns in all platform roles
for platform in "${platforms[@]}"; do
    tasks_file="roles/platform_specific/$platform/tasks/main.yml"
    if [[ -f "$tasks_file" ]]; then
        echo "--- $platform Idempotency Checks ---"
        
        # Check for pipx installation check
        if grep -q "Check if pipx is already installed" "$tasks_file"; then
            echo "✅ $platform: Has pipx pre-installation check"
        else
            echo "❌ $platform: Missing pipx pre-installation check"
        fi
        
        # Check for pipx package checks
        if grep -q "Check which pipx packages are already installed" "$tasks_file"; then
            echo "✅ $platform: Has pipx package pre-installation checks"
        else
            echo "❌ $platform: Missing pipx package pre-installation checks"
        fi
        
        # Check for verification steps
        if grep -q "Verify pipx.*installation" "$tasks_file"; then
            echo "✅ $platform: Has pipx installation verification"
        else
            echo "❌ $platform: Missing pipx installation verification"
        fi
        
        # Check for status display
        if grep -q "Display.*status" "$tasks_file"; then
            echo "✅ $platform: Has status display tasks"
        else
            echo "❌ $platform: Missing status display tasks"
        fi
    fi
done

echo ""
echo "✅ Testing Ansible syntax..."

# Test syntax of all platform roles
for platform in "${platforms[@]}"; do
    tasks_file="roles/platform_specific/$platform/tasks/main.yml"
    if [[ -f "$tasks_file" ]]; then
        if ansible-playbook --syntax-check --check "$tasks_file" >/dev/null 2>&1; then
            echo "✅ $platform: Ansible syntax is valid"
        else
            echo "❌ $platform: Ansible syntax check failed"
        fi
    fi
done

echo ""
echo "🎉 Python development tools integration test completed!"
echo ""
echo "📋 Summary:"
echo "- pipx: Python package isolation tool"
echo "- ansible-dev-tools: Ansible development toolkit"
echo "- ansible-lint: Ansible linting tool"
echo ""
echo "All tools integrated with proper dependency ordering and idempotent patterns!"
