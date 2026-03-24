#Requires -Version 5.1
<#
.SYNOPSIS
    Self-sufficient Windows bootstrap for Dotsible.

.DESCRIPTION
    Complete Windows environment setup — no Ansible dependency required.
    Handles everything: package managers, packages, development tools,
    dotfile deployment, PowerShell profile, environment configuration.

    Steps:
      1. Windows features (WSL, Hyper-V)
      2. Package managers (Chocolatey, Scoop)
      3. Core packages via Chocolatey
      4. Development tools via Chocolatey + Scoop
      5. PowerShell modules
      6. Environment variables & registry settings
      7. Development directories
      8. Dotfile deployment (Neovim, Starship, Alacritty, etc.)
      9. PowerShell profile installation
     10. Final validation

.PARAMETER EnvironmentType
    Environment type: personal or enterprise

.PARAMETER SkipPackages
    Skip package installation (useful for re-deploying dotfiles only)

.PARAMETER SkipDotfiles
    Skip dotfile deployment

.PARAMETER DryRun
    Show what would be done without making changes

.PARAMETER Force
    Overwrite existing files without prompting

.EXAMPLE
    .\bootstrap_windows.ps1
    .\bootstrap_windows.ps1 -EnvironmentType enterprise
    .\bootstrap_windows.ps1 -SkipPackages          # dotfiles only
    .\bootstrap_windows.ps1 -DryRun                 # preview
#>

[CmdletBinding()]
param(
    [ValidateSet("personal", "enterprise")]
    [string]$EnvironmentType = "personal",
    [switch]$SkipPackages,
    [switch]$SkipDotfiles,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Script:LogFile = "$env:USERPROFILE\.dotsible\logs\bootstrap_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:StartTime = Get-Date
$Script:DotfilesRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

# ============================================================================
# CONFIGURATION
# ============================================================================
$Script:Config = @{
    ChocolateyInstallUrl = "https://chocolatey.org/install.ps1"
    ScoopInstallUrl      = "https://get.scoop.sh"

    # Windows optional features (require admin)
    RequiredFeatures = @(
        "Microsoft-Windows-Subsystem-Linux"
        "VirtualMachinePlatform"
    )

    # Scoop buckets to add
    ScoopBuckets = @(
        "extras"
        "versions"
        "nerd-fonts"
    )

    # PowerShell modules
    PowerShellModules = @(
        "PSReadLine"
        "posh-git"
        "Terminal-Icons"
        "PSFzf"
        "PowerShellGet"
        "PackageManagement"
    )

    # --- Chocolatey packages (core + dev tools) ---
    ChocolateyPackages = @(
        # Core utilities
        "git"
        "7zip"
        "curl"
        "wget"
        "powershell-core"

        # Editors & terminals
        "neovim"
        "vim"
        "alacritty"

        # Languages & runtimes
        "python3"
        "nodejs"
        "golang"
        "rustup.install"

        # CLI tools
        "starship"
        "ripgrep"
        "fd"
        "fzf"
        "bat"
        "jq"
        "tree"
        "zoxide"
        "lsd"

        # Containers & VMs
        "docker-desktop"
    )

    # Development tools (Chocolatey) — heavier installs, separate step
    DevToolsChocolatey = @(
        "llvm"
        "cmake"
        "ninja"
        "make"
        "nasm"
        "grep"
        "sed"
        "gawk"
        "which"
        "sysinternals"
    )

    # Scoop packages (things that work better via Scoop)
    ScoopPackages = @(
        "gdb"
        "lazygit"
    )

    # Nerd Fonts (via Scoop nerd-fonts bucket)
    # These provide the powerline/icon glyphs used by starship, lsd, Terminal-Icons
    NerdFonts = @(
        "Iosevka-NF"
        "JetBrainsMono-NF"
    )

    # GUI apps (Chocolatey)
    GuiPackages = @(
        "vscode"
        "firefox"
        "googlechrome"
        "discord"
        "notion"
        "obsidian"
    )

    # Environment variables
    EnvironmentVars = @(
        @{ Name = "EDITOR"; Value = "nvim" }
        @{ Name = "VISUAL"; Value = "nvim" }
        @{ Name = "STARSHIP_CONFIG"; Value = "$env:USERPROFILE\.config\starship.toml" }
    )

    # Registry settings
    RegistrySettings = @(
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "HideFileExt"; Value = 0; Type = "DWord" }
        @{ Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name = "Hidden"; Value = 1; Type = "DWord" }
    )

    # Development directories
    DevDirectories = @(
        "$env:USERPROFILE\dev"
        "$env:USERPROFILE\projects"
        "$env:USERPROFILE\.config"
        "$env:USERPROFILE\.local\bin"
    )
}

