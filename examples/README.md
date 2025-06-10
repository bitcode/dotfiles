# Dotsible Configuration Examples

This directory contains advanced configuration examples and templates for various use cases and environments.

## Directory Structure

```
examples/
├── README.md                    # This file
├── configurations/             # Complete configuration examples
│   ├── developer-workstation/  # Developer workstation setup
│   ├── server-production/      # Production server configuration
│   ├── gaming-setup/          # Gaming workstation configuration
│   └── minimal-server/        # Minimal server setup
├── profiles/                  # Custom profile examples
│   ├── data-scientist.yml     # Data science environment
│   ├── devops-engineer.yml    # DevOps tools and configuration
│   ├── web-developer.yml      # Web development stack
│   └── security-analyst.yml   # Security tools and hardening
├── inventories/               # Inventory examples
│   ├── multi-environment/     # Multiple environment setup
│   ├── cloud-infrastructure/  # Cloud-based infrastructure
│   └── hybrid-setup/         # Mixed local/remote setup
├── roles/                     # Custom role examples
│   ├── custom-applications/   # Custom application roles
│   ├── security-hardening/   # Security configuration roles
│   └── monitoring/           # Monitoring and alerting roles
└── integrations/             # Integration examples
    ├── ci-cd/               # CI/CD pipeline integration
    ├── cloud-providers/     # Cloud provider configurations
    └── container-platforms/ # Docker/Kubernetes integration
```

## Quick Start Examples

### 1. Developer Workstation

Complete setup for a software development environment:

```bash
# Copy example configuration
cp -r examples/configurations/developer-workstation/* .

# Customize for your needs
vim inventories/local/hosts.yml
vim group_vars/all/developer.yml

# Run configuration
ansible-playbook -i inventories/local/hosts.yml site.yml
```

### 2. Production Server

Secure, hardened server configuration:

```bash
# Copy server configuration
cp -r examples/configurations/server-production/* .

# Update server details
vim inventories/production/hosts.yml

# Deploy with security hardening
ansible-playbook -i inventories/production/hosts.yml site.yml -e profile=server
```

### 3. Multi-Environment Setup

Manage development, staging, and production environments:

```bash
# Copy multi-environment setup
cp -r examples/inventories/multi-environment/* inventories/

# Configure each environment
vim inventories/development/hosts.yml
vim inventories/staging/hosts.yml
vim inventories/production/hosts.yml

# Deploy to specific environment
ansible-playbook -i inventories/development/hosts.yml site.yml
```

## Configuration Examples

### Custom Profile Example

```yaml
# examples/profiles/data-scientist.yml
---
profiles:
  data_scientist:
    description: "Complete data science environment"
    applications:
      - git
      - vim
      - python3
      - jupyter
      - r-lang
      - docker
      - postgresql
    features:
      - python_data_stack
      - r_environment
      - jupyter_lab
      - database_tools
      - visualization_tools
    packages:
      - python3-pip
      - python3-venv
      - r-base
      - r-base-dev
      - postgresql-client
      - graphviz
    custom_config:
      jupyter_port: 8888
      r_mirror: "https://cran.rstudio.com/"
      python_packages:
        - numpy
        - pandas
        - matplotlib
        - seaborn
        - scikit-learn
        - tensorflow
        - pytorch
      r_packages:
        - "ggplot2"
        - "dplyr"
        - "tidyr"
        - "caret"
        - "randomForest"
```

### Advanced Inventory Example

```yaml
# examples/inventories/cloud-infrastructure/hosts.yml
---
all:
  children:
    webservers:
      hosts:
        web[01:03].example.com:
          ansible_host: "{{ hostvars[inventory_hostname]['private_ip'] }}"
          profile: server
          role: webserver
      vars:
        nginx_config:
          worker_processes: auto
          worker_connections: 1024
        ssl_enabled: true
        
    databases:
      hosts:
        db[01:02].example.com:
          ansible_host: "{{ hostvars[inventory_hostname]['private_ip'] }}"
          profile: server
          role: database
      vars:
        postgresql_config:
          max_connections: 200
          shared_buffers: 256MB
        backup_enabled: true
        
    loadbalancers:
      hosts:
        lb[01:02].example.com:
          ansible_host: "{{ hostvars[inventory_hostname]['public_ip'] }}"
          profile: server
          role: loadbalancer
      vars:
        haproxy_config:
          maxconn: 4096
          timeout_connect: 5000ms
        
  vars:
    ansible_user: deploy
    ansible_ssh_private_key_file: ~/.ssh/deploy_key
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
    
    # Cloud provider settings
    cloud_provider: aws
    region: us-west-2
    vpc_id: vpc-12345678
    
    # Security settings
    security_hardening: true
    firewall_enabled: true
    fail2ban_enabled: true
    
    # Monitoring
    monitoring_enabled: true
    log_aggregation: true
    
    # Backup configuration
    backup_schedule: "0 2 * * *"
    backup_retention: 30
```

