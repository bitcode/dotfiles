#!/bin/bash

# Test script for clean output implementation
# This script tests the new clean output formatting

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_color "$BOLD$CYAN" "🧪 Testing Dotsible Clean Output Implementation"
echo

# Test 1: Check if callback plugin exists
print_color "$CYAN" "Test 1: Checking callback plugin..."
if [[ -f "plugins/callback/dotsible_clean.py" ]]; then
    print_color "$GREEN" "✅ Callback plugin found"
else
    print_color "$RED" "❌ Callback plugin missing"
    exit 1
fi

# Test 2: Check if run script exists and is executable
print_color "$CYAN" "Test 2: Checking run script..."
if [[ -x "run-dotsible.sh" ]]; then
    print_color "$GREEN" "✅ Run script found and executable"
else
    print_color "$RED" "❌ Run script missing or not executable"
    exit 1
fi

# Test 3: Check ansible.cfg configuration
print_color "$CYAN" "Test 3: Checking ansible.cfg configuration..."
if grep -q "stdout_callback = dotsible_clean" ansible.cfg; then
    print_color "$GREEN" "✅ Ansible configuration updated"
else
    print_color "$RED" "❌ Ansible configuration not updated"
    exit 1
fi

# Test 4: Test dry run with clean output
print_color "$CYAN" "Test 4: Testing dry run with clean output..."
print_color "$YELLOW" "Running: ./run-dotsible.sh --dry-run --profile minimal"
echo

if ./run-dotsible.sh --dry-run --profile minimal; then
    print_color "$GREEN" "✅ Dry run completed successfully"
else
    print_color "$RED" "❌ Dry run failed"
    exit 1
fi

echo
print_color "$BOLD$GREEN" "🎉 All tests passed!"
print_color "$GREEN" "Clean output implementation is working correctly."

echo
print_color "$BOLD$YELLOW" "💡 Usage Examples:"
print_color "$YELLOW" "• Clean output (default): ./run-dotsible.sh"
print_color "$YELLOW" "• Verbose output: ./run-dotsible.sh --verbose"
print_color "$YELLOW" "• Dry run: ./run-dotsible.sh --dry-run"
print_color "$YELLOW" "• Developer profile: ./run-dotsible.sh --profile developer"
print_color "$YELLOW" "• Enterprise environment: ./run-dotsible.sh --environment enterprise"
print_color "$YELLOW" "• Specific tags: ./run-dotsible.sh --tags platform_specific"

echo
print_color "$BOLD$CYAN" "📊 Output Improvements:"
print_color "$CYAN" "• ✅ Clear status indicators (✅ INSTALLED, ❌ FAILED, ⏭️ SKIPPED, 🔄 CHANGED)"
print_color "$CYAN" "• 📊 Progress tracking with section headers"
print_color "$CYAN" "• 📋 Summary sections for each major component"
print_color "$CYAN" "• 🔇 Reduced verbose debug messages"
print_color "$CYAN" "• 🎨 Clean, readable formatting"
print_color "$CYAN" "• 🔧 Optional verbose mode for debugging"