# ============================================================================
# LOGGING
# ============================================================================
function Initialize-Logging {
    $logDir = Split-Path -Parent $Script:LogFile
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    try { Start-Transcript -Path $Script:LogFile -Append } catch { }
}

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS", "SKIP")]
        [string]$Level = "INFO"
    )
    $colors = @{ "INFO" = "Cyan"; "WARN" = "Yellow"; "ERROR" = "Red"; "SUCCESS" = "Green"; "SKIP" = "DarkGray" }
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
    Add-Content -Path $Script:LogFile -Value "[$timestamp] [$Level] $Message" -ErrorAction SilentlyContinue
}

function Show-StepBanner {
    param([int]$Step, [int]$Total, [string]$Title)
    Write-Host ""
    Write-Host "  [$Step/$Total] $Title" -ForegroundColor White
    Write-Host "  $("-" * ($Title.Length + 8))" -ForegroundColor DarkGray
}

function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    # Ensure scoop shims are in PATH (scoop adds itself to User PATH on install,
    # but the current session may not see it yet)
    $scoopShims = "$env:USERPROFILE\scoop\shims"
    if ((Test-Path $scoopShims) -and ($env:Path -notlike "*$scoopShims*")) {
        $env:Path = "$scoopShims;$env:Path"
    }
}

# ============================================================================
# STEP 1: WINDOWS FEATURES
# ============================================================================
function Enable-WindowsFeatures {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    if (-not $isAdmin) {
        Write-Log "Skipping Windows features (requires admin). Run as Administrator to enable WSL/Hyper-V." "WARN"
        return
    }

    foreach ($feature in $Script:Config.RequiredFeatures) {
        try {
            $state = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
            if ($state -and $state.State -eq "Enabled") {
                Write-Log "$feature already enabled" "SUCCESS"
            } else {
                if ($DryRun) {
                    Write-Log "Would enable: $feature" "INFO"
                } else {
                    Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart | Out-Null
                    Write-Log "$feature enabled" "SUCCESS"
                }
            }
        } catch {
            Write-Log "Failed to enable ${feature}: $_" "WARN"
        }
    }
}

# ============================================================================
# STEP 2: PACKAGE MANAGERS
# ============================================================================
function Install-Chocolatey {
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        $ver = & choco --version 2>$null
        Write-Log "Chocolatey $ver already installed" "SUCCESS"
        return $true
    }

    if ($DryRun) {
        Write-Log "Would install Chocolatey" "INFO"
        return $true
    }

    try {
        Write-Log "Installing Chocolatey..." "INFO"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($Script:Config.ChocolateyInstallUrl))
        Refresh-Path

        if (Get-Command choco -ErrorAction SilentlyContinue) {
            Write-Log "Chocolatey installed" "SUCCESS"
            return $true
        }
        Write-Log "Chocolatey install failed verification" "ERROR"
        return $false
    } catch {
        Write-Log "Chocolatey install failed: $_" "ERROR"
        return $false
    }
}

function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Log "Scoop already installed" "SUCCESS"
        return $true
    }

    if ($DryRun) {
        Write-Log "Would install Scoop" "INFO"
        return $true
    }

    try {
        Write-Log "Installing Scoop..." "INFO"
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod $Script:Config.ScoopInstallUrl | Invoke-Expression
        Refresh-Path

        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Log "Scoop installed" "SUCCESS"
            foreach ($bucket in $Script:Config.ScoopBuckets) {
                try {
                    & scoop bucket add $bucket 2>$null
                    Write-Log "Scoop bucket added: $bucket" "SUCCESS"
                } catch {
                    Write-Log "Scoop bucket $bucket may already exist" "SKIP"
                }
            }
            return $true
        }
        Write-Log "Scoop install failed verification" "ERROR"
        return $false
    } catch {
        Write-Log "Scoop install failed: $_" "ERROR"
        return $false
    }
}

