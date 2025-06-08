# Windows-Specific Bootstrap Script for Dotsible
param([string]$EnvironmentType = "personal")

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$ErrorActionPreference = "Stop"

# Colors
$Red = "Red"; $Green = "Green"; $Blue = "Blue"; $Yellow = "Yellow"

# Logging
$LogDir = "$env:USERPROFILE\.dotsible\logs"
$LogFile = "$LogDir\bootstrap_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Timestamp [$Level] $Message"
    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor $Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor $Green }
        "INFO" { Write-Host $Message -ForegroundColor $Blue }
        "WARN" { Write-Host $Message -ForegroundColor $Yellow }
        default { Write-Host $Message }
    }
}

function Install-Chocolatey {
    Write-Log "Checking Chocolatey..." "INFO"
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Log "Chocolatey already installed" "SUCCESS"
        return
    }
    Write-Log "Installing Chocolatey..." "INFO"
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Log "Chocolatey installed" "SUCCESS"
}

function Install-Python {
    Write-Log "Checking Python..." "INFO"
    try {
        $pythonVersion = python --version 2>&1
        if ($pythonVersion -match "Python (\d+)\.(\d+)") {
            if ([int]$matches[1] -ge 3 -and [int]$matches[2] -ge 8) {
                Write-Log "Python found: $pythonVersion" "SUCCESS"
                return
            }
        }
    } catch {}
    Write-Log "Installing Python..." "INFO"
    choco install python3 -y
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    python -m pip install --upgrade pip
    Write-Log "Python installed" "SUCCESS"
}

function Install-Ansible {
    Write-Log "Checking Ansible..." "INFO"
    if (Get-Command ansible -ErrorAction SilentlyContinue) {
        Write-Log "Ansible already installed" "SUCCESS"
        return
    }
    Write-Log "Installing Ansible..." "INFO"
    python -m pip install --user ansible
    $userScripts = "$env:APPDATA\Python\Python*\Scripts"
    $scriptsPath = Get-ChildItem $userScripts -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($scriptsPath -and ($env:Path -notlike "*$scriptsPath*")) {
        $env:Path += ";$scriptsPath"
    }
    Write-Log "Ansible installed" "SUCCESS"
}

function Install-Pipx {
    Write-Log "Checking pipx..." "INFO"
    if (Get-Command pipx -ErrorAction SilentlyContinue) {
        Write-Log "pipx already installed" "SUCCESS"
        return
    }
    Write-Log "Installing pipx..." "INFO"
    python -m pip install --user pipx
    $userScripts = "$env:APPDATA\Python\Python*\Scripts"
    $scriptsPath = Get-ChildItem $userScripts -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($scriptsPath -and ($env:Path -notlike "*$scriptsPath*")) {
        $env:Path += ";$scriptsPath"
    }
    pipx ensurepath 2>$null
    Write-Log "pipx installed" "SUCCESS"
}

function Install-AnsibleDevTools {
    Write-Log "Installing Ansible dev tools..." "INFO"
    
    $devToolsInstalled = pipx list 2>&1 | Select-String "ansible-dev-tools"
    if (-not $devToolsInstalled) {
        pipx install ansible-dev-tools
        Write-Log "ansible-dev-tools installed" "SUCCESS"
    } else {
        Write-Log "ansible-dev-tools already installed" "SUCCESS"
    }
    
    $lintInstalled = pipx list 2>&1 | Select-String "ansible-lint"
    if (-not $lintInstalled) {
        pipx install ansible-lint
        Write-Log "ansible-lint installed" "SUCCESS"
    } else {
        Write-Log "ansible-lint already installed" "SUCCESS"
    }
}

# Main execution
Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $Blue
Write-Host "║                WINDOWS BOOTSTRAP SCRIPT                     ║" -ForegroundColor $Blue
Write-Host "║              Dotsible Environment Setup                     ║" -ForegroundColor $Blue
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $Blue

Write-Log "Windows bootstrap started for environment: $EnvironmentType" "INFO"

Install-Chocolatey
Install-Python
Install-Ansible
Install-Pipx
Install-AnsibleDevTools

Write-Log "Windows bootstrap completed successfully!" "SUCCESS"
Write-Log "Environment: $EnvironmentType" "INFO"
Write-Log "Log: $LogFile" "INFO"
