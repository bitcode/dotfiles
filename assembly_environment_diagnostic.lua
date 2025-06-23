#!/usr/bin/env lua

-- Comprehensive Assembly Development Environment Diagnostic
-- This script systematically tests all components and identifies potential issues

local function log(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    print(string.format("[%s] %s: %s", timestamp, level, message))
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function test_lua_syntax(file_path)
    if not file_exists(file_path) then
        return false, "File does not exist"
    end
    
    local chunk, err = loadfile(file_path)
    if chunk then
        return true, "Syntax valid"
    else
        return false, err or "Unknown syntax error"
    end
end

-- Test 1: File Structure Verification
local function test_file_structure()
    log("INFO", "=== Testing File Structure ===")
    
    local required_files = {
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua",
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua", 
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua",
        "files/dotfiles/nvim/.config/nvim/snippets/asm.lua",
        "files/dotfiles/nvim/.config/nvim/docs/ASSEMBLY_DEVELOPMENT.md",
        "files/dotfiles/nvim/.config/nvim/examples/arm64_hello_world.s"
    }
    
    local issues = {}
    local passed = 0
    
    for _, file in ipairs(required_files) do
        if file_exists(file) then
            log("PASS", "File exists: " .. file)
            passed = passed + 1
        else
            log("FAIL", "Missing file: " .. file)
            table.insert(issues, "Missing: " .. file)
        end
    end
    
    return {
        total = #required_files,
        passed = passed,
        issues = issues
    }
end

-- Test 2: Template Coverage Analysis
local function test_template_coverage()
    log("INFO", "=== Testing Template Coverage ===")
    
    local architectures = {"arm64", "x86_64", "arm32", "riscv"}
    local template_types = {"asm-lsp", "compile_flags", "Makefile"}
    
    local missing_templates = {}
    local existing_templates = {}
    
    for _, arch in ipairs(architectures) do
        for _, template_type in ipairs(template_types) do
            local extension = ""
            if template_type == "asm-lsp" then
                extension = ".toml"
            elseif template_type == "compile_flags" then
                extension = ".txt"
            end
            
            local template_file = string.format("files/dotfiles/nvim/.config/nvim/templates/%s_%s%s", 
                                               template_type, arch, extension)
            
            if file_exists(template_file) then
                table.insert(existing_templates, template_file)
                log("PASS", "Template exists: " .. template_file)
            else
                table.insert(missing_templates, template_file)
                log("WARN", "Template missing: " .. template_file)
            end
        end
    end
    
    return {
        existing = existing_templates,
        missing = missing_templates,
        coverage_percent = (#existing_templates / (#existing_templates + #missing_templates)) * 100
    }
end

-- Test 3: Lua Module Syntax Validation
local function test_lua_modules()
    log("INFO", "=== Testing Lua Module Syntax ===")
    
    local lua_files = {
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua",
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua",
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua",
        "files/dotfiles/nvim/.config/nvim/snippets/asm.lua"
    }
    
    local syntax_issues = {}
    local passed = 0
    
    for _, file in ipairs(lua_files) do
        local valid, error_msg = test_lua_syntax(file)
        if valid then
            log("PASS", "Syntax valid: " .. file)
            passed = passed + 1
        else
            log("FAIL", "Syntax error in " .. file .. ": " .. error_msg)
            table.insert(syntax_issues, {file = file, error = error_msg})
        end
    end
    
    return {
        total = #lua_files,
        passed = passed,
        issues = syntax_issues
    }
end

-- Test 4: Architecture Detection Logic Analysis
local function test_architecture_detection()
    log("INFO", "=== Testing Architecture Detection Logic ===")
    
    -- Test file extension detection patterns
    local test_files = {
        "test.s",
        "test.S", 
        "test.asm",
        "test.inc",
        "arm64_test.s",
        "x86_test.asm",
        "riscv_test.s",
        "hello.arm",
        "program.aarch64"
    }
    
    local detection_issues = {}
    
    -- This is a simplified test - in real implementation, we'd need to load the actual module
    for _, filename in ipairs(test_files) do
        local extension = filename:match("%.([^%.]+)$")
        local valid_extensions = {s = true, S = true, asm = true, inc = true, arm = true, aarch64 = true, riscv = true}
        
        if valid_extensions[extension] then
            log("PASS", "Valid assembly file: " .. filename)
        else
            log("WARN", "Unrecognized extension: " .. filename)
            table.insert(detection_issues, "Unrecognized: " .. filename)
        end
    end
    
    return {
        issues = detection_issues
    }
end

-- Test 5: Cross-Platform Compatibility Check
local function test_cross_platform_compatibility()
    log("INFO", "=== Testing Cross-Platform Compatibility ===")
    
    local issues = {}
    
    -- Check for hardcoded paths or platform-specific code
    local files_to_check = {
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua"
    }
    
    for _, file in ipairs(files_to_check) do
        if file_exists(file) then
            local f = io.open(file, "r")
            if f then
                local content = f:read("*all")
                f:close()
                
                -- Check for cross-platform URL opening
                if content:match("vim%.fn%.has%('mac'%)") and 
                   content:match("vim%.fn%.has%('unix'%)") and 
                   content:match("vim%.fn%.has%('win32'%)") then
                    log("PASS", "Cross-platform URL opening detected in " .. file)
                else
                    log("WARN", "Potential cross-platform issue in " .. file)
                    table.insert(issues, "Cross-platform concern: " .. file)
                end
            end
        end
    end
    
    return {
        issues = issues
    }
end

-- Test 6: GNU Stow Compatibility
local function test_stow_compatibility()
    log("INFO", "=== Testing GNU Stow Compatibility ===")
    
    local issues = {}
    
    -- Check directory structure
    local base_path = "files/dotfiles/nvim/.config/nvim/"
    
    -- Verify no conflicting files
    local potential_conflicts = {
        "files/dotfiles/nvim/.config/nvim/init.lua",
        "files/dotfiles/nvim/.config/nvim/lua/init.lua"
    }
    
    for _, conflict_file in ipairs(potential_conflicts) do
        if file_exists(conflict_file) then
            log("WARN", "Potential Stow conflict: " .. conflict_file)
            table.insert(issues, "Conflict: " .. conflict_file)
        else
            log("PASS", "No conflict: " .. conflict_file)
        end
    end
    
    return {
        issues = issues
    }
end

-- Test 7: Error Handling Validation
local function test_error_handling()
    log("INFO", "=== Testing Error Handling ===")
    
    local issues = {}
    
    -- Check for proper error handling patterns in Lua files
    local files_to_check = {
        "files/dotfiles/nvim/.config/nvim/lua/plugins/asm_lsp.lua",
        "files/dotfiles/nvim/.config/nvim/lua/custom_arm_docs.lua",
        "files/dotfiles/nvim/.config/nvim/lua/asm_utils.lua"
    }
    
    for _, file in ipairs(files_to_check) do
        if file_exists(file) then
            local f = io.open(file, "r")
            if f then
                local content = f:read("*all")
                f:close()
                
                -- Check for pcall usage (protected calls)
                local pcall_count = 0
                for _ in content:gmatch("pcall") do
                    pcall_count = pcall_count + 1
                end
                
                if pcall_count > 0 then
                    log("PASS", "Error handling (pcall) found in " .. file .. " (" .. pcall_count .. " instances)")
                else
                    log("WARN", "Limited error handling in " .. file)
                    table.insert(issues, "Limited error handling: " .. file)
                end
            end
        end
    end
    
    return {
        issues = issues
    }
end

-- Main diagnostic function
local function run_comprehensive_diagnostic()
    log("INFO", "Starting Comprehensive Assembly Development Environment Diagnostic")
    log("INFO", "================================================================")
    
    local results = {
        file_structure = test_file_structure(),
        template_coverage = test_template_coverage(),
        lua_modules = test_lua_modules(),
        architecture_detection = test_architecture_detection(),
        cross_platform = test_cross_platform_compatibility(),
        stow_compatibility = test_stow_compatibility(),
        error_handling = test_error_handling()
    }
    
    -- Generate comprehensive report
    log("INFO", "")
    log("INFO", "=== DIAGNOSTIC SUMMARY ===")
    
    -- File Structure Summary
    log("INFO", string.format("File Structure: %d/%d files present (%.1f%%)", 
                             results.file_structure.passed, 
                             results.file_structure.total,
                             (results.file_structure.passed / results.file_structure.total) * 100))
    
    -- Template Coverage Summary
    log("INFO", string.format("Template Coverage: %.1f%% (%d existing, %d missing)", 
                             results.template_coverage.coverage_percent,
                             #results.template_coverage.existing,
                             #results.template_coverage.missing))
    
    -- Lua Module Syntax Summary
    log("INFO", string.format("Lua Syntax: %d/%d modules valid (%.1f%%)", 
                             results.lua_modules.passed,
                             results.lua_modules.total,
                             (results.lua_modules.passed / results.lua_modules.total) * 100))
    
    -- Critical Issues Summary
    local critical_issues = 0
    critical_issues = critical_issues + #results.file_structure.issues
    critical_issues = critical_issues + #results.lua_modules.issues
    critical_issues = critical_issues + #results.template_coverage.missing
    
    log("INFO", "")
    log("INFO", "=== CRITICAL ISSUES IDENTIFIED ===")
    
    if #results.file_structure.issues > 0 then
        log("ERROR", "Missing Core Files:")
        for _, issue in ipairs(results.file_structure.issues) do
            log("ERROR", "  - " .. issue)
        end
    end
    
    if #results.lua_modules.issues > 0 then
        log("ERROR", "Lua Syntax Errors:")
        for _, issue in ipairs(results.lua_modules.issues) do
            log("ERROR", "  - " .. issue.file .. ": " .. issue.error)
        end
    end
    
    if #results.template_coverage.missing > 0 then
        log("WARN", "Missing Templates (Multi-Architecture Support Incomplete):")
        for _, template in ipairs(results.template_coverage.missing) do
            log("WARN", "  - " .. template)
        end
    end
    
    -- Deployment Readiness Assessment
    log("INFO", "")
    log("INFO", "=== DEPLOYMENT READINESS ASSESSMENT ===")
    
    if critical_issues == 0 then
        log("PASS", "✅ READY FOR DEPLOYMENT - All critical components functional")
    elseif #results.lua_modules.issues == 0 and #results.file_structure.issues == 0 then
        log("WARN", "⚠️  PARTIAL DEPLOYMENT READY - Core functional, missing multi-arch templates")
        log("WARN", "   Recommendation: Deploy for ARM64-only environments")
    else
        log("FAIL", "❌ NOT READY FOR DEPLOYMENT - Critical issues must be resolved")
    end
    
    return results
end

-- Execute diagnostic
return run_comprehensive_diagnostic()