# ============================================================================
# STEP 3-5: PACKAGE INSTALLATION
# ============================================================================
function Install-ChocoPackages {
    param([string[]]$Packages, [string]$Category = "packages")

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Log "Chocolatey not available, skipping $Category" "WARN"
        return
    }

    $installed = 0
    $skipped = 0
    $failed = 0

    foreach ($pkg in $Packages) {
        # Check if already installed
        $check = & choco list --local-only 2>$null | Select-String "^$pkg\s"
        if ($check) {
            $skipped++
            Write-Log "$pkg already installed" "SKIP"
            continue
        }

        if ($DryRun) {
            Write-Log "Would install: $pkg" "INFO"
            continue
        }

        try {
            & choco install $pkg -y --no-progress 2>&1 | Out-Null
            $installed++
            Write-Log "$pkg installed" "SUCCESS"
        } catch {
            $failed++
            Write-Log "$pkg failed: $_" "WARN"
        }
    }

    Refresh-Path
    Write-Log "$Category summary: $installed installed, $skipped already present, $failed failed" "INFO"
}

function Install-ScoopPackages {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Log "Scoop not available, skipping Scoop packages" "WARN"
        return
    }

    foreach ($pkg in $Script:Config.ScoopPackages) {
        $check = & scoop list 2>$null | Select-String $pkg
        if ($check) {
            Write-Log "$pkg already installed (Scoop)" "SKIP"
            continue
        }

        if ($DryRun) {
            Write-Log "Would install (Scoop): $pkg" "INFO"
            continue
        }

        try {
            & scoop install $pkg 2>&1 | Out-Null
            Write-Log "$pkg installed (Scoop)" "SUCCESS"
        } catch {
            Write-Log "$pkg failed (Scoop): $_" "WARN"
        }
    }
}

# ============================================================================
# STEP 5b: NERD FONTS (via Scoop)
# ============================================================================
function Install-NerdFonts {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Log "Scoop not available, skipping Nerd Fonts" "WARN"
        return
    }

    # Ensure nerd-fonts bucket is added
    $buckets = & scoop bucket list 2>$null
    if ($buckets -notmatch "nerd-fonts") {
        if (-not $DryRun) {
            & scoop bucket add nerd-fonts 2>$null
            Write-Log "Added nerd-fonts bucket" "SUCCESS"
        }
    }

    foreach ($font in $Script:Config.NerdFonts) {
        $check = & scoop list 2>$null | Select-String $font
        if ($check) {
            Write-Log "$font already installed" "SKIP"
            continue
        }

        if ($DryRun) {
            Write-Log "Would install font: $font" "INFO"
            continue
        }

        try {
            Write-Log "Installing $font (this may take a minute)..." "INFO"
            & scoop install $font 2>&1 | Out-Null
            Write-Log "$font installed" "SUCCESS"
        } catch {
            Write-Log "$font failed: $_" "WARN"
        }
    }

    # Verify fonts are in the user font directory
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $iosevkaCount = (Get-ChildItem -Path $fontDir -Filter "IosevkaNerd*" -ErrorAction SilentlyContinue).Count
    $jbCount = (Get-ChildItem -Path $fontDir -Filter "JetBrainsMono*Nerd*" -ErrorAction SilentlyContinue).Count
    Write-Log "Nerd Fonts installed: Iosevka ($iosevkaCount files), JetBrainsMono ($jbCount files)" "INFO"
}

# ============================================================================
# STEP 6: POWERSHELL MODULES
# ============================================================================
function Install-PSModules {
    # Check if Install-Module works (PS 5.1 on some machines has broken PowerShellGet)
    $canInstall = $true
    try {
        Get-Command Install-Module -ErrorAction Stop | Out-Null
    } catch {
        $canInstall = $false
        Write-Log "Install-Module not available in this PowerShell session" "WARN"
        Write-Log "Run this bootstrap from PowerShell 7 (pwsh) for module installation" "WARN"
    }

    foreach ($module in $Script:Config.PowerShellModules) {
        if (Get-Module -ListAvailable -Name $module) {
            Write-Log "$module already installed" "SKIP"
            continue
        }

        if ($DryRun) {
            Write-Log "Would install module: $module" "INFO"
            continue
        }

        if (-not $canInstall) {
            Write-Log "$module skipped (Install-Module unavailable)" "SKIP"
            continue
        }

        try {
            Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser -ErrorAction Stop
            Write-Log "$module installed" "SUCCESS"
        } catch {
            Write-Log "$module failed: $_" "WARN"
        }
    }
}

