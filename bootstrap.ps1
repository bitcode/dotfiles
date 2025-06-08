# Universal Windows Bootstrap Script for Cross-Platform Dotfiles System
param([string]$EnvironmentType = "personal")

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$ErrorActionPreference = "Stop"

# Colors
$Blue = "Blue"; $Green = "Green"; $Red = "Red"

# Logging
$LogDir = "$env:USERPROFILE\.dotsible\logs"
$LogFile = "$LogDir\bootstrap_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Timestamp [$Level] $Message"
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor $Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor $Green }
        default { Write-Host $Message -ForegroundColor $Blue }
    }
}

# Main function
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║                    DOTSIBLE BOOTSTRAP                        ║" -ForegroundColor $Blue
Write-Host "║              Cross-Platform Environment Setup               ║" -ForegroundColor $Blue
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $Blue

Write-Log "Bootstrap started for Windows" "INFO"
Write-Log "Environment type: $EnvironmentType" "INFO"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BootstrapScript = Join-Path $ScriptDir "scripts\bootstrap_windows.ps1"

if (Test-Path $BootstrapScript) {
    Write-Log "Executing: $BootstrapScript" "INFO"
    & $BootstrapScript $EnvironmentType
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Platform-specific bootstrap completed successfully" "SUCCESS"
        Write-Host ""
        Write-Log "Bootstrap completed successfully!" "SUCCESS"
        Write-Host ""
        Write-Log "Next steps:" "INFO"
        Write-Host "  1. Run: ansible-playbook site.yml"
        Write-Host "  2. Check logs: $LogFile"
    } else {
        Write-Log "Platform-specific bootstrap failed" "ERROR"
        exit 1
    }
} else {
    Write-Log "Bootstrap script not found: $BootstrapScript" "ERROR"
    exit 1
}