### Custom Role Example

```yaml
# examples/roles/monitoring/prometheus/tasks/main.yml
---
- name: Create prometheus user
  user:
    name: prometheus
    system: yes
    shell: /bin/false
    home: /var/lib/prometheus
    createhome: yes
  become: yes

- name: Download and install Prometheus
  unarchive:
    src: "https://github.com/prometheus/prometheus/releases/download/v{{ prometheus_version }}/prometheus-{{ prometheus_version }}.linux-amd64.tar.gz"
    dest: /opt
    remote_src: yes
    owner: prometheus
    group: prometheus
    creates: "/opt/prometheus-{{ prometheus_version }}.linux-amd64"
  become: yes

- name: Create Prometheus configuration
  template:
    src: prometheus.yml.j2
    dest: /etc/prometheus/prometheus.yml
    owner: prometheus
    group: prometheus
    mode: '0644'
  notify: restart prometheus
  become: yes

- name: Create Prometheus systemd service
  template:
    src: prometheus.service.j2
    dest: /etc/systemd/system/prometheus.service
    mode: '0644'
  notify:
    - reload systemd
    - restart prometheus
  become: yes

- name: Start and enable Prometheus
  systemd:
    name: prometheus
    state: started
    enabled: yes
    daemon_reload: yes
  become: yes
```

## Integration Examples

### CI/CD Pipeline Integration

```yaml
# examples/integrations/ci-cd/github-actions.yml
name: Deploy with Dotsible

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
          
      - name: Install Ansible
        run: |
          pip install ansible
          ansible-galaxy install -r requirements.yml
          
      - name: Setup SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -H ${{ secrets.SERVER_HOST }} >> ~/.ssh/known_hosts
          
      - name: Deploy to staging
        run: |
          ansible-playbook -i inventories/staging/hosts.yml site.yml \
            -e profile=server \
            --vault-password-file <(echo "${{ secrets.VAULT_PASSWORD }}")
            
      - name: Run health checks
        run: |
          ansible-playbook -i inventories/staging/hosts.yml \
            playbooks/health-check.yml
```

### Docker Integration

```yaml
# examples/integrations/container-platforms/docker-compose.yml
version: '3.8'

services:
  dotsible-runner:
    build:
      context: .
      dockerfile: Dockerfile.dotsible
    volumes:
      - ./inventories:/dotsible/inventories
      - ./group_vars:/dotsible/group_vars
      - ./host_vars:/dotsible/host_vars
      - ~/.ssh:/root/.ssh:ro
    environment:
      - ANSIBLE_HOST_KEY_CHECKING=False
      - ANSIBLE_STDOUT_CALLBACK=yaml
    command: >
      ansible-playbook -i inventories/production/hosts.yml site.yml
      -e profile=server
      --vault-password-file /run/secrets/vault_password
    secrets:
      - vault_password

secrets:
  vault_password:
    file: ./secrets/vault_password.txt
```

### Kubernetes Integration

```yaml
# examples/integrations/container-platforms/kubernetes-job.yml
apiVersion: batch/v1
kind: Job
metadata:
  name: dotsible-deployment
  namespace: automation
spec:
  template:
    spec:
      containers:
      - name: dotsible
        image: dotsible:latest
        command:
        - ansible-playbook
        - -i
        - inventories/kubernetes/hosts.yml
        - site.yml
        - -e
        - profile=server
        volumeMounts:
        - name: ssh-key
          mountPath: /root/.ssh
          readOnly: true
        - name: vault-password
          mountPath: /run/secrets
          readOnly: true
        env:
        - name: ANSIBLE_HOST_KEY_CHECKING
          value: "False"
      volumes:
      - name: ssh-key
        secret:
          secretName: ssh-key
          defaultMode: 0600
      - name: vault-password
        secret:
          secretName: vault-password
      restartPolicy: Never
  backoffLimit: 3
```

## Advanced Use Cases

### 1. Multi-Cloud Deployment

Deploy across multiple cloud providers:

