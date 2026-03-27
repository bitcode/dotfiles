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
    [switch]$AllUsers,
    [switch]$SkipPackages,
    [switch]$SkipDotfiles,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Script:LogFile    = "$env:USERPROFILE\.dotsible\logs\bootstrap_windows_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$Script:StartTime  = Get-Date
$Script:DotfilesRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Script:IsAdmin    = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
$Script:SkipAccounts = @('Default', 'Public', 'defaultuser0', 'defaultuser1', 'All Users', 'TEMP')

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
        "microsoft-windows-terminal"

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
        "lazygit"

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
    if (-not $Script:IsAdmin) {
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
# STEP 5b: NERD FONTS
# Primary method: direct download from GitHub releases (no Scoop needed).
# Falls back to Scoop if available and direct download fails.
# When running as admin, installs system-wide to C:\Windows\Fonts so all
# users get the fonts without per-user registration.
# ============================================================================

# Maps a friendly name to:
#   GithubZip  — zip name in nerd-fonts GitHub releases
#   Filter     — glob to check if already installed in the font dir
$Script:NerdFontDefs = @(
    @{ Name = "JetBrainsMono NF"; GithubZip = "JetBrainsMono.zip"; Filter = "JetBrainsMonoNerd*" }
    @{ Name = "Iosevka NF";       GithubZip = "Iosevka.zip";       Filter = "IosevkaNerd*"       }
)

function Install-FontFile {
    param([string]$FontPath, [string]$SystemFontsDir)
    $ext = [IO.Path]::GetExtension($FontPath).ToLower()
    if ($ext -notin @(".ttf", ".otf")) { return }

    $dest = Join-Path $SystemFontsDir ([IO.Path]::GetFileName($FontPath))
    if (Test-Path $dest) { return }   # already there

    Copy-Item -Path $FontPath -Destination $dest -Force

    # Register in HKLM so all users see the font
    $regName = [IO.Path]::GetFileNameWithoutExtension($FontPath) + " (TrueType)"
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    Set-ItemProperty -Path $regPath -Name $regName -Value ([IO.Path]::GetFileName($FontPath)) -ErrorAction SilentlyContinue
}

function Install-NerdFonts {
    # Determine install target: system-wide if admin, user-level otherwise
    $systemFontsDir = "$env:WINDIR\Fonts"
    $userFontsDir   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $fontsDir       = if ($Script:IsAdmin) { $systemFontsDir } else { $userFontsDir }

    $releaseBase = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
    $tmpBase     = Join-Path $env:TEMP "dotsible-nerdfonts"

    foreach ($fontDef in $Script:NerdFontDefs) {
        # Check if already installed
        $existing = Get-ChildItem -Path $fontsDir -Filter $fontDef.Filter -ErrorAction SilentlyContinue
        if (-not $Script:IsAdmin) {
            # Also check system fonts dir when running as user
            $existing += Get-ChildItem -Path $systemFontsDir -Filter $fontDef.Filter -ErrorAction SilentlyContinue
        }
        if ($existing.Count -gt 0) {
            Write-Log "$($fontDef.Name): already installed ($($existing.Count) files)" "SKIP"
            continue
        }

        if ($DryRun) {
            Write-Log "Would install: $($fontDef.Name) from $releaseBase/$($fontDef.GithubZip)" "INFO"
            continue
        }

        $zipUrl  = "$releaseBase/$($fontDef.GithubZip)"
        $zipPath = Join-Path $tmpBase $fontDef.GithubZip
        $extractDir = Join-Path $tmpBase ([IO.Path]::GetFileNameWithoutExtension($fontDef.GithubZip))

        try {
            Write-Log "Downloading $($fontDef.Name) from GitHub..." "INFO"
            New-Item -ItemType Directory -Path $tmpBase -Force | Out-Null
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            (New-Object Net.WebClient).DownloadFile($zipUrl, $zipPath)

            Write-Log "Extracting $($fontDef.Name)..." "INFO"
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

            Write-Log "Installing $($fontDef.Name) to $fontsDir..." "INFO"
            $fontFiles = Get-ChildItem -Path $extractDir -Recurse -Include "*.ttf","*.otf" |
                            Where-Object { $_.Name -notmatch "Windows Compatible" }
            foreach ($f in $fontFiles) {
                Install-FontFile -FontPath $f.FullName -SystemFontsDir $fontsDir
            }

            $installed = (Get-ChildItem -Path $fontsDir -Filter $fontDef.Filter -ErrorAction SilentlyContinue).Count
            Write-Log "$($fontDef.Name): installed $installed font files" "SUCCESS"

            # Cleanup
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
            Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Log "$($fontDef.Name): download/install failed: $_" "WARN"

            # Fallback to Scoop if available
            if (Get-Command scoop -ErrorAction SilentlyContinue) {
                Write-Log "Trying Scoop fallback for $($fontDef.Name)..." "INFO"
                try {
                    & scoop bucket add nerd-fonts 2>$null
                    & scoop install $fontDef.GithubZip.Replace(".zip","") 2>&1 | Out-Null
                    Write-Log "$($fontDef.Name): installed via Scoop" "SUCCESS"
                } catch {
                    Write-Log "$($fontDef.Name): Scoop fallback also failed" "WARN"
                }
            }
        }
    }

    # Final count
    $jbCount  = (Get-ChildItem -Path $fontsDir -Filter "JetBrainsMonoNerd*" -ErrorAction SilentlyContinue).Count
    $ioCount  = (Get-ChildItem -Path $fontsDir -Filter "IosevkaNerd*"       -ErrorAction SilentlyContinue).Count
    Write-Log "Nerd Fonts in $fontsDir — JetBrainsMono: $jbCount files, Iosevka: $ioCount files" "INFO"
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
            $moduleScope = if ($AllUsers -and $Script:IsAdmin) { "AllUsers" } else { "CurrentUser" }
            Install-Module -Name $module -Force -AllowClobber -Scope $moduleScope -ErrorAction Stop
            Write-Log "$module installed ($moduleScope)" "SUCCESS"
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
    # When -AllUsers: set at Machine scope so all users inherit the values.
    # STARSHIP_CONFIG uses %USERPROFILE% which Windows expands per-user at runtime.
    $envScope = if ($AllUsers -and $Script:IsAdmin) { "Machine" } else { "User" }
    if ($AllUsers -and -not $Script:IsAdmin) {
        Write-Log "AllUsers env vars requested but not admin — falling back to User scope" "WARN"
    }

    foreach ($var in $Script:Config.EnvironmentVars) {
        # For Machine scope, STARSHIP_CONFIG value should use %USERPROFILE% so each
        # user gets their own path when Windows expands the variable.
        $value = $var.Value
        if ($envScope -eq "Machine" -and $var.Name -eq "STARSHIP_CONFIG") {
            $value = "%USERPROFILE%\.config\starship.toml"
        }

        $current = [System.Environment]::GetEnvironmentVariable($var.Name, $envScope)
        if ($current -eq $value) {
            Write-Log "Env $($var.Name) already set ($envScope)" "SKIP"
            continue
        }
        if ($DryRun) {
            Write-Log "Would set env ($envScope): $($var.Name)=$value" "INFO"
            continue
        }
        [System.Environment]::SetEnvironmentVariable($var.Name, $value, $envScope)
        Set-Item -Path "Env:$($var.Name)" -Value $value
        Write-Log "Set env ($envScope): $($var.Name)=$value" "SUCCESS"
    }

    # Registry settings
    # When -AllUsers: apply to each user's hive by loading NTUSER.DAT.
    # Always apply to the current user (HKCU) regardless.
    $regTargets = @()

    # Current user (HKCU) — always apply
    $regTargets += @{ Label = "CurrentUser"; HivePath = $null; HiveKey = $null }

    if ($AllUsers -and $Script:IsAdmin) {
        # Apply to Default User hive (new accounts created later will inherit these settings)
        $defaultHive = "C:\Users\Default\NTUSER.DAT"
        if (Test-Path $defaultHive) {
            $regTargets += @{ Label = "Default"; HivePath = $defaultHive; HiveKey = "HKLM\DOTSIBLE_DEFAULT" }
        }

        # Apply to each existing user's hive (skip the running user — already covered by HKCU)
        $userHomes = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -notin $Script:SkipAccounts } |
                        Where-Object { $_.FullName -ne $env:USERPROFILE }
        foreach ($uhome in $userHomes) {
            $hivePath = Join-Path $uhome.FullName "NTUSER.DAT"
            if (Test-Path $hivePath) {
                $regTargets += @{ Label = $uhome.Name; HivePath = $hivePath; HiveKey = "HKLM\DOTSIBLE_$($uhome.Name)" }
            }
        }
    }

    foreach ($target in $regTargets) {
        $loaded = $false
        $hiveRoot = "HKCU:"   # default: current user's hive

        if ($null -ne $target.HiveKey) {
            if ($DryRun) {
                Write-Log "Would load hive for: $($target.Label)" "INFO"
            } else {
                try {
                    & reg load $target.HiveKey $target.HivePath 2>&1 | Out-Null
                    $loaded = $true
                    # Map the loaded hive to a PS drive for Set-ItemProperty
                    $hiveRoot = "HKLM:\$($target.HiveKey -replace 'HKLM\\','')"
                } catch {
                    Write-Log "Could not load hive for $($target.Label): $_" "WARN"
                    continue
                }
            }
        }

        foreach ($reg in $Script:Config.RegistrySettings) {
            try {
                # Remap HKCU: path to the loaded hive root when processing other users
                $regPath = if ($loaded) {
                    $reg.Path -replace "^HKCU:", $hiveRoot
                } else {
                    $reg.Path
                }

                $current = Get-ItemProperty -Path $regPath -Name $reg.Name -ErrorAction SilentlyContinue
                if ($current -and $current.$($reg.Name) -eq $reg.Value) {
                    Write-Log "[$($target.Label)] Registry $($reg.Name) already set" "SKIP"
                    continue
                }
                if ($DryRun) {
                    Write-Log "[$($target.Label)] Would set registry: $($reg.Name)=$($reg.Value)" "INFO"
                    continue
                }
                if (-not (Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                Set-ItemProperty -Path $regPath -Name $reg.Name -Value $reg.Value -Type $reg.Type
                Write-Log "[$($target.Label)] Set registry: $($reg.Name)=$($reg.Value)" "SUCCESS"
            } catch {
                Write-Log "[$($target.Label)] Registry $($reg.Name) failed: $_" "WARN"
            }
        }

        if ($loaded -and -not $DryRun) {
            try {
                [gc]::Collect()
                & reg unload $target.HiveKey 2>&1 | Out-Null
            } catch {
                Write-Log "Could not unload hive for $($target.Label) — may need manual cleanup" "WARN"
            }
        }
    }
}

# ============================================================================
# STEP 8: DEVELOPMENT DIRECTORIES
# ============================================================================
function New-DevDirectories {
    # Build the list of home directories to create dev dirs for
    $targetHomes = @($env:USERPROFILE)
    if ($AllUsers -and $Script:IsAdmin) {
        $otherHomes = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -notin $Script:SkipAccounts } |
                        Where-Object { $_.FullName -ne $env:USERPROFILE } |
                        ForEach-Object { $_.FullName }
        $targetHomes += $otherHomes
    }

    # The configured dirs use $env:USERPROFILE — strip to relative paths and reapply per home
    $relDirs = $Script:Config.DevDirectories | ForEach-Object {
        $_ -replace [regex]::Escape($env:USERPROFILE), ""
    }

    foreach ($userHome in $targetHomes) {
        $userName = Split-Path -Leaf $userHome
        foreach ($rel in $relDirs) {
            $dir = Join-Path $userHome $rel.TrimStart("\")
            if (Test-Path $dir) {
                Write-Log "[$userName] Directory exists: $dir" "SKIP"
                continue
            }
            if ($DryRun) {
                Write-Log "[$userName] Would create: $dir" "INFO"
                continue
            }
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Log "[$userName] Created: $dir" "SUCCESS"
        }
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
    if ($AllUsers) { $deployArgs["AllUsers"] = $true }
    if ($DryRun)   { $deployArgs["DryRun"]   = $true }
    if ($Force)    { $deployArgs["Force"]     = $true }

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
        Write-Log "Environment:  $EnvironmentType" "INFO"
        Write-Log "Dotfiles root: $Script:DotfilesRoot" "INFO"
        Write-Log "Running as admin: $Script:IsAdmin" "INFO"
        if ($AllUsers) {
            if ($Script:IsAdmin) {
                Write-Log "All-users mode: deploying to all user accounts + system-wide settings" "INFO"
            } else {
                Write-Log "All-users mode requested but NOT running as Administrator — some steps will be limited" "WARN"
                Write-Log "Re-run as Administrator for full multi-user deployment (Machine env vars, AllUsers PS modules, cross-user registry)" "WARN"
            }
        }
        if ($DryRun)      { Write-Log "DRY RUN - no changes will be made" "WARN" }
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
