#!/bin/bash
# Test Development Tools Integration in Dotsible Cross-Platform Ansible Roles
echo "🔧 Testing Development Tools Integration in Dotsible"
echo "===================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
    esac
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v pacman >/dev/null 2>&1; then
            echo "archlinux"
        elif command -v apt >/dev/null 2>&1; then
            echo "ubuntu"
        else
            echo "linux-unknown"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

PLATFORM=$(detect_platform)
print_status "INFO" "Detected platform: $PLATFORM"

# Test platform-specific role existence
echo ""
echo "🔍 Testing platform-specific role structure..."
platforms=("macos" "windows" "archlinux" "ubuntu")
for platform in "${platforms[@]}"; do
    role_dir="roles/platform_specific/$platform"
    if [[ -d "$role_dir" ]]; then
        print_status "PASS" "$platform: Role directory exists"
        
        # Check vars file
        vars_file="$role_dir/vars/main.yml"
        if [[ -f "$vars_file" ]]; then
            print_status "PASS" "$platform: Variables file exists"
            
            # Check for development tools variables
            if grep -q "development_tools\|dev_packages\|assembler_packages" "$vars_file"; then
                print_status "PASS" "$platform: Development tools variables found"
            else
                print_status "FAIL" "$platform: Development tools variables missing"
            fi
        else
            print_status "FAIL" "$platform: Variables file missing"
        fi
        
        # Check tasks file
        tasks_file="$role_dir/tasks/main.yml"
        if [[ -f "$tasks_file" ]]; then
            print_status "PASS" "$platform: Tasks file exists"
        else
            print_status "FAIL" "$platform: Tasks file missing"
        fi
    else
        print_status "FAIL" "$platform: Role directory missing"
    fi
done

# Test development tools categories
echo ""
echo "🔧 Testing development tools categories..."

test_development_categories() {
    local platform=$1
    local vars_file="roles/platform_specific/$platform/vars/main.yml"
    
    if [[ ! -f "$vars_file" ]]; then
        print_status "FAIL" "$platform: Cannot test - vars file missing"
        return
    fi
    
    # Test for essential compiler categories
    categories=(
        "gcc\|clang\|llvm"
        "cmake\|ninja\|make"
        "nasm\|yasm"
        "rust\|cargo"
        "go\|golang"
        "python"
        "node\|npm"
    )
    
    category_names=(
        "Core compilers (GCC/Clang/LLVM)"
        "Build systems (CMake/Ninja/Make)"
        "Assemblers (NASM/YASM)"
        "Rust toolchain"
        "Go toolchain"
        "Python toolchain"
        "Node.js toolchain"
    )
    
    for i in "${!categories[@]}"; do
        if grep -q "${categories[$i]}" "$vars_file"; then
            print_status "PASS" "$platform: ${category_names[$i]} found"
        else
            print_status "WARN" "$platform: ${category_names[$i]} not found"
        fi
    done
}

for platform in "${platforms[@]}"; do
    test_development_categories "$platform"
done

# Test cross-platform consistency
echo ""
echo "🌐 Testing cross-platform consistency..."

