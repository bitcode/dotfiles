#!/bin/bash
# Test Python Development Tools Integration
echo "🔍 Testing Python Development Tools Integration"
echo "=============================================="

# Test bootstrap scripts exist
echo "✅ Testing bootstrap script existence..."
platforms=("macos" "archlinux" "ubuntu" "windows")
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

# Test main bootstrap scripts
echo ""
echo "✅ Testing main bootstrap scripts..."
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

# Test for Python dev tools integration in scripts
echo ""
echo "✅ Testing Python dev tools integration..."

# Check macOS script
if grep -q "install_pipx" scripts/bootstrap_macos.sh; then
    echo "✅ macOS: Has pipx installation"
else
    echo "❌ macOS: Missing pipx installation"
fi

if grep -q "install_ansible_dev_tools" scripts/bootstrap_macos.sh; then
    echo "✅ macOS: Has ansible dev tools installation"
else
    echo "❌ macOS: Missing ansible dev tools installation"
fi

# Check Arch Linux script
if [[ -f "scripts/bootstrap_archlinux.sh" ]]; then
    if grep -q "install_pipx" scripts/bootstrap_archlinux.sh; then
        echo "✅ Arch Linux: Has pipx installation"
    else
        echo "❌ Arch Linux: Missing pipx installation"
    fi
    
    if grep -q "install_ansible_dev_tools" scripts/bootstrap_archlinux.sh; then
        echo "✅ Arch Linux: Has ansible dev tools installation"
    else
        echo "❌ Arch Linux: Missing ansible dev tools installation"
    fi
fi

# Check Ubuntu script
if [[ -f "scripts/bootstrap_ubuntu.sh" ]]; then
    if grep -q "install_pipx" scripts/bootstrap_ubuntu.sh; then
        echo "✅ Ubuntu: Has pipx installation"
    else
        echo "❌ Ubuntu: Missing pipx installation"
    fi
    
    if grep -q "install_ansible_dev_tools" scripts/bootstrap_ubuntu.sh; then
        echo "✅ Ubuntu: Has ansible dev tools installation"
    else
        echo "❌ Ubuntu: Missing ansible dev tools installation"
    fi
fi

# Check Windows script
if [[ -f "scripts/bootstrap_windows.ps1" ]]; then
    if grep -q "Install-Pipx" scripts/bootstrap_windows.ps1; then
        echo "✅ Windows: Has pipx installation"
    else
        echo "❌ Windows: Missing pipx installation"
    fi
    
    if grep -q "Install-AnsibleDevTools" scripts/bootstrap_windows.ps1; then
        echo "✅ Windows: Has ansible dev tools installation"
    else
        echo "❌ Windows: Missing ansible dev tools installation"
    fi
fi

# Test dependency ordering
echo ""
echo "✅ Testing dependency ordering..."

# Check that pipx comes after Python/pip in all scripts
for script in scripts/bootstrap_*.sh; do
    if [[ -f "$script" ]]; then
        platform=$(basename "$script" .sh | sed 's/bootstrap_//')
        
        # Get line numbers
        python_line=$(grep -n "install_python\|validate_python" "$script" | head -1 | cut -d: -f1)
        pipx_line=$(grep -n "install_pipx" "$script" | head -1 | cut -d: -f1)
        dev_tools_line=$(grep -n "install_ansible_dev_tools" "$script" | head -1 | cut -d: -f1)
        
        if [[ -n "$python_line" && -n "$pipx_line" && -n "$dev_tools_line" ]]; then
            if [[ "$python_line" -lt "$pipx_line" && "$pipx_line" -lt "$dev_tools_line" ]]; then
                echo "✅ $platform: Correct dependency ordering (Python → pipx → dev tools)"
            else
                echo "❌ $platform: Incorrect dependency ordering"
            fi
        fi
    fi
done

echo ""
echo "🎉 Python development tools integration test completed!"