# ============================================================================
# STEP 7: ENVIRONMENT & REGISTRY
# ============================================================================
function Set-EnvironmentConfig {
    # Environment variables
    foreach ($var in $Script:Config.EnvironmentVars) {
        $current = [System.Environment]::GetEnvironmentVariable($var.Name, "User")
        if ($current -eq $var.Value) {
            Write-Log "Env $($var.Name) already set" "SKIP"
            continue
        }
        if ($DryRun) {
            Write-Log "Would set env: $($var.Name)=$($var.Value)" "INFO"
            continue
        }
        [System.Environment]::SetEnvironmentVariable($var.Name, $var.Value, "User")
        Set-Item -Path "Env:$($var.Name)" -Value $var.Value
        Write-Log "Set env: $($var.Name)=$($var.Value)" "SUCCESS"
    }

    # Registry settings
    foreach ($reg in $Script:Config.RegistrySettings) {
        try {
            $current = Get-ItemProperty -Path $reg.Path -Name $reg.Name -ErrorAction SilentlyContinue
            if ($current -and $current.$($reg.Name) -eq $reg.Value) {
                Write-Log "Registry $($reg.Name) already set" "SKIP"
                continue
            }
            if ($DryRun) {
                Write-Log "Would set registry: $($reg.Name)=$($reg.Value)" "INFO"
                continue
            }
            Set-ItemProperty -Path $reg.Path -Name $reg.Name -Value $reg.Value -Type $reg.Type
            Write-Log "Set registry: $($reg.Name)=$($reg.Value)" "SUCCESS"
        } catch {
            Write-Log "Registry $($reg.Name) failed: $_" "WARN"
        }
    }
}

# ============================================================================
# STEP 8: DEVELOPMENT DIRECTORIES
# ============================================================================
function New-DevDirectories {
    foreach ($dir in $Script:Config.DevDirectories) {
        if (Test-Path $dir) {
            Write-Log "Directory exists: $dir" "SKIP"
            continue
        }
        if ($DryRun) {
            Write-Log "Would create: $dir" "INFO"
            continue
        }
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Created: $dir" "SUCCESS"
    }
}

# ============================================================================
# STEP 9: DOTFILE DEPLOYMENT
# ============================================================================
function Deploy-Dotfiles {
    $deployScript = Join-Path $Script:DotfilesRoot "scripts\deploy_dotfiles_windows.ps1"

    if (-not (Test-Path $deployScript)) {
        Write-Log "Dotfile deploy script not found: $deployScript" "ERROR"
        return
    }

    $deployArgs = @{
        DotfilesRoot = $Script:DotfilesRoot
    }
    if ($DryRun) { $deployArgs["DryRun"] = $true }
    if ($Force) { $deployArgs["Force"] = $true }

    Write-Log "Deploying dotfiles..." "INFO"
    & $deployScript @deployArgs
}

# ============================================================================
# STEP 10: VALIDATION
# ============================================================================
function Invoke-Validation {
    # Ensure scoop shims are in path for validation
    Refresh-Path

    Write-Host ""
    Write-Host "  Validation" -ForegroundColor White
    Write-Host "  ----------" -ForegroundColor DarkGray

    $checks = @(
        @{ Name = "Chocolatey"; Cmd = "choco" }
        @{ Name = "Git"; Cmd = "git" }
        @{ Name = "Python"; Cmd = "python" }
        @{ Name = "Node.js"; Cmd = "node" }
        @{ Name = "Neovim"; Cmd = "nvim" }
        @{ Name = "Go"; Cmd = "go" }
        @{ Name = "Starship"; Cmd = "starship" }
        @{ Name = "ripgrep"; Cmd = "rg" }
        @{ Name = "fd"; Cmd = "fd" }
        @{ Name = "fzf"; Cmd = "fzf" }
        @{ Name = "bat"; Cmd = "bat" }
        @{ Name = "zoxide"; Cmd = "zoxide" }
        @{ Name = "lsd"; Cmd = "lsd" }
    )

    $passed = 0
    $total = $checks.Count

    foreach ($check in $checks) {
        if (Get-Command $check.Cmd -ErrorAction SilentlyContinue) {
            Write-Log "$($check.Name): OK" "SUCCESS"
            $passed++
        } else {
            Write-Log "$($check.Name): not found" "WARN"
        }
    }

    # Check Nerd Fonts
    Write-Host ""
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $iosevkaFonts = (Get-ChildItem -Path $fontDir -Filter "IosevkaNerd*" -ErrorAction SilentlyContinue).Count
    $jbFonts = (Get-ChildItem -Path $fontDir -Filter "JetBrainsMono*Nerd*" -ErrorAction SilentlyContinue).Count
    if ($iosevkaFonts -gt 0) {
        Write-Log "Iosevka Nerd Font: $iosevkaFonts files installed" "SUCCESS"
    } else {
        Write-Log "Iosevka Nerd Font: not installed" "WARN"
    }
    if ($jbFonts -gt 0) {
        Write-Log "JetBrainsMono Nerd Font: $jbFonts files installed" "SUCCESS"
    } else {
        Write-Log "JetBrainsMono Nerd Font: not installed" "WARN"
    }

    # Check dotfile targets
    Write-Host ""
    $dotfileChecks = @(
        @{ Name = "Neovim config"; Path = "$env:LOCALAPPDATA\nvim\init.lua" }
        @{ Name = "Starship config"; Path = "$env:USERPROFILE\.config\starship.toml" }
        @{ Name = "PowerShell profile"; Path = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }
        @{ Name = "Vim config"; Path = "$env:USERPROFILE\.vimrc" }
    )

    foreach ($dc in $dotfileChecks) {
        if (Test-Path $dc.Path) {
            Write-Log "$($dc.Name): deployed" "SUCCESS"
        } else {
            Write-Log "$($dc.Name): missing" "WARN"
        }
    }

    Write-Host ""
    Write-Log "Tools: $passed/$total available" "INFO"
}

# ============================================================================
# MAIN
# ============================================================================
function Invoke-WindowsBootstrap {
    try {
        Initialize-Logging

        Write-Host ""
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host "  DOTSIBLE - Windows Bootstrap" -ForegroundColor Cyan
        Write-Host "  Self-sufficient setup (no Ansible required)" -ForegroundColor DarkGray
        Write-Host "========================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Log "Environment: $EnvironmentType" "INFO"
        Write-Log "Dotfiles root: $Script:DotfilesRoot" "INFO"
        if ($DryRun) { Write-Log "DRY RUN - no changes will be made" "WARN" }
        if ($SkipPackages) { Write-Log "Skipping package installation" "INFO" }
        if ($SkipDotfiles) { Write-Log "Skipping dotfile deployment" "INFO" }

        $totalSteps = 11
        $step = 0

        # Step 1: Windows Features
        Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Windows Features"
        Enable-WindowsFeatures

        if (-not $SkipPackages) {
            # Step 2: Package Managers
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Package Managers"
            $chocoOk = Install-Chocolatey
            $scoopOk = Install-Scoop

            # Step 3: Core Packages
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Core Packages (Chocolatey)"
            Install-ChocoPackages -Packages $Script:Config.ChocolateyPackages -Category "Core packages"

            # Step 4: Development Tools
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Development Tools"
            Install-ChocoPackages -Packages $Script:Config.DevToolsChocolatey -Category "Dev tools"
            Install-ScoopPackages

            # Step 5: GUI Applications
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "GUI Applications"
            Install-ChocoPackages -Packages $Script:Config.GuiPackages -Category "GUI apps"

            # Step 6: Nerd Fonts
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Nerd Fonts"
            Install-NerdFonts
        } else {
            $step += 5  # Skip package + font steps
        }

        # Step 7: PowerShell Modules
        Show-StepBanner -Step (++$step) -Total $totalSteps -Title "PowerShell Modules"
        Install-PSModules

        # Step 8: Environment & Registry
        Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Environment Configuration"
        Set-EnvironmentConfig

        # Step 9: Development Directories
        Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Development Directories"
        New-DevDirectories

        if (-not $SkipDotfiles) {
            # Step 10: Dotfile Deployment
            Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Dotfile Deployment"
            Deploy-Dotfiles
        } else {
            $step++
        }

        # Step 11: Validation
        Show-StepBanner -Step (++$step) -Total $totalSteps -Title "Validation"
        Invoke-Validation

        # Done
        $duration = (Get-Date) - $Script:StartTime
        Write-Host ""
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host "  Bootstrap completed in $($duration.TotalMinutes.ToString('F1')) minutes" -ForegroundColor Green
        Write-Host "========================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Next steps:" -ForegroundColor White
        Write-Host "    1. Restart your terminal (or run: pwsh)" -ForegroundColor DarkGray
        Write-Host "    2. Your PowerShell profile will load automatically" -ForegroundColor DarkGray
        Write-Host "    3. Starship prompt + zoxide + vi mode will be active" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  To re-deploy dotfiles only:" -ForegroundColor White
        Write-Host "    .\scripts\deploy_dotfiles_windows.ps1 -Force" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Log: $Script:LogFile" -ForegroundColor DarkGray
        Write-Host ""

    } catch {
        Write-Log "Bootstrap failed: $_" "ERROR"
        Write-Log "Check log: $Script:LogFile" "ERROR"
        exit 1
    } finally {
        try { Stop-Transcript } catch { }
    }
}

# Execute
Invoke-WindowsBootstrap