```yaml
# examples/configurations/multi-cloud/hosts.yml
---
all:
  children:
    aws_servers:
      hosts:
        aws-web-01.example.com:
          cloud_provider: aws
          instance_type: t3.medium
          region: us-west-2
      vars:
        ansible_ssh_private_key_file: ~/.ssh/aws_key
        
    gcp_servers:
      hosts:
        gcp-web-01.example.com:
          cloud_provider: gcp
          machine_type: n1-standard-2
          zone: us-central1-a
      vars:
        ansible_ssh_private_key_file: ~/.ssh/gcp_key
        
    azure_servers:
      hosts:
        azure-web-01.example.com:
          cloud_provider: azure
          vm_size: Standard_B2s
          location: westus2
      vars:
        ansible_ssh_private_key_file: ~/.ssh/azure_key
```

### 2. Development Environment Synchronization

Keep development environments in sync across team:

```yaml
# examples/configurations/team-sync/team-profile.yml
---
team_development_profile:
  base_profile: developer
  
  # Standardized tools and versions
  standardized_tools:
    node_version: "18.17.0"
    python_version: "3.11.4"
    docker_version: "24.0.5"
    kubectl_version: "1.28.0"
    
  # Team-specific packages
  team_packages:
    - pre-commit
    - black
    - flake8
    - eslint
    - prettier
    
  # Shared configurations
  shared_configs:
    git_hooks:
      pre_commit: true
      commit_msg: true
    
    editor_config:
      tab_size: 2
      insert_final_newline: true
      trim_trailing_whitespace: true
    
    linting_rules:
      python: .flake8
      javascript: .eslintrc.js
      css: .stylelintrc.json
```

### 3. Security Compliance Setup

Automated security hardening and compliance:

```yaml
# examples/configurations/security-compliance/security-profile.yml
---
security_compliance_profile:
  base_profile: server
  
  # Security standards compliance
  compliance_standards:
    - cis_benchmark
    - nist_cybersecurity_framework
    - iso_27001
    
  # Security hardening measures
  hardening_measures:
    ssh_hardening:
      disable_root_login: true
      disable_password_auth: true
      change_default_port: true
      enable_fail2ban: true
      
    firewall_config:
      default_policy: deny
      allowed_ports:
        - 22    # SSH
        - 80    # HTTP
        - 443   # HTTPS
      rate_limiting: true
      
    system_hardening:
      disable_unused_services: true
      secure_kernel_parameters: true
      file_permissions_audit: true
      user_account_policies: true
      
    monitoring:
      intrusion_detection: true
      log_monitoring: true
      file_integrity_monitoring: true
      network_monitoring: true
```

## Best Practices

### 1. Environment Separation

```bash
# Use separate inventories for each environment
inventories/
├── development/
├── staging/
├── production/
└── testing/
```

### 2. Variable Precedence

```yaml
# Order of precedence (highest to lowest):
# 1. Extra vars (-e)
# 2. Task vars
# 3. Block vars
# 4. Role and include vars
# 5. Play vars
# 6. Host facts
# 7. Host vars
# 8. Group vars
# 9. Role defaults
```

### 3. Secret Management

```bash
# Use Ansible Vault for secrets
ansible-vault create group_vars/production/secrets.yml
ansible-vault edit group_vars/production/secrets.yml

# Use different vault passwords for different environments
ansible-playbook -i inventories/production/hosts.yml site.yml \
  --vault-id production@prompt
```

### 4. Testing Configurations

```bash
# Always test with check mode first
ansible-playbook -i inventories/production/hosts.yml site.yml --check

# Use diff mode to see changes
ansible-playbook -i inventories/production/hosts.yml site.yml --diff

# Test on staging first
ansible-playbook -i inventories/staging/hosts.yml site.yml
```

## Contributing Examples

To contribute new examples:

1. **Create example directory structure**
2. **Add comprehensive documentation**
3. **Include test procedures**
4. **Provide usage instructions**
5. **Submit pull request**

### Example Template

```
examples/configurations/my-example/
├── README.md                    # Detailed description and usage
├── inventories/                 # Example inventories
├── group_vars/                  # Example variables
├── host_vars/                   # Host-specific variables
├── playbooks/                   # Custom playbooks (if needed)
└── tests/                       # Test procedures
```

---

**Explore, customize, and contribute!** 🚀

For more information, see:
- [USAGE.md](../docs/USAGE.md) - Detailed usage guide
- [EXTENDING.md](../docs/EXTENDING.md) - Adding new functionality
- [TESTING.md](../docs/TESTING.md) - Testing procedures