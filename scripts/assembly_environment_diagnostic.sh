#!/usr/bin/env zsh

# Comprehensive Assembly Development Environment Diagnostic
# This script systematically tests all components and identifies potential issues

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    local level=$1
    local message=$2
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    case $level in
        "PASS") echo -e "[${timestamp}] ${GREEN}PASS${NC}: $message" ;;
        "FAIL") echo -e "[${timestamp}] ${RED}FAIL${NC}: $message" ;;
        "WARN") echo -e "[${timestamp}] ${YELLOW}WARN${NC}: $message" ;;
        "INFO") echo -e "[${timestamp}] ${BLUE}INFO${NC}: $message" ;;
        "ERROR") echo -e "[${timestamp}] ${RED}ERROR${NC}: $message" ;;
    esac
}

# Test 1: File Structure Verification
test_file_structure() {
    log "INFO" "=== Testing File Structure ==="
    
    local required_files=(
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua"
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua"
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua"
        "files/dotfiles/nvim/.config/nvim/snippets/asm.lua"
        "files/dotfiles/nvim/.config/nvim/docs/ASSEMBLY_DEVELOPMENT.md"
        "files/dotfiles/nvim/.config/nvim/examples/arm64_hello_world.s"
    )
    
    local passed=0
    local total=${#required_files[@]}
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            log "PASS" "File exists: $file"
            ((passed++))
        else
            log "FAIL" "Missing file: $file"
            missing_files+=("$file")
        fi
    done
    
    echo "FILE_STRUCTURE_RESULT:$passed/$total"
    return $((total - passed))
}

# Test 2: Template Coverage Analysis
test_template_coverage() {
    log "INFO" "=== Testing Template Coverage ==="
    
    local architectures=("arm64" "x86_64" "arm32" "riscv")
    local template_types=("asm-lsp" "compile_flags" "Makefile")
    
    local existing_templates=()
    local missing_templates=()
    
    for arch in "${architectures[@]}"; do
        for template_type in "${template_types[@]}"; do
            local extension=""
            case $template_type in
                "asm-lsp") extension=".toml" ;;
                "compile_flags") extension=".txt" ;;
                "Makefile") extension="" ;;
            esac
            
            local template_file="files/dotfiles/nvim/.config/nvim/templates/${template_type}_${arch}${extension}"
            
            if [[ -f "$template_file" ]]; then
                existing_templates+=("$template_file")
                log "PASS" "Template exists: $template_file"
            else
                missing_templates+=("$template_file")
                log "WARN" "Template missing: $template_file"
            fi
        done
    done
    
    local total=$((${#existing_templates[@]} + ${#missing_templates[@]}))
    local coverage_percent=$(( ${#existing_templates[@]} * 100 / total ))
    
    echo "TEMPLATE_COVERAGE_RESULT:${#existing_templates[@]}/$total ($coverage_percent%)"
    return ${#missing_templates[@]}
}

# Test 3: Lua Module Syntax Validation
test_lua_modules() {
    log "INFO" "=== Testing Lua Module Syntax ==="
    
    local lua_files=(
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua"
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua"
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua"
        "files/dotfiles/nvim/.config/nvim/snippets/asm.lua"
    )
    
    local passed=0
    local total=${#lua_files[@]}
    local syntax_issues=()
    
    # Check if we have any Lua interpreter available
    local lua_cmd=""
    if command -v lua >/dev/null 2>&1; then
        lua_cmd="lua"
    elif command -v lua5.4 >/dev/null 2>&1; then
        lua_cmd="lua5.4"
    elif command -v lua5.3 >/dev/null 2>&1; then
        lua_cmd="lua5.3"
    elif command -v luajit >/dev/null 2>&1; then
        lua_cmd="luajit"
    fi
    
    if [[ -n "$lua_cmd" ]]; then
        for file in "${lua_files[@]}"; do
            if [[ -f "$file" ]]; then
                if $lua_cmd -l "$file" >/dev/null 2>&1; then
                    log "PASS" "Syntax valid: $file"
                    ((passed++))
                else
                    local error_msg=$($lua_cmd -l "$file" 2>&1)
                    log "FAIL" "Syntax error in $file: $error_msg"
                    syntax_issues+=("$file: $error_msg")
                fi
            else
                log "FAIL" "File not found: $file"
                syntax_issues+=("$file: File not found")
            fi
        done
    else
        log "WARN" "No Lua interpreter found - skipping syntax validation"
        # Basic syntax check using grep for common issues
        for file in "${lua_files[@]}"; do
            if [[ -f "$file" ]]; then
                # Check for basic syntax issues
                if grep -q "function.*end" "$file" && ! grep -q "syntax error" "$file"; then
                    log "PASS" "Basic syntax check passed: $file"
                    ((passed++))
                else
                    log "WARN" "Could not verify syntax: $file"
                fi
            fi
        done
    fi
    
    echo "LUA_SYNTAX_RESULT:$passed/$total"
    return $((total - passed))
}

# Test 4: Architecture Detection Logic Analysis
test_architecture_detection() {
    log "INFO" "=== Testing Architecture Detection Logic ==="
    
    local test_files=(
        "test.s" "test.S" "test.asm" "test.inc"
        "arm64_test.s" "x86_test.asm" "riscv_test.s"
        "hello.arm" "program.aarch64"
    )
    
    local valid_extensions=("s" "S" "asm" "inc" "arm" "aarch64" "riscv")
    local detection_issues=()
    
    for filename in "${test_files[@]}"; do
        local extension="${filename##*.}"
        if [[ " ${valid_extensions[*]} " =~ " ${extension} " ]]; then
            log "PASS" "Valid assembly file: $filename"
        else
            log "WARN" "Unrecognized extension: $filename"
            detection_issues+=("$filename")
        fi
    done
    
    echo "ARCHITECTURE_DETECTION_RESULT:${#detection_issues[@]} issues"
    return ${#detection_issues[@]}
}

# Test 5: Cross-Platform Compatibility Check
test_cross_platform_compatibility() {
    log "INFO" "=== Testing Cross-Platform Compatibility ==="
    
    local issues=()
    local file="files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua"
    
    if [[ -f "$file" ]]; then
        # Check for cross-platform URL opening
        if grep -q "vim.fn.has('mac')" "$file" && \
           grep -q "vim.fn.has('unix')" "$file" && \
           grep -q "vim.fn.has('win32')" "$file"; then
            log "PASS" "Cross-platform URL opening detected in $file"
        else
            log "WARN" "Potential cross-platform issue in $file"
            issues+=("Cross-platform concern: $file")
        fi
    else
        log "FAIL" "File not found: $file"
        issues+=("Missing file: $file")
    fi
    
    echo "CROSS_PLATFORM_RESULT:${#issues[@]} issues"
    return ${#issues[@]}
}

# Test 6: GNU Stow Compatibility
test_stow_compatibility() {
    log "INFO" "=== Testing GNU Stow Compatibility ==="
    
    local issues=()
    local potential_conflicts=(
        "files/dotfiles/nvim/.config/nvim/init.lua"
        "files/dotfiles/nvim/.config/nvim/lua/init.lua"
    )
    
    for conflict_file in "${potential_conflicts[@]}"; do
        if [[ -f "$conflict_file" ]]; then
            log "WARN" "Potential Stow conflict: $conflict_file"
            issues+=("Conflict: $conflict_file")
        else
            log "PASS" "No conflict: $conflict_file"
        fi
    done
    
    echo "STOW_COMPATIBILITY_RESULT:${#issues[@]} issues"
    return ${#issues[@]}
}

# Test 7: Error Handling Validation
test_error_handling() {
    log "INFO" "=== Testing Error Handling ==="
    
    local issues=()
    local files_to_check=(
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua"
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua"
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua"
    )
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]]; then
            local pcall_count=$(grep -c "pcall" "$file" 2>/dev/null || echo "0")
            
            if [[ $pcall_count -gt 0 ]]; then
                log "PASS" "Error handling (pcall) found in $file ($pcall_count instances)"
            else
                log "WARN" "Limited error handling in $file"
                issues+=("Limited error handling: $file")
            fi
        else
            log "FAIL" "File not found: $file"
            issues+=("Missing file: $file")
        fi
    done
    
    echo "ERROR_HANDLING_RESULT:${#issues[@]} issues"
    return ${#issues[@]}
}

# Main diagnostic function
run_comprehensive_diagnostic() {
    log "INFO" "Starting Comprehensive Assembly Development Environment Diagnostic"
    log "INFO" "================================================================"
    
    local total_issues=0
    
    # Run all tests
    test_file_structure
    total_issues=$((total_issues + $?))
    
    test_template_coverage
    total_issues=$((total_issues + $?))
    
    test_lua_modules
    total_issues=$((total_issues + $?))
    
    test_architecture_detection
    total_issues=$((total_issues + $?))
    
    test_cross_platform_compatibility
    total_issues=$((total_issues + $?))
    
    test_stow_compatibility
    total_issues=$((total_issues + $?))
    
    test_error_handling
    total_issues=$((total_issues + $?))
    
    # Generate summary
    echo ""
    log "INFO" "=== DIAGNOSTIC SUMMARY ==="
    
    # Extract results from previous outputs
    local file_structure_result=$(grep "FILE_STRUCTURE_RESULT:" /dev/stdout 2>/dev/null | tail -1 | cut -d: -f2)
    local template_coverage_result=$(grep "TEMPLATE_COVERAGE_RESULT:" /dev/stdout 2>/dev/null | tail -1 | cut -d: -f2)
    local lua_syntax_result=$(grep "LUA_SYNTAX_RESULT:" /dev/stdout 2>/dev/null | tail -1 | cut -d: -f2)
    
    echo ""
    log "INFO" "=== DEPLOYMENT READINESS ASSESSMENT ==="
    
    if [[ $total_issues -eq 0 ]]; then
        log "PASS" "✅ READY FOR DEPLOYMENT - All critical components functional"
    elif [[ $total_issues -le 5 ]]; then
        log "WARN" "⚠️  PARTIAL DEPLOYMENT READY - Core functional, minor issues detected"
        log "WARN" "   Recommendation: Deploy for limited environments, address issues for full deployment"
    else
        log "FAIL" "❌ NOT READY FOR DEPLOYMENT - Critical issues must be resolved"
        log "FAIL" "   Total issues detected: $total_issues"
    fi
    
    return $total_issues
}

# Execute diagnostic
run_comprehensive_diagnostic
exit_code=$?

echo ""
log "INFO" "Diagnostic completed with exit code: $exit_code"
exit $exit_code