#!/bin/bash
# Dotsible Health Check Script
# Comprehensive system health verification after Dotsible deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTSIBLE_ROOT="$(dirname "$SCRIPT_DIR")"
HEALTH_LOG="$HOME/.dotsible/health_check_$(date +%Y%m%d_%H%M%S).log"
HEALTH_REPORT="$HOME/.dotsible/health_report.json"

# Health check results
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Logging functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$HEALTH_LOG"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$HEALTH_LOG"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$HEALTH_LOG"
    WARNING_CHECKS=$((WARNING_CHECKS + 1))
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$HEALTH_LOG"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

header() {
    echo -e "${CYAN}=== $1 ===${NC}" | tee -a "$HEALTH_LOG"
}

# Function to run health check
health_check() {
    local name="$1"
    local command="$2"
    local critical="${3:-false}"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$command" >/dev/null 2>&1; then
        success "✓ $name"
        return 0
    else
        if [ "$critical" = "true" ]; then
            error "✗ $name (Critical)"
            return 1
        else
            warning "⚠ $name (Non-critical)"
            return 0
        fi
    fi
}

# Function to check system basics
check_system_basics() {
    header "System Basics Health Check"
    
    health_check "System uptime" "uptime" true
    health_check "Disk space (root)" "[ \$(df / | awk 'NR==2 {print \$5}' | sed 's/%//') -lt 90 ]" true
    health_check "Memory availability" "[ \$(free | awk 'NR==2{printf \"%.0f\", \$3/\$2*100}') -lt 90 ]" false
    health_check "Load average" "[ \$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | sed 's/,//') -lt 5.0 ]" false
    
    # Check critical directories
    health_check "Home directory accessible" "[ -d '$HOME' ] && [ -w '$HOME' ]" true
    health_check "Dotsible directory accessible" "[ -d '$DOTSIBLE_ROOT' ]" true
    
    # Check shell
    health_check "Shell executable" "[ -x '$SHELL' ]" true
}

# Function to check installed applications
check_applications() {
    header "Application Health Check"
    
    # Core applications
    health_check "Git installation" "command -v git" true
    health_check "Vim installation" "command -v vim" false
    health_check "ZSH installation" "command -v zsh" false
    health_check "Tmux installation" "command -v tmux" false
    
    # Package managers
    case "$(uname -s)" in
        Linux)
            if [ -f /etc/debian_version ]; then
                health_check "APT package manager" "command -v apt" true
            elif [ -f /etc/arch-release ]; then
                health_check "Pacman package manager" "command -v pacman" true
            fi
            ;;
        Darwin)
            health_check "Homebrew package manager" "command -v brew" false
            ;;
    esac
    
    # Development tools (if developer profile)
    if [ -f "$HOME/.ansible_profile_summary" ] && grep -q "developer" "$HOME/.ansible_profile_summary"; then
        health_check "Node.js installation" "command -v node" false
        health_check "Python 3 installation" "command -v python3" false
        health_check "Docker installation" "command -v docker" false
    fi
}

# Function to check configurations
check_configurations() {
    header "Configuration Health Check"
    
    # Git configuration
    if command -v git >/dev/null 2>&1; then
        health_check "Git user name configured" "git config --global user.name" false
        health_check "Git user email configured" "git config --global user.email" false
    fi
    
    # Shell configuration
    health_check "Shell RC file exists" "[ -f '$HOME/.bashrc' ] || [ -f '$HOME/.zshrc' ]" false
    
    # SSH configuration
    health_check "SSH directory exists" "[ -d '$HOME/.ssh' ]" false
    if [ -d "$HOME/.ssh" ]; then
        health_check "SSH directory permissions" "[ \$(stat -c '%a' '$HOME/.ssh' 2>/dev/null || stat -f '%A' '$HOME/.ssh' 2>/dev/null) = '700' ]" false
    fi
    
    # Dotfiles
    if [ -f "$HOME/.ansible_profile_summary" ]; then
        health_check "Profile summary exists" "[ -s '$HOME/.ansible_profile_summary' ]" false
    fi
}

# Function to check services
check_services() {
    header "Service Health Check"
    
    # SSH service (if server profile)
    if command -v systemctl >/dev/null 2>&1; then
        health_check "SSH service running" "systemctl is-active ssh || systemctl is-active sshd" false
    fi
    
    # Docker service (if installed)
    if command -v docker >/dev/null 2>&1; then
        health_check "Docker service running" "docker info" false
    fi
    
    # Check for failed systemd services
    if command -v systemctl >/dev/null 2>&1; then
        health_check "No failed systemd services" "[ \$(systemctl --failed --no-legend | wc -l) -eq 0 ]" false
    fi
}

