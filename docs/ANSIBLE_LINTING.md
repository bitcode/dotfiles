# Ansible Linting Guide for Dotsible

This comprehensive guide covers the Ansible linting standards, workflow, and best practices for the Dotsible project.

## Table of Contents

1. [Overview](#overview)
2. [Installation and Setup](#installation-and-setup)
3. [Linting Tools](#linting-tools)
4. [Usage Examples](#usage-examples)
5. [Common Linting Rules](#common-linting-rules)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

## Overview

Dotsible uses a comprehensive linting workflow to ensure code quality, consistency, and adherence to Ansible best practices. This workflow includes:

- **ansible-lint**: Primary linting tool for Ansible-specific rules
- **yamllint**: YAML syntax and formatting validation
- **pre-commit hooks**: Automated linting on git commits
- **CI/CD integration**: Continuous validation in workflows

### Benefits

- **Prevent Issues**: Catch problems like role dependency issues before they reach production
- **Consistency**: Ensure uniform code style across the project
- **Best Practices**: Enforce Ansible community standards
- **Early Detection**: Find issues during development, not deployment

## Installation and Setup

### Prerequisites

Ensure you have Python 3.8+ and pip installed:

```bash
python3 --version  # Should be 3.8+
pip3 --version
```

### Quick Setup

1. **Install dependencies**:
   ```bash
   # Install base requirements
   pip3 install -r requirements.txt
   
   # Install development tools (includes pre-commit)
   pip3 install -r requirements-dev.txt
   ```

2. **Install pre-commit hooks**:
   ```bash
   pre-commit install
   ```

3. **Verify installation**:
   ```bash
   ansible-lint --version
   pre-commit --version
   ```

### Manual Installation

If you prefer to install tools individually:

```bash
# Core linting tools
pip3 install ansible-lint>=6.0
pip3 install yamllint>=1.32
pip3 install pre-commit>=3.0

# Install pre-commit hooks
pre-commit install
```

### Development Environment Setup

For a complete development environment:

```bash
# Clone the repository
git clone <repository-url> dotsible
cd dotsible

# Install all dependencies
pip3 install -r requirements-dev.txt

# Install pre-commit hooks
pre-commit install

# Run initial validation
./scripts/lint-ansible.sh
```

## Linting Tools

### 1. Ansible Lint

Primary tool for Ansible-specific linting rules.

**Configuration**: [`.ansible-lint.yml`](../.ansible-lint.yml)

**Key Features**:
- Validates Ansible syntax and best practices
- Checks for deprecated modules and syntax
- Enforces naming conventions
- Validates variable usage

**Usage**:
```bash
# Lint entire project
ansible-lint .

# Lint specific files
ansible-lint playbooks/site.yml
ansible-lint roles/common/

# Use custom config
ansible-lint --config-file=.ansible-lint.yml
```

### 2. YAML Lint

Validates YAML syntax and formatting.

**Usage**:
```bash
# Lint all YAML files
yamllint .

# Lint specific files
yamllint playbooks/site.yml

# Custom configuration
yamllint --config-data '{extends: default, rules: {line-length: {max: 120}}}' .
```

### 3. Pre-commit Hooks

Automated linting on git commits.

**Configuration**: [`.pre-commit-config.yaml`](../.pre-commit-config.yaml)

**Included Hooks**:
- `ansible-lint`: Ansible-specific linting
- `yamllint`: YAML formatting
- `trailing-whitespace`: Remove trailing spaces
- `end-of-file-fixer`: Ensure files end with newline
- `check-yaml`: Basic YAML syntax validation
- `shellcheck`: Shell script linting
- `markdownlint`: Markdown formatting

**Usage**:
```bash
# Run on staged files
pre-commit run

# Run on all files
pre-commit run --all-files

# Run specific hook
pre-commit run ansible-lint
```

### 4. Custom Lint Script

Comprehensive linting script with detailed reporting.

**Location**: [`scripts/lint-ansible.sh`](../scripts/lint-ansible.sh)

**Features**:
- Colored output for easy reading
- Detailed error reporting
- Support for different file types
- Integration with CI/CD

## Usage Examples

### Basic Linting

```bash
# Quick lint check
./scripts/lint-ansible.sh

# Lint with verbose output
ansible-lint -v .

# Check specific role
ansible-lint roles/applications/neovim/
```

### Pre-commit Workflow

```bash
# Stage your changes
git add .

# Commit (triggers pre-commit hooks)
git commit -m "Add new role"

# If hooks fail, fix issues and retry
git add .
git commit -m "Add new role (fixed linting issues)"
```

### CI/CD Integration

```bash
# Run in CI environment
./scripts/lint-ansible.sh

# Generate parseable output for CI
ansible-lint --parseable .

# Exit with error code on failures
ansible-lint --strict .
```

### Advanced Usage

```bash
# Lint with custom rules directory
ansible-lint --rulesdir=./custom_rules .

# Skip specific rules
ansible-lint --skip-list=yaml[line-length],experimental .

# Lint only specific file types
find . -name "*.yml" -not -path "./.git/*" | xargs ansible-lint

# Generate detailed report
ansible-lint --parseable . > lint-report.txt
```

## Common Linting Rules

### Critical Rules (Must Fix)

#### 1. Syntax Errors
```yaml
# ❌ Bad: Invalid YAML syntax
- name Install package
  package:
    name: git
    state: present

# ✅ Good: Proper YAML syntax
- name: Install package
  package:
    name: git
    state: present
```

#### 2. Deprecated Modules
```yaml
# ❌ Bad: Using deprecated module
- name: Copy file
  copy:
    src: file.txt
    dest: /tmp/file.txt
    mode: 0644

# ✅ Good: Using current module syntax
- name: Copy file
  ansible.builtin.copy:
    src: file.txt
    dest: /tmp/file.txt
    mode: '0644'
```

#### 3. Variable Naming
```yaml
# ❌ Bad: Invalid variable names
- name: Set variables
  set_fact:
    my-var: "value"
    2ndvar: "value"

# ✅ Good: Valid variable names
- name: Set variables
  set_fact:
    my_var: "value"
    second_var: "value"
```

### Warning Rules (Should Fix)

#### 1. Line Length
```yaml
# ❌ Bad: Line too long
- name: This is a very long task name that exceeds the recommended line length and should be shortened for better readability
  package:
    name: git

# ✅ Good: Reasonable line length
- name: Install Git package
  package:
    name: git
```

#### 2. Task Naming
```yaml
# ❌ Bad: Generic task name
- name: Install
  package:
    name: git

# ✅ Good: Descriptive task name
- name: Install Git version control system
  package:
    name: git
```

#### 3. Handler Usage
```yaml
# ❌ Bad: Not using handlers for service restarts
- name: Update config
  template:
    src: config.j2
    dest: /etc/app/config.conf

- name: Restart service
  service:
    name: app
    state: restarted

# ✅ Good: Using handlers
- name: Update config
  template:
    src: config.j2
    dest: /etc/app/config.conf
  notify: Restart app service

# handlers/main.yml
- name: Restart app service
  service:
    name: app
    state: restarted
```

### Skipped Rules

Some rules are intentionally skipped in our configuration:

```yaml
# .ansible-lint.yml
skip_list:
  - yaml[line-length]  # We use 120 chars instead of 80
  - experimental       # Skip experimental rules
  - fqcn[action]       # Allow short module names in some cases
  - meta-no-info       # Allow minimal meta/main.yml files
```

## CI/CD Integration

### GitHub Actions

Example workflow for GitHub Actions:

```yaml
# .github/workflows/ansible-lint.yml
name: Ansible Lint

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          
      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          
      - name: Run Ansible Lint
        run: |
          ./scripts/lint-ansible.sh
          
      - name: Run pre-commit
        run: |
          pre-commit run --all-files
```

### GitLab CI

Example configuration for GitLab CI:

```yaml
# .gitlab-ci.yml
stages:
  - lint

ansible-lint:
  stage: lint
  image: python:3.11
  before_script:
    - pip install -r requirements-dev.txt
  script:
    - ./scripts/lint-ansible.sh
    - pre-commit run --all-files
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == "main"
```

### Local Development

Set up git hooks for local development:

```bash
# Install pre-commit hooks
pre-commit install

# Install commit-msg hook
pre-commit install --hook-type commit-msg

# Test hooks
pre-commit run --all-files
```

## Troubleshooting

### Common Issues

#### 1. ansible-lint not found

**Error**:
```
ansible-lint: command not found
```

**Solution**:
```bash
# Install ansible-lint
pip3 install ansible-lint

# Or install all requirements
pip3 install -r requirements.txt
```

#### 2. Configuration file not found

**Error**:
```
WARNING: Couldn't open .ansible-lint.yml
```

**Solution**:
```bash
# Ensure you're in the project root
cd /path/to/dotsible

# Verify config file exists
ls -la .ansible-lint.yml

# Run from correct directory
./scripts/lint-ansible.sh
```

#### 3. Pre-commit hooks failing

**Error**:
```
pre-commit hook failed
```

**Solution**:
```bash
# Update pre-commit hooks
pre-commit autoupdate

# Clear cache and reinstall
pre-commit clean
pre-commit install

# Run manually to see detailed errors
pre-commit run --all-files
```

#### 4. YAML syntax errors

**Error**:
```
YAML syntax error: mapping values are not allowed here
```

**Solution**:
```bash
# Check YAML syntax
yamllint problematic-file.yml

# Common fixes:
# - Check indentation (use spaces, not tabs)
# - Ensure proper quoting of strings
# - Verify list and dictionary syntax
```

#### 5. Role dependency issues

**Error**:
```
Role dependency not found
```

**Solution**:
```bash
# Install Galaxy requirements
ansible-galaxy install -r requirements.yml

# Check role paths in ansible.cfg
cat ansible.cfg

# Verify role structure
ls -la roles/
```

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Verbose ansible-lint
ansible-lint -v .

# Very verbose
ansible-lint -vv .

# Debug pre-commit
pre-commit run --verbose --all-files

# Debug specific hook
pre-commit run ansible-lint --verbose
```

### Log Analysis

Check logs for detailed information:

```bash
# View lint script output
./scripts/lint-ansible.sh 2>&1 | tee lint.log

# Check pre-commit logs
cat ~/.cache/pre-commit/pre-commit.log

# Analyze specific errors
grep -n "ERROR" lint.log
```

## Best Practices

### 1. Development Workflow

```bash
# Before starting work
git pull origin main
pre-commit autoupdate

# During development
git add .
git commit -m "Descriptive commit message"
# (pre-commit hooks run automatically)

# Before pushing
./scripts/lint-ansible.sh
git push origin feature-branch
```

### 2. Writing Lint-Friendly Code

#### Task Names
```yaml
# ✅ Good: Descriptive and specific
- name: Install Neovim text editor via package manager
  package:
    name: neovim
    state: present

# ✅ Good: Include context
- name: Configure Neovim - Copy main configuration
  copy:
    src: init.vim
    dest: "{{ ansible_env.HOME }}/.config/nvim/init.vim"
```

#### Variable Usage
```yaml
# ✅ Good: Clear variable names
vars:
  neovim_config_dir: "{{ ansible_env.HOME }}/.config/nvim"
  neovim_plugins_dir: "{{ neovim_config_dir }}/pack/plugins"

# ✅ Good: Proper quoting
- name: Create directory
  file:
    path: "{{ neovim_config_dir }}"
    state: directory
    mode: '0755'
```

#### File Organization
```
roles/
├── applications/
│   └── neovim/
│       ├── tasks/
│       │   └── main.yml          # Main task file
│       ├── handlers/
│       │   └── main.yml          # Service handlers
│       ├── vars/
│       │   └── main.yml          # Role variables
│       ├── templates/
│       │   └── init.vim.j2       # Configuration templates
│       └── meta/
│           └── main.yml          # Role metadata
```

### 3. Configuration Management

#### Keep .ansible-lint.yml Updated
```yaml
# Regular updates to rule configuration
skip_list:
  - yaml[line-length]  # Document why rules are skipped
  - experimental       # Skip until rules are stable

enable_list:
  - name[prefix]       # Enforce consistent naming
  - no-log-password    # Security best practice
```

#### Maintain Requirements Files
```bash
# Regular updates
pip-review --local --auto  # Update Python packages
ansible-galaxy install -r requirements.yml --force  # Update Galaxy roles
```

### 4. Team Collaboration

#### Shared Configuration
- Keep linting configuration in version control
- Document any custom rules or exceptions
- Use consistent tool versions across team

#### Code Reviews
- Include linting status in pull request templates
- Review linting rule changes carefully
- Document exceptions and their rationale

#### Training
- Share this documentation with team members
- Conduct regular reviews of linting practices
- Update practices based on team feedback

### 5. Continuous Improvement

#### Monitor Rule Effectiveness
```bash
# Generate linting reports
ansible-lint --parseable . > reports/lint-$(date +%Y%m%d).txt

# Track improvements over time
git log --oneline --grep="lint" --since="1 month ago"
```

#### Regular Maintenance
```bash
# Monthly maintenance tasks
pre-commit autoupdate
pip install --upgrade ansible-lint yamllint
./scripts/lint-ansible.sh --all-files
```

## Integration with Development Tools

### VS Code Integration

Install recommended extensions:

```json
// .vscode/extensions.json
{
  "recommendations": [
    "redhat.ansible",
    "redhat.vscode-yaml",
    "ms-python.python",
    "ms-python.flake8",
    "davidanson.vscode-markdownlint"
  ]
}
```

Configure settings:

```json
// .vscode/settings.json
{
  "ansible.validation.enabled": true,
  "ansible.validation.lint.enabled": true,
  "ansible.validation.lint.path": "ansible-lint",
  "yaml.validate": true,
  "yaml.format.enable": true
}
```

### Vim/Neovim Integration

Add to your configuration:

```vim
" Install ALE for linting
Plug 'dense-analysis/ale'

" Configure linters
let g:ale_linters = {
\   'yaml': ['yamllint', 'ansible-lint'],
\   'ansible': ['ansible-lint'],
\}

" Auto-fix on save
let g:ale_fix_on_save = 1
```

---

## Getting Help

### Documentation
- [Ansible Lint Documentation](https://ansible-lint.readthedocs.io/)
- [YAML Lint Documentation](https://yamllint.readthedocs.io/)
- [Pre-commit Documentation](https://pre-commit.com/)

### Support Channels
- **Issues**: Create GitHub issues for bugs or questions
- **Discussions**: Use GitHub discussions for general questions
- **Team Chat**: Internal team communication channels

### Contributing
- Report false positives or suggest rule improvements
- Contribute to documentation and examples
- Share best practices with the community

---

**Happy Linting!** 🎉

*This guide is part of the Dotsible project documentation. For more information, see the main [README](../README.md) and [USAGE](USAGE.md) guides.*