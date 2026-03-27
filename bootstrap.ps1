# Dotsible - Windows Bootstrap Entry Point
# Usage: .\bootstrap.ps1 [-EnvironmentType personal|enterprise] [-AllUsers] [-SkipPackages] [-SkipDotfiles] [-DryRun] [-Force]
param(
    [ValidateSet("personal", "enterprise")]
    [string]$EnvironmentType = "personal",
    [switch]$AllUsers,
    [switch]$SkipPackages,
    [switch]$SkipDotfiles,
    [switch]$DryRun,
    [switch]$Force
)

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
$ErrorActionPreference = "Stop"

# Logging
$LogDir = "$env:USERPROFILE\.dotsible\logs"
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

Write-Host ""
Write-Host "  DOTSIBLE" -ForegroundColor Cyan
Write-Host "  Cross-Platform Dotfiles Manager" -ForegroundColor DarkGray
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BootstrapScript = Join-Path $ScriptDir "scripts\bootstrap_windows.ps1"

if (-not (Test-Path $BootstrapScript)) {
    Write-Host "  ERROR: Bootstrap script not found: $BootstrapScript" -ForegroundColor Red
    exit 1
}

# Pass all parameters through to the main bootstrap script
$params = @{
    EnvironmentType = $EnvironmentType
}
if ($AllUsers)     { $params["AllUsers"]     = $true }
if ($SkipPackages) { $params["SkipPackages"] = $true }
if ($SkipDotfiles) { $params["SkipDotfiles"] = $true }
if ($DryRun)       { $params["DryRun"]       = $true }
if ($Force)        { $params["Force"]         = $true }

& $BootstrapScript @params