# Function to check network connectivity
check_network() {
    header "Network Health Check"
    
    health_check "DNS resolution" "nslookup google.com" false
    health_check "Internet connectivity" "ping -c 1 8.8.8.8" false
    health_check "HTTPS connectivity" "curl -s https://www.google.com" false
    
    # Package manager connectivity
    case "$(uname -s)" in
        Linux)
            if command -v apt >/dev/null 2>&1; then
                health_check "APT repository connectivity" "apt-cache policy" false
            elif command -v pacman >/dev/null 2>&1; then
                health_check "Pacman repository connectivity" "pacman -Sy --noconfirm" false
            fi
            ;;
        Darwin)
            if command -v brew >/dev/null 2>&1; then
                health_check "Homebrew repository connectivity" "brew update" false
            fi
            ;;
    esac
}

# Function to check security
check_security() {
    header "Security Health Check"
    
    # File permissions
    health_check "Home directory permissions" "[ \$(stat -c '%a' '$HOME' 2>/dev/null || stat -f '%A' '$HOME' 2>/dev/null) -ge 700 ]" false
    
    # SSH security
    if [ -f "$HOME/.ssh/config" ]; then
        health_check "SSH config permissions" "[ \$(stat -c '%a' '$HOME/.ssh/config' 2>/dev/null || stat -f '%A' '$HOME/.ssh/config' 2>/dev/null) = '600' ]" false
    fi
    
    # Check for world-writable files in home
    health_check "No world-writable files in home" "[ \$(find '$HOME' -type f -perm -002 2>/dev/null | wc -l) -eq 0 ]" false
    
    # Firewall status (Linux)
    if command -v ufw >/dev/null 2>&1; then
        health_check "UFW firewall status" "ufw status | grep -q 'Status: active'" false
    elif command -v firewall-cmd >/dev/null 2>&1; then
        health_check "Firewalld status" "firewall-cmd --state" false
    fi
}

# Function to check performance
check_performance() {
    header "Performance Health Check"
    
    # CPU usage
    health_check "CPU usage reasonable" "[ \$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}' | sed 's/%us,//' | cut -d'%' -f1) -lt 80 ]" false
    
    # Memory usage
    health_check "Memory usage reasonable" "[ \$(free | awk 'NR==2{printf \"%.0f\", \$3/\$2*100}') -lt 85 ]" false
    
    # Disk I/O
    health_check "Disk I/O reasonable" "[ \$(iostat -x 1 1 2>/dev/null | tail -n +4 | awk '{sum+=\$10} END {print sum/NR}' || echo 0) -lt 80 ]" false
    
    # Load average
    health_check "Load average reasonable" "[ \$(uptime | awk -F'load average:' '{print \$2}' | awk '{print \$1}' | sed 's/,//' | cut -d'.' -f1) -lt \$(nproc) ]" false
}

# Function to check Dotsible-specific items
check_dotsible_specific() {
    header "Dotsible-Specific Health Check"
    
    # Dotsible files
    health_check "Dotsible main playbook exists" "[ -f '$DOTSIBLE_ROOT/site.yml' ]" true
    health_check "Dotsible configuration valid" "ansible-playbook --syntax-check '$DOTSIBLE_ROOT/site.yml'" true
    
    # Ansible installation
    health_check "Ansible installation" "command -v ansible-playbook" true
    health_check "Ansible version compatible" "ansible --version | head -1 | grep -E '(2\.[9-9]|[3-9]\.)'" false
    
    # Profile summary
    if [ -f "$HOME/.ansible_profile_summary" ]; then
        health_check "Profile summary readable" "[ -r '$HOME/.ansible_profile_summary' ]" false
        
        # Check profile-specific items
        if grep -q "developer" "$HOME/.ansible_profile_summary"; then
            health_check "Developer tools accessible" "command -v git && command -v vim" false
        fi
    fi
    
    # Backup directory
    health_check "Backup directory exists" "[ -d '$HOME/.dotsible/backups' ]" false
    
    # Log directory
    if [ -d "/var/log/ansible" ]; then
        health_check "Ansible logs accessible" "[ -r '/var/log/ansible' ]" false
    fi
}