test_cross_platform_consistency() {
    local tool=$1
    local found_platforms=()
    
    for platform in "${platforms[@]}"; do
        vars_file="roles/platform_specific/$platform/vars/main.yml"
        if [[ -f "$vars_file" ]] && grep -q "$tool" "$vars_file"; then
            found_platforms+=("$platform")
        fi
    done
    
    if [[ ${#found_platforms[@]} -ge 3 ]]; then
        print_status "PASS" "$tool: Available on ${#found_platforms[@]} platforms (${found_platforms[*]})"
    elif [[ ${#found_platforms[@]} -ge 2 ]]; then
        print_status "WARN" "$tool: Available on ${#found_platforms[@]} platforms (${found_platforms[*]})"
    else
        print_status "FAIL" "$tool: Available on ${#found_platforms[@]} platforms only"
    fi
}

# Test essential cross-platform tools
cross_platform_tools=(
    "gcc"
    "clang"
    "cmake"
    "ninja"
    "nasm"
    "rust"
    "go"
    "python"
    "node"
)

for tool in "${cross_platform_tools[@]}"; do
    test_cross_platform_consistency "$tool"
done

# Test idempotent patterns
echo ""
echo "🔄 Testing idempotent installation patterns..."

test_idempotent_patterns() {
    local platform=$1
    local tasks_file="roles/platform_specific/$platform/tasks/main.yml"
    
    if [[ ! -f "$tasks_file" ]]; then
        print_status "FAIL" "$platform: Cannot test - tasks file missing"
        return
    fi
    
    # Check for idempotent patterns
    if grep -q "register:.*check" "$tasks_file"; then
        print_status "PASS" "$platform: Check-before-install pattern found"
    else
        print_status "WARN" "$platform: Check-before-install pattern not found"
    fi
    
    if grep -q "when:.*rc.*!= 0\|when:.*rc.*== 0" "$tasks_file"; then
        print_status "PASS" "$platform: Conditional installation logic found"
    else
        print_status "WARN" "$platform: Conditional installation logic not found"
    fi
    
    if grep -q "failed_when: false" "$tasks_file"; then
        print_status "PASS" "$platform: Error handling patterns found"
    else
        print_status "WARN" "$platform: Error handling patterns not found"
    fi
}

for platform in "${platforms[@]}"; do
    test_idempotent_patterns "$platform"
done

# Test status indicators
echo ""
echo "📊 Testing status indicators and clean output..."

test_status_indicators() {
    local platform=$1
    local tasks_file="roles/platform_specific/$platform/tasks/main.yml"
    
    if [[ ! -f "$tasks_file" ]]; then
        print_status "FAIL" "$platform: Cannot test - tasks file missing"
        return
    fi
    
    # Check for status indicators
    status_patterns=(
        "✅\|INSTALLED"
        "❌\|MISSING\|FAILED"
        "⏭️\|SKIPPED"
        "🔄\|CHANGED"
    )
    
    status_names=(
        "Success indicators"
        "Error indicators"
        "Skip indicators"
        "Change indicators"
    )
    
    for i in "${!status_patterns[@]}"; do
        if grep -q "${status_patterns[$i]}" "$tasks_file"; then
            print_status "PASS" "$platform: ${status_names[$i]} found"
        else
            print_status "WARN" "$platform: ${status_names[$i]} not found"
        fi
    done
}

for platform in "${platforms[@]}"; do
    test_status_indicators "$platform"
done

# Test Go packages integration
echo ""
echo "🐹 Testing Go packages integration..."

test_go_packages() {
    local platform=$1
    local vars_file="roles/platform_specific/$platform/vars/main.yml"
    local tasks_file="roles/platform_specific/$platform/tasks/main.yml"

    if [[ ! -f "$vars_file" ]]; then
        print_status "FAIL" "$platform: Cannot test Go packages - vars file missing"
        return
    fi

    # Check for go_packages variable
    if grep -q "go_packages:" "$vars_file"; then
        print_status "PASS" "$platform: go_packages variable found"

        # Check for essential Go tools
        go_tools=(
            "golangci-lint"
            "goimports"
            "godoc"
            "delve\|dlv"
            "staticcheck"
            "gopls"
        )

        go_tool_names=(
            "golangci-lint (linter)"
            "goimports (import formatter)"
            "godoc (documentation)"
            "delve (debugger)"
            "staticcheck (static analyzer)"
            "gopls (language server)"
        )

        for i in "${!go_tools[@]}"; do
            if grep -q "${go_tools[$i]}" "$vars_file"; then
                print_status "PASS" "$platform: ${go_tool_names[$i]} found in go_packages"
            else
                print_status "WARN" "$platform: ${go_tool_names[$i]} not found in go_packages"
            fi
        done
    else
        print_status "FAIL" "$platform: go_packages variable missing"
    fi

    # Check for Go packages installation logic in tasks
    if [[ -f "$tasks_file" ]]; then
        if grep -q "go install\|GO PACKAGES" "$tasks_file"; then
            print_status "PASS" "$platform: Go packages installation logic found"
        else
            print_status "WARN" "$platform: Go packages installation logic not found"
        fi

        if grep -q "go version\|go_available_check" "$tasks_file"; then
            print_status "PASS" "$platform: Go availability check found"
        else
            print_status "WARN" "$platform: Go availability check not found"
        fi
    fi
}

for platform in "${platforms[@]}"; do
    test_go_packages "$platform"
done

# Summary
echo ""
echo "📋 Test Summary"
echo "==============="
print_status "INFO" "Development tools integration test completed"
print_status "INFO" "Platform detected: $PLATFORM"
print_status "INFO" "Check output above for any FAIL or WARN items"

# Suggest next steps
echo ""
echo "🚀 Suggested next steps:"
echo "1. Run: ansible-playbook -i inventories/local/hosts.yml site.yml --tags platform_specific --check"
echo "2. Test specific platform: ansible-playbook -i inventories/local/hosts.yml site.yml --tags $PLATFORM --check"
echo "3. Install development tools: ansible-playbook -i inventories/local/hosts.yml site.yml --tags platform_specific"
echo "4. Verify installations manually using platform-specific package managers"

echo ""
echo "🔧 Platform-specific verification commands:"
case $PLATFORM in
    "macos")
        echo "   brew list | grep -E '(gcc|clang|cmake|ninja|nasm|rust|go)'"
        echo "   cargo install --list"
        echo "   go list -m all"
        ;;
    "archlinux")
        echo "   pacman -Q | grep -E '(gcc|clang|cmake|ninja|nasm|rust|go)'"
        echo "   cargo install --list"
        echo "   go list -m all"
        ;;
    "ubuntu")
        echo "   dpkg -l | grep -E '(gcc|clang|cmake|ninja|nasm|rust|go)'"
        echo "   cargo install --list"
        echo "   go list -m all"
        ;;
    "windows")
        echo "   choco list --local-only | findstr /i 'gcc clang cmake ninja nasm rust go'"
        echo "   cargo install --list"
        echo "   go list -m all"
        ;;
esac
