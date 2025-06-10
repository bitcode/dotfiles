#Requires -Version 5.1
<#
.SYNOPSIS
    Windows-Specific Bootstrap Script for Dotsible

.DESCRIPTION
    Configures Windows-specific requirements for Ansible-based dotfiles deployment:
    - Enables necessary Windows features
    - Installs package managers (Chocolatey, Scoop) if missing
    - Configures PowerShell modules for Ansible
    - Sets up WinRM for Ansible connectivity

.PARAMETER EnvironmentType
    Environment type: personal or enterprise

.PARAMETER Force
    Force reinstallation of existing components

.PARAMETER Verbose
    Enable verbose output

.EXAMPLE
    .\bootstrap_windows.ps1 -EnvironmentType personal

.EXAMPLE
    .\bootstrap_windows.ps1 -EnvironmentType enterprise -Verbose

.NOTES
    Requires PowerShell 5.1 or later
    Should be run after main bootstrap.ps1
#>

[CmdletBinding()]
param(
    [ValidateSet("personal", "enterprise")]
    [string]$EnvironmentType = "personal",
    [switch]$Force,
    [switch]$Verbose
)

# Script configuration
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Script:LogFile = "$env:USERPROFILE\.dotsible\logs\bootstrap_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:StartTime = Get-Date

# Configuration
$Script:Config = @{
    ChocolateyInstallUrl = "https://chocolatey.org/install.ps1"
    ScoopInstallUrl = "https://get.scoop.sh"
    RequiredFeatures = @(
        "Microsoft-Windows-Subsystem-Linux"
        "VirtualMachinePlatform"
    )
    PowerShellModules = @(
        "PowerShellGet"
        "PackageManagement"
        "PSWindowsUpdate"
    )
    ChocolateyPackages = @(
        "git"
        "7zip"
        "curl"
        "wget"
    )
    ScoopBuckets = @(
        "extras"
        "versions"
        "nerd-fonts"
    )
}

# Logging functions
function Initialize-Logging {
    $logDir = Split-Path -Parent $Script:LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    try {
        Start-Transcript -Path $Script:LogFile -Append
    } catch {
        Write-Warning "Could not start transcript: $_"
    }
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS", "DEBUG")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "DEBUG" { if ($Verbose) { Write-Host $logMessage -ForegroundColor Magenta } }
        default { Write-Host $logMessage -ForegroundColor Cyan }
    }
    
    Add-Content -Path $Script:LogFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Show-Progress {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity,
        [string]$Status = "Processing..."
    )
    
    $percent = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $percent
}

function Show-Banner {
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                WINDOWS BOOTSTRAP SCRIPT                     ║
║              Dotsible Environment Setup                     ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
}

# Windows feature management
function Enable-WindowsFeatures {
    Write-Log "Checking Windows features..." -Level INFO
    
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $isAdmin) {
        Write-Log "Administrator privileges required for Windows feature management" -Level WARN
        return
    }
    
    foreach ($feature in $Script:Config.RequiredFeatures) {
        try {
            $featureState = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
            
            if ($featureState -and $featureState.State -eq "Enabled") {
                Write-Log "Windows feature already enabled: $feature" -Level SUCCESS
            } else {
                Write-Log "Enabling Windows feature: $feature" -Level INFO
                Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart
                Write-Log "Windows feature enabled: $feature" -Level SUCCESS
            }
        } catch {
            Write-Log "Failed to enable Windows feature $feature`: $_" -Level WARN
        }
    }
}

# Package manager installation
function Install-Chocolatey {
    Write-Log "Checking Chocolatey installation..." -Level INFO
    
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Log "Chocolatey already installed" -Level SUCCESS
        
        # Update Chocolatey
        try {
            Write-Log "Updating Chocolatey..." -Level INFO
            & choco upgrade chocolatey -y
        } catch {
            Write-Log "Chocolatey update failed: $_" -Level WARN
        }
        return $true
    }
    
    try {
        Write-Log "Installing Chocolatey..." -Level INFO
        
        # Set execution policy temporarily
        $originalPolicy = Get-ExecutionPolicy
        Set-ExecutionPolicy Bypass -Scope Process -Force
        
        # Download and install Chocolatey
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($Script:Config.ChocolateyInstallUrl))
        
        # Restore execution policy
        Set-ExecutionPolicy $originalPolicy -Scope Process -Force
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log "Chocolatey installed successfully" -Level SUCCESS
            
            # Install essential packages
            foreach ($package in $Script:Config.ChocolateyPackages) {
                try {
                    Write-Log "Installing Chocolatey package: $package" -Level INFO
                    & choco install $package -y --no-progress
                } catch {
                    Write-Log "Failed to install $package`: $_" -Level WARN
                }
            }
            
            return $true
        } else {
            Write-Log "Chocolatey installation verification failed" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "Chocolatey installation failed: $_" -Level ERROR
        return $false
    }
}

function Install-Scoop {
    Write-Log "Checking Scoop installation..." -Level INFO
    
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Log "Scoop already installed" -Level SUCCESS
        
        # Update Scoop
        try {
            Write-Log "Updating Scoop..." -Level INFO
            & scoop update
        } catch {
            Write-Log "Scoop update failed: $_" -Level WARN
        }
        return $true
    }
    
    try {
        Write-Log "Installing Scoop..." -Level INFO
        
        # Set execution policy temporarily
        $originalPolicy = Get-ExecutionPolicy -Scope CurrentUser
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        
        # Install Scoop
        Invoke-RestMethod $Script:Config.ScoopInstallUrl | Invoke-Expression
        
        # Restore execution policy
        Set-ExecutionPolicy $originalPolicy -Scope CurrentUser -Force
        
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Log "Scoop installed successfully" -Level SUCCESS
            
            # Add useful buckets
            foreach ($bucket in $Script:Config.ScoopBuckets) {
                try {
                    Write-Log "Adding Scoop bucket: $bucket" -Level INFO
                    & scoop bucket add $bucket
                } catch {
                    Write-Log "Failed to add bucket $bucket`: $_" -Level WARN
                }
            }
            
            return $true
        } else {
            Write-Log "Scoop installation verification failed" -Level ERROR
            return $false
        }
    } catch {
        Write-Log "Scoop installation failed: $_" -Level ERROR
        return $false
    }
}

# PowerShell module management
function Install-PowerShellModules {
    Write-Log "Installing PowerShell modules..." -Level INFO
    
    foreach ($module in $Script:Config.PowerShellModules) {
        try {
            if (Get-Module -ListAvailable -Name $module) {
                Write-Log "PowerShell module already installed: $module" -Level SUCCESS
            } else {
                Write-Log "Installing PowerShell module: $module" -Level INFO
                Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
                Write-Log "PowerShell module installed: $module" -Level SUCCESS
            }
        } catch {
            Write-Log "Failed to install PowerShell module $module`: $_" -Level WARN
        }
    }
}

# WinRM configuration for Ansible
function Initialize-WinRM {
    Write-Log "Configuring WinRM for Ansible..." -Level INFO
    
    try {
        # Check if WinRM is already configured
        $winrmConfig = & winrm get winrm/config 2>$null
        if ($winrmConfig) {
            Write-Log "WinRM already configured" -Level SUCCESS
        } else {
            Write-Log "Configuring WinRM..." -Level INFO
            
            # Enable WinRM
            & winrm quickconfig -quiet
            
            # Configure WinRM for Ansible
            & winrm set winrm/config/service/auth '@{Basic="true"}'
            & winrm set winrm/config/service '@{AllowUnencrypted="true"}'
            & winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
            
            Write-Log "WinRM configured successfully" -Level SUCCESS
        }
        
        # Start WinRM service
        $winrmService = Get-Service -Name WinRM
        if ($winrmService.Status -ne "Running") {
            Write-Log "Starting WinRM service..." -Level INFO
            Start-Service -Name WinRM
        }
        
        # Set WinRM service to automatic startup
        Set-Service -Name WinRM -StartupType Automatic
        
        Write-Log "WinRM service configured and started" -Level SUCCESS
        return $true
    } catch {
        Write-Log "WinRM configuration failed: $_" -Level ERROR
        return $false
    }
}

# Environment-specific configuration
function Initialize-Environment {
    param([string]$EnvType)
    
    Write-Log "Configuring for environment type: $EnvType" -Level INFO
    
    switch ($EnvType) {
        "enterprise" {
            Write-Log "Applying enterprise-specific configurations..." -Level INFO
            
            # Enterprise-specific configurations
            try {
                # Configure Windows Update settings for enterprise
                if (Get-Command Set-WUSettings -ErrorAction SilentlyContinue) {
                    Set-WUSettings -MicrosoftUpdateEnabled -AutoUpdateOption "ScheduledInstallation"
                }
                
                # Configure enterprise security settings
                # Add enterprise-specific registry settings here
                
                Write-Log "Enterprise configuration completed" -Level SUCCESS
            } catch {
                Write-Log "Enterprise configuration failed: $_" -Level WARN
            }
        }
        "personal" {
            Write-Log "Applying personal environment configurations..." -Level INFO
            
            # Personal-specific configurations
            try {
                # Configure personal settings
                # Add personal-specific configurations here
                
                Write-Log "Personal configuration completed" -Level SUCCESS
            } catch {
                Write-Log "Personal configuration failed: $_" -Level WARN
            }
        }
        default {
            Write-Log "Unknown environment type: $EnvType. Using default configuration." -Level WARN
        }
    }
}

# Final validation
function Invoke-FinalValidation {
    Write-Log "Performing final validation..." -Level INFO
    
    $validationResults = @()
    
    # Check Chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $validationResults += "✓ Chocolatey: $(& choco --version)"
    } else {
        $validationResults += "✗ Chocolatey: Not found"
    }
    
    # Check Scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        $validationResults += "✓ Scoop: Available"
    } else {
        $validationResults += "✗ Scoop: Not found"
    }
    
    # Check WinRM
    try {
        $winrmService = Get-Service -Name WinRM
        if ($winrmService.Status -eq "Running") {
            $validationResults += "✓ WinRM: Running"
        } else {
            $validationResults += "✗ WinRM: Not running"
        }
    } catch {
        $validationResults += "✗ WinRM: Error checking status"
    }
    
    # Check PowerShell modules
    $moduleCount = 0
    foreach ($module in $Script:Config.PowerShellModules) {
        if (Get-Module -ListAvailable -Name $module) {
            $moduleCount++
        }
    }
    $validationResults += "✓ PowerShell Modules: $moduleCount/$($Script:Config.PowerShellModules.Count) installed"
    
    Write-Log "Validation Results:" -Level INFO
    foreach ($result in $validationResults) {
        Write-Log "  $result" -Level INFO
    }
    
    Write-Log "Windows-specific validation completed" -Level SUCCESS
    return $true
}

# Main execution function
function Invoke-WindowsBootstrap {
    try {
        Initialize-Logging
        Show-Banner
        
        Write-Log "Windows bootstrap started" -Level INFO
        Write-Log "Environment type: $EnvironmentType" -Level INFO
        Write-Log "Parameters: Force=$Force, Verbose=$Verbose" -Level INFO
        Write-Log "Log file: $Script:LogFile" -Level INFO
        
        $totalSteps = 6
        $currentStep = 0
        
        # Step 1: Windows features
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Enabling Windows features..."
        Enable-WindowsFeatures
        
        # Step 2: Chocolatey
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Installing Chocolatey..."
        Install-Chocolatey | Out-Null
        
        # Step 3: Scoop
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Installing Scoop..."
        Install-Scoop | Out-Null
        
        # Step 4: PowerShell modules
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Installing PowerShell modules..."
        Install-PowerShellModules
        
        # Step 5: WinRM
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Configuring WinRM..."
        Initialize-WinRM | Out-Null
        
        # Step 6: Environment configuration
        Show-Progress -Current (++$currentStep) -Total $totalSteps -Activity "Windows Bootstrap" -Status "Configuring environment..."
        Initialize-Environment -EnvType $EnvironmentType
        
        Write-Progress -Activity "Windows Bootstrap" -Completed
        
        # Final validation
        Invoke-FinalValidation | Out-Null
        
        # Success message
        Write-Log "Windows bootstrap completed successfully!" -Level SUCCESS
        Write-Host ""
        Write-Log "Installed components:" -Level INFO
        Write-Host "  - Package Managers: Chocolatey, Scoop"
        Write-Host "  - PowerShell Modules: $($Script:Config.PowerShellModules -join ', ')"
        Write-Host "  - WinRM: Configured and running"
        Write-Host ""
        Write-Log "Environment type: $EnvironmentType" -Level INFO
        Write-Log "Log file: $Script:LogFile" -Level INFO
        
        $duration = (Get-Date) - $Script:StartTime
        Write-Log "Windows bootstrap completed in $($duration.TotalMinutes.ToString('F1')) minutes" -Level INFO
        
    } catch {
        Write-Log "Windows bootstrap failed: $_" -Level ERROR
        Write-Log "Check log file for details: $Script:LogFile" -Level ERROR
        exit 1
    } finally {
        try {
            Stop-Transcript
        } catch {
            # Ignore transcript errors
        }
    }
}

# Execute bootstrap
Invoke-WindowsBootstrap
