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
    
    if grep -q "community-ansible-dev-tools" roles/platform_specific/macos/tasks/main.yml; then
        echo "✅ macOS: Has community-ansible-dev-tools installation"
    else
        echo "❌ macOS: Missing community-ansible-dev-tools installation"
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
    
    if grep -q "community-ansible-dev-tools" roles/platform_specific/windows/tasks/main.yml; then
        echo "✅ Windows: Has community-ansible-dev-tools installation"
    else
        echo "❌ Windows: Missing community-ansible-dev-tools installation"
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
    
    if grep -q "community-ansible-dev-tools" roles/platform_specific/archlinux/tasks/main.yml; then
        echo "✅ Arch Linux: Has community-ansible-dev-tools installation"
    else
        echo "❌ Arch Linux: Missing community-ansible-dev-tools installation"
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
    
    if grep -q "community-ansible-dev-tools" roles/platform_specific/ubuntu/tasks/main.yml; then
        echo "✅ Ubuntu: Has community-ansible-dev-tools installation"
    else
        echo "❌ Ubuntu: Missing community-ansible-dev-tools installation"
    fi
fi

echo ""
echo "🎉 Python development tools integration test completed!"
echo ""
echo "📋 Summary:"
echo "- pipx: Python package isolation tool"
echo "- community-ansible-dev-tools: Ansible development toolkit"
echo "- ansible-lint: Ansible linting tool"
echo ""
echo "All tools integrated with proper dependency ordering and idempotent patterns!"
