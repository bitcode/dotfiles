# Dotsible Testing Guide

This guide covers all aspects of testing Dotsible, from basic syntax validation to comprehensive integration testing across multiple platforms.

## Table of Contents

1. [Testing Overview](#testing-overview)
2. [Test Types](#test-types)
3. [Running Tests](#running-tests)
4. [Test Framework](#test-framework)
5. [Writing Tests](#writing-tests)
6. [Continuous Integration](#continuous-integration)
7. [Troubleshooting Tests](#troubleshooting-tests)

## Testing Overview

Dotsible includes a comprehensive testing framework that validates:

- **Syntax**: YAML and Ansible playbook syntax
- **Functionality**: Individual role and application functionality
- **Integration**: Cross-platform and cross-role compatibility
- **Performance**: Execution time and resource usage
- **Security**: Configuration security and best practices

### Test Structure

```
tests/
├── README.md                    # Testing documentation
├── inventories/                 # Test inventory files
│   ├── test.yml                # Local testing inventory
│   └── multiplatform.yml       # Cross-platform testing
├── playbooks/                  # Test playbooks
├── roles/                      # Role-specific tests
│   ├── test-git.yml           # Git role tests
│   ├── test-zsh.yml           # ZSH role tests
│   └── test-*.yml             # Other role tests
├── integration/                # Integration tests
│   ├── cross-platform.yml     # Cross-platform tests
│   └── test_application_compatibility.yml
├── validation/                 # Syntax and validation tests
│   ├── syntax-check.yml       # Comprehensive syntax validation
│   └── validation_report.j2   # Validation report template
└── scripts/                   # Test automation scripts
    ├── run_all_tests.sh       # Main test runner
    ├── validate_syntax.sh     # Syntax validation script
    └── run_integration_tests.sh
```

## Test Types

### 1. Syntax Validation Tests

Validate YAML syntax and Ansible playbook structure:

```bash
# Quick syntax check
./tests/scripts/validate_syntax.sh

# Comprehensive syntax validation
ansible-playbook -i tests/inventories/test.yml tests/validation/syntax-check.yml
```

**What it checks:**
- YAML file syntax
- Ansible playbook syntax
- Inventory file validity
- Template syntax
- Variable file structure

### 2. Role-Specific Tests

Test individual role functionality:

```bash
# Test Git role
ansible-playbook -i tests/inventories/test.yml tests/roles/test-git.yml

# Test ZSH role
ansible-playbook -i tests/inventories/test.yml tests/roles/test-zsh.yml

# Test all roles
for test in tests/roles/test-*.yml; do
    ansible-playbook -i tests/inventories/test.yml "$test"
done
```

**What it tests:**
- Application installation
- Configuration generation
- Service management
- Functionality verification

### 3. Integration Tests

Test cross-platform and cross-role compatibility:

```bash
# Cross-platform integration
ansible-playbook -i tests/inventories/multiplatform.yml tests/integration/cross-platform.yml

# Profile integration
ansible-playbook -i tests/inventories/test.yml site.yml -e profile=developer --check
```

**What it tests:**
- Cross-platform compatibility
- Role interactions
- Profile functionality
- System integration

### 4. Performance Tests

Measure execution time and resource usage:

```bash
# Time execution
time ansible-playbook -i tests/inventories/test.yml site.yml

# Profile with callback plugins
ANSIBLE_STDOUT_CALLBACK=profile_tasks ansible-playbook -i tests/inventories/test.yml site.yml
```

### 5. Security Tests

Validate security configurations:

```bash
# Check for security issues
ansible-playbook -i tests/inventories/test.yml tests/security/security-audit.yml
```

## Running Tests

### Quick Test Suite

```bash
# Run all tests
./tests/scripts/run_all_tests.sh

# Run specific test categories
./tests/scripts/run_all_tests.sh --syntax-only
./tests/scripts/run_all_tests.sh --roles-only
./tests/scripts/run_all_tests.sh --integration
```

### Individual Test Execution

```bash
# Syntax validation only
./tests/scripts/validate_syntax.sh

# Specific role test
ansible-playbook -i tests/inventories/test.yml tests/roles/test-git.yml

# Integration test
ansible-playbook -i tests/inventories/test.yml tests/integration/cross-platform.yml

# Full playbook test (dry run)
ansible-playbook -i tests/inventories/test.yml site.yml --check --diff
```

### Test Options and Flags

```bash
# Verbose output
ansible-playbook -i tests/inventories/test.yml tests/roles/test-git.yml -vvv

# Check mode (dry run)
ansible-playbook -i tests/inventories/test.yml site.yml --check

# Diff mode (show changes)
ansible-playbook -i tests/inventories/test.yml site.yml --diff

# Specific tags
ansible-playbook -i tests/inventories/test.yml site.yml --tags=git,vim

# Skip tags
ansible-playbook -i tests/inventories/test.yml site.yml --skip-tags=dotfiles

# Limit to specific hosts
ansible-playbook -i tests/inventories/multiplatform.yml tests/integration/cross-platform.yml --limit=ubuntu-test
```

## Test Framework

### Test Inventory Configuration

```yaml
# tests/inventories/test.yml
---
all:
  hosts:
    localhost:
      ansible_connection: local
      ansible_python_interpreter: "{{ ansible_playbook_python }}"
  vars:
    # Test-specific variables
    test_mode: true
    skip_interactive: true
    dry_run: false
    backup_existing: true
    force_install: false
    cleanup_temp_files: true
    
    # Application verification commands
    application_verification:
      - name: git
        command: git --version
        expected_pattern: "git version"
      - name: vim
        command: vim --version
        expected_pattern: "VIM"
```

### Test Result Validation

Tests use Ansible's built-in assertion and verification mechanisms:

```yaml
# Example test validation
- name: Verify application installation
  command: "{{ app_command }}"
  register: app_result
  changed_when: false
  failed_when: app_result.rc != 0

- name: Assert expected output
  assert:
    that:
      - "'expected_string' in app_result.stdout"
    fail_msg: "Application test failed"
    success_msg: "Application test passed"
```

### Test Reporting

Tests generate comprehensive reports:

```bash
# View test results
cat tests/logs/test_run_YYYYMMDD_HHMMSS.log

# View validation report
cat validation_report.txt

# View integration report
cat ~/.dotsible_integration_report
```

## Writing Tests

### Creating Role Tests

1. **Create test file structure:**

```bash
# Create role test file
touch tests/roles/test-myapp.yml
```

2. **Write comprehensive test:**

```yaml
# tests/roles/test-myapp.yml
---
- name: Test MyApp Role Functionality
  hosts: all
  gather_facts: yes
  become: no
  
  vars:
    test_myapp_config:
      setting1: test_value1
      setting2: test_value2
  
  pre_tasks:
    - name: Display test information
      debug:
        msg: |
          Testing MyApp role on {{ ansible_distribution }} {{ ansible_distribution_version }}
          Test mode: {{ test_mode | default(false) }}
  
  tasks:
    - name: Include myapp role
      include_role:
        name: applications/myapp
      vars:
        myapp_config: "{{ test_myapp_config }}"
    
    - name: Verify myapp installation
      command: myapp --version
      register: myapp_version_result
      changed_when: false
      failed_when: myapp_version_result.rc != 0
    
    - name: Check myapp configuration
      stat:
        path: "{{ ansible_env.HOME }}/.myapp/config"
      register: myapp_config_check
    
    - name: Verify configuration exists
      assert:
        that:
          - myapp_config_check.stat.exists
        fail_msg: "MyApp configuration not found"
        success_msg: "MyApp configuration verified"
    
    - name: Test myapp functionality
      block:
        - name: Run myapp test command
          command: myapp --test
          register: myapp_test_result
          changed_when: false
        
        - name: Verify test output
          assert:
            that:
              - "'success' in myapp_test_result.stdout.lower()"
            fail_msg: "MyApp functionality test failed"
            success_msg: "MyApp functionality test passed"
      
      rescue:
        - name: Handle test failure
          debug:
            msg: "MyApp functionality test failed, but continuing..."
  
  post_tasks:
    - name: MyApp test summary
      debug:
        msg: |
          MyApp Role Test Results:
          =====================
          Version: {{ myapp_version_result.stdout }}
          Configuration: ✓ Verified
          Functionality: ✓ Verified
          
          All MyApp tests passed successfully!
```

### Creating Integration Tests

```yaml
# tests/integration/test-profile-integration.yml
---
- name: Profile Integration Tests
  hosts: all
  gather_facts: yes
  
  vars:
    test_profiles:
      - minimal
      - developer
      - server
  
  tasks:
    - name: Test each profile
      include_tasks: test_profile.yml
      loop: "{{ test_profiles }}"
      loop_control:
        loop_var: profile_name
```

```yaml
# tests/integration/test_profile.yml
---
- name: "Test {{ profile_name }} profile"
  block:
    - name: "Run {{ profile_name }} profile in check mode"
      command: >
        ansible-playbook -i tests/inventories/test.yml site.yml 
        -e profile={{ profile_name }} --check
      register: profile_test_result
      changed_when: false
      failed_when: profile_test_result.rc != 0
    
    - name: "Record {{ profile_name }} test result"
      set_fact:
        profile_test_results: "{{ profile_test_results | default([]) + [test_result] }}"
      vars:
        test_result:
          profile: "{{ profile_name }}"
          status: "{{ 'pass' if profile_test_result.rc == 0 else 'fail' }}"
          output: "{{ profile_test_result.stdout }}"
```

### Test Best Practices

1. **Use descriptive test names:**
```yaml
- name: Verify Git configuration is properly applied
  # vs
- name: Check git
```

2. **Test both positive and negative cases:**
```yaml
- name: Verify application works with valid config
  command: myapp --config valid.conf
  register: valid_result
  failed_when: valid_result.rc != 0

- name: Verify application fails with invalid config
  command: myapp --config invalid.conf
  register: invalid_result
  failed_when: invalid_result.rc == 0
```

3. **Use proper error handling:**
```yaml
- name: Test potentially failing operation
  block:
    - name: Attempt operation
      command: risky_command
      register: risky_result
  rescue:
    - name: Handle expected failure
      debug:
        msg: "Operation failed as expected"
  always:
    - name: Cleanup
      file:
        path: /tmp/test_file
        state: absent
```

4. **Validate test environment:**
```yaml
- name: Ensure test prerequisites
  assert:
    that:
      - test_mode is defined
      - test_mode == true
    fail_msg: "Tests must be run in test mode"
```

### Mock and Stub Testing

For testing without actual installation:

```yaml
# Mock package installation
- name: Mock package installation
  debug:
    msg: "Would install package: {{ package_name }}"
  when: test_mode | default(false)

- name: Actual package installation
  package:
    name: "{{ package_name }}"
    state: present
  when: not (test_mode | default(false))
```

## Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Dotsible Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  syntax-validation:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install Ansible
        run: |
          python -m pip install --upgrade pip
          pip install ansible
      
      - name: Run syntax validation
        run: ./tests/scripts/validate_syntax.sh

  role-tests:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
        profile: [minimal, developer]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          ansible-galaxy install -r requirements.yml
      
      - name: Run role tests
        run: |
          ./tests/scripts/run_all_tests.sh --roles-only
      
      - name: Test profile integration
        run: |
          ansible-playbook -i tests/inventories/test.yml site.yml \
            -e profile=${{ matrix.profile }} --check

  integration-tests:
    runs-on: ubuntu-latest
    needs: [syntax-validation, role-tests]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          ansible-galaxy install -r requirements.yml
      
      - name: Run integration tests
        run: ./tests/scripts/run_all_tests.sh --integration
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: tests/logs/
```

### Local CI with Docker

```dockerfile
# Dockerfile.test
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    ansible \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /dotsible
COPY . .

RUN pip3 install -r requirements.txt
RUN ansible-galaxy install -r requirements.yml

CMD ["./tests/scripts/run_all_tests.sh"]
```

```bash
# Build and run tests in Docker
docker build -f Dockerfile.test -t dotsible-test .
docker run --rm dotsible-test
```

## Troubleshooting Tests

### Common Test Issues

#### 1. Permission Errors

```bash
# Error: Permission denied during tests
# Solution: Ensure test user has proper permissions
sudo chown -R $USER:$USER ~/.dotsible
chmod -R 755 ~/.dotsible
```

#### 2. Package Installation Failures

```bash
# Error: Package not found during tests
# Solution: Update package cache or use test mode
export TEST_MODE=true
ansible-playbook -i tests/inventories/test.yml tests/roles/test-git.yml
```

#### 3. SSH Connection Issues in Multi-Host Tests

```bash
# Error: SSH connection failed
# Solution: Set up SSH keys or use local connection
ansible-playbook -i tests/inventories/test.yml tests/integration/cross-platform.yml \
  -e ansible_connection=local
```

#### 4. Test Environment Conflicts

```bash
# Error: Tests interfere with existing configuration
# Solution: Use isolated test environment
export TEST_MODE=true
export BACKUP_EXISTING=true
./tests/scripts/run_all_tests.sh
```

### Debug Test Execution

```bash
# Enable debug output
export ANSIBLE_DEBUG=true
ansible-playbook -i tests/inventories/test.yml tests/roles/test-git.yml -vvv

# Check test logs
tail -f tests/logs/test_run_*.log

# Validate test inventory
ansible-inventory -i tests/inventories/test.yml --list

# Test connectivity
ansible all -i tests/inventories/test.yml -m ping
```

### Test Performance Analysis

```bash
# Profile task execution time
ANSIBLE_STDOUT_CALLBACK=profile_tasks \
ansible-playbook -i tests/inventories/test.yml site.yml

# Memory usage monitoring
/usr/bin/time -v ansible-playbook -i tests/inventories/test.yml site.yml

# Detailed timing
ansible-playbook -i tests/inventories/test.yml site.yml \
  --start-at-task="Install Git" -vvv
```

## Test Maintenance

### Regular Test Updates

1. **Update test data regularly:**
```bash
# Update package lists
./scripts/update_test_data.sh

# Refresh test inventories
./scripts/refresh_test_inventories.sh
```

2. **Review and update test cases:**
```bash
# Check for deprecated test patterns
grep -r "include:" tests/
grep -r "sudo:" tests/
```

3. **Validate test coverage:**
```bash
# Ensure all roles have tests
for role in roles/applications/*; do
    role_name=$(basename "$role")
    if [ ! -f "tests/roles/test-$role_name.yml" ]; then
        echo "Missing test for role: $role_name"
    fi
done
```

### Test Documentation

Keep test documentation updated:

1. **Document test procedures**
2. **Update test examples**
3. **Maintain troubleshooting guides**
4. **Document test environment requirements**

---

## Test Checklist

Before submitting changes, ensure:

- [ ] All syntax validation tests pass
- [ ] Role-specific tests pass
- [ ] Integration tests pass
- [ ] Tests run on multiple platforms
- [ ] New features have corresponding tests
- [ ] Test documentation is updated
- [ ] Performance impact is acceptable
- [ ] Security tests pass (if applicable)

**Happy Testing!** 🧪

For more information, see:
- [USAGE.md](USAGE.md) - Detailed usage guide
- [EXTENDING.md](EXTENDING.md) - Adding new functionality
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions