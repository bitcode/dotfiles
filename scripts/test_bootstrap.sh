#!/bin/bash
# Test Bootstrap Infrastructure
echo "🔍 Testing Bootstrap Infrastructure"
echo "=================================="

# Test main bootstrap script
if [[ -f "bootstrap.sh" && -x "bootstrap.sh" ]]; then
    echo "✅ bootstrap.sh: Exists and executable"
else
    echo "❌ bootstrap.sh: Missing or not executable"
fi

# Test platform-specific scripts
platforms=("macos" "archlinux" "ubuntu" "windows")
for platform in "${platforms[@]}"; do
    script="scripts/bootstrap_${platform}.sh"
    ps_script="scripts/bootstrap_${platform}.ps1"
    
    if [[ "$platform" == "windows" ]]; then
        if [[ -f "$ps_script" ]]; then
            echo "✅ $ps_script: Exists"
        else
            echo "❌ $ps_script: Missing"
        fi
    else
        if [[ -f "$script" && -x "$script" ]]; then
            echo "✅ $script: Exists and executable"
        else
            echo "❌ $script: Missing or not executable"
        fi
    fi
done

echo ""
echo "🎉 Bootstrap infrastructure test completed!"