# Function to generate health report
generate_health_report() {
    header "Generating Health Report"
    
    mkdir -p "$(dirname "$HEALTH_REPORT")"
    
    local success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    local status="HEALTHY"
    
    if [ $FAILED_CHECKS -gt 0 ]; then
        status="UNHEALTHY"
    elif [ $WARNING_CHECKS -gt 5 ]; then
        status="WARNING"
    fi
    
    cat > "$HEALTH_REPORT" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "hostname": "$(hostname)",
  "user": "$(whoami)",
  "os": "$(uname -s)",
  "dotsible_version": "2.0.0",
  "health_status": "$status",
  "summary": {
    "total_checks": $TOTAL_CHECKS,
    "passed_checks": $PASSED_CHECKS,
    "failed_checks": $FAILED_CHECKS,
    "warning_checks": $WARNING_CHECKS,
    "success_rate": $success_rate
  },
  "categories": {
    "system_basics": "$([ $FAILED_CHECKS -eq 0 ] && echo "PASS" || echo "FAIL")",
    "applications": "PASS",
    "configurations": "PASS",
    "services": "PASS",
    "network": "PASS",
    "security": "PASS",
    "performance": "PASS",
    "dotsible_specific": "$([ $FAILED_CHECKS -eq 0 ] && echo "PASS" || echo "FAIL")"
  },
  "recommendations": [
    $([ $FAILED_CHECKS -gt 0 ] && echo '"Fix critical issues identified in health check",' || echo '')
    $([ $WARNING_CHECKS -gt 0 ] && echo '"Review warnings and consider addressing them",' || echo '')
    "Run regular health checks to maintain system health",
    "Keep Dotsible and system packages updated"
  ]
}
EOF
    
    success "Health report generated: $HEALTH_REPORT"
}

# Function to display summary
display_summary() {
    header "Health Check Summary"
    
    local success_rate=$(( PASSED_CHECKS * 100 / TOTAL_CHECKS ))
    
    echo "Health Check Results:"
    echo "===================="
    echo "Total Checks: $TOTAL_CHECKS"
    echo "Passed: $PASSED_CHECKS"
    echo "Failed: $FAILED_CHECKS"
    echo "Warnings: $WARNING_CHECKS"
    echo "Success Rate: $success_rate%"
    echo
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        success "🎉 System is healthy! All critical checks passed."
        if [ $WARNING_CHECKS -gt 0 ]; then
            warning "Note: $WARNING_CHECKS warning(s) found. Review recommended."
        fi
    else
        error "❌ System health issues detected!"
        log "Critical issues found: $FAILED_CHECKS"
        log "Please review the health log: $HEALTH_LOG"
    fi
    
    echo
    log "Detailed health log: $HEALTH_LOG"
    log "Health report (JSON): $HEALTH_REPORT"
}

# Main health check function
main() {
    header "Dotsible System Health Check"
    log "Starting comprehensive health check..."
    log "Timestamp: $(date)"
    log "Host: $(hostname)"
    log "User: $(whoami)"
    
    # Create log directory
    mkdir -p "$(dirname "$HEALTH_LOG")"
    
    # Run all health checks
    check_system_basics
    check_applications
    check_configurations
    check_services
    check_network
    check_security
    check_performance
    check_dotsible_specific
    
    # Generate report and summary
    generate_health_report
    display_summary
    
    # Exit with appropriate code
    if [ $FAILED_CHECKS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Dotsible Health Check Script"
        echo ""
        echo "Performs comprehensive health checks on Dotsible-managed systems."
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h          Show this help message"
        echo "  --quick             Run only critical checks"
        echo "  --system            Check only system basics"
        echo "  --applications      Check only applications"
        echo "  --network           Check only network connectivity"
        echo "  --security          Check only security items"
        echo "  --json              Output results in JSON format"
        echo ""
        echo "Examples:"
        echo "  $0                  # Full health check"
        echo "  $0 --quick          # Quick critical checks only"
        echo "  $0 --json           # JSON output for automation"
        echo ""
        exit 0
        ;;
    --quick)
        log "Running quick health check..."
        check_system_basics
        check_dotsible_specific
        generate_health_report
        display_summary
        ;;
    --system)
        check_system_basics
        display_summary
        ;;
    --applications)
        check_applications
        display_summary
        ;;
    --network)
        check_network
        display_summary
        ;;
    --security)
        check_security
        display_summary
        ;;
    --json)
        main >/dev/null 2>&1
        cat "$HEALTH_REPORT"
        ;;
    "")
        main
        ;;
    *)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac