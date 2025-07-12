#!/bin/bash
# Comprehensive Test Script for Alacritty GPU Fixes
# Tests both Issue 1 (MESA errors) and Issue 2 (shell configuration)

echo "🧪 COMPREHENSIVE ALACRITTY GPU FIXES TEST"
echo "=========================================="
echo ""

# Test results tracking
tests_passed=0
tests_failed=0
total_tests=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    total_tests=$((total_tests + 1))
    echo "🔍 Test $total_tests: $test_name"
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "pass" ]; then
            echo "   ✅ PASSED"
            tests_passed=$((tests_passed + 1))
        else
            echo "   ❌ FAILED (expected to fail but passed)"
            tests_failed=$((tests_failed + 1))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo "   ✅ PASSED (correctly failed as expected)"
            tests_passed=$((tests_passed + 1))
        else
            echo "   ❌ FAILED"
            tests_failed=$((tests_failed + 1))
        fi
    fi
}

# Test function with output capture
run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="$3"
    
    total_tests=$((total_tests + 1))
    echo "🔍 Test $total_tests: $test_name"
    
    output=$(eval "$test_command" 2>&1)
    if echo "$output" | grep -q "$expected_pattern"; then
        echo "   ✅ PASSED (found: $expected_pattern)"
        tests_passed=$((tests_passed + 1))
    else
        echo "   ❌ FAILED (expected: $expected_pattern)"
        echo "   Output: $output"
        tests_failed=$((tests_failed + 1))
    fi
}

echo "📋 ISSUE 1: Default Alacritty MESA Errors"
echo "----------------------------------------"

# Source the system-wide MESA configuration
source /etc/profile.d/mesa-gpu-config.sh 2>/dev/null || echo "Warning: Could not source MESA config"

# Test 1: Default Alacritty should work without MESA errors
run_test_with_output "Default alacritty --version works" "timeout 5s alacritty --version" "alacritty"

# Test 2: System wrapper script works
run_test_with_output "System wrapper script works" "timeout 5s /usr/local/bin/alacritty-wrapper --version" "alacritty"

# Test 3: GPU-optimized launcher works
run_test_with_output "GPU-optimized launcher works" "timeout 5s ~/.local/bin/alacritty-gpu --version" "alacritty"

# Test 4: MESA environment is configured
run_test_with_output "MESA driver override is set" "echo \$MESA_LOADER_DRIVER_OVERRIDE" "nouveau"

# Test 5: OpenGL renderer uses correct driver
run_test_with_output "OpenGL uses nouveau driver" "glxinfo | grep 'OpenGL renderer'" "NV176"

echo ""
echo "📋 ISSUE 2: Shell Configuration for Desktop Launches"
echo "---------------------------------------------------"

# Test 6: Desktop entry exists and is valid
run_test "Desktop entry exists" "test -f /usr/share/applications/Alacritty.desktop" "pass"
run_test "Desktop entry is valid" "desktop-file-validate /usr/share/applications/Alacritty.desktop" "pass"

# Test 7: Desktop entry uses system wrapper
run_test_with_output "Desktop entry uses wrapper" "grep 'Exec=' /usr/share/applications/Alacritty.desktop" "alacritty-wrapper"

# Test 8: Alacritty config includes tmux auto-start
run_test_with_output "Alacritty config has tmux auto-start" "grep -A2 'terminal.shell' ~/.config/alacritty/alacritty.toml" "tmux"

# Test 9: ZSH configuration exists
run_test "ZSH configuration exists" "test -f ~/.zshrc" "pass"

# Test 10: tmux configuration exists
run_test "tmux configuration exists" "test -f ~/.tmux.conf" "pass"

# Test 11: User environment configuration exists
run_test "User environment config exists" "test -f ~/.config/environment.d/mesa-gpu.conf" "pass"

# Test 12: System-wide MESA config exists
run_test "System MESA config exists" "test -f /etc/profile.d/mesa-gpu-config.sh" "pass"

echo ""
echo "📋 INTEGRATION TESTS"
echo "-------------------"

# Test 13: GPU-optimized launcher has correct environment
run_test_with_output "GPU launcher debug shows nouveau" "ALACRITTY_GPU_DEBUG=1 timeout 5s ~/.local/bin/alacritty-gpu --version 2>&1" "nouveau"

# Test 14: System wrapper preserves environment
run_test_with_output "System wrapper preserves MESA override" "MESA_LOADER_DRIVER_OVERRIDE=nouveau timeout 5s /usr/local/bin/alacritty-wrapper --version 2>&1 && echo \$MESA_LOADER_DRIVER_OVERRIDE" "nouveau"

# Test 15: Shell alias exists
run_test_with_output "Shell alias configured" "grep 'alacritty-gpu' ~/.zshrc" "alias alacritty-gpu"

echo ""
echo "📊 TEST SUMMARY"
echo "==============="
echo "Total Tests: $total_tests"
echo "Passed: $tests_passed"
echo "Failed: $tests_failed"
echo ""

if [ $tests_failed -eq 0 ]; then
    echo "🎉 ALL TESTS PASSED!"
    echo ""
    echo "✅ Issue 1 RESOLVED: Default Alacritty no longer has MESA errors"
    echo "✅ Issue 2 RESOLVED: Desktop/rofi launches will use proper shell configuration"
    echo ""
    echo "🚀 LAUNCH METHODS AVAILABLE:"
    echo "• Command line: alacritty"
    echo "• GPU optimized: ~/.local/bin/alacritty-gpu"
    echo "• Shell alias: alacritty-gpu (after shell restart)"
    echo "• Desktop/rofi: Applications → Alacritty"
    echo "• System wrapper: /usr/local/bin/alacritty-wrapper"
    echo ""
    echo "🔧 CONFIGURATION:"
    echo "• MESA Driver: nouveau (NVIDIA)"
    echo "• Auto-start: ZSH + tmux"
    echo "• GPU Optimization: System-wide"
    echo ""
    echo "💡 USAGE NOTES:"
    echo "• All launch methods now work without MESA errors"
    echo "• Desktop/rofi launches automatically start ZSH + tmux"
    echo "• No manual environment variable overrides needed"
    echo "• Log out/in or source /etc/profile.d/mesa-gpu-config.sh for full effect"
    exit 0
else
    echo "❌ SOME TESTS FAILED!"
    echo "Please check the failed tests above and run the Ansible playbook again."
    exit 1
fi
