#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy dotfiles to Windows target locations.

.DESCRIPTION
    Replaces GNU Stow on Windows. Copies dotfiles from files/dotfiles/ to their
    correct Windows locations, with backup support and symlink option.

    Dotfile mapping (Stow source -> Windows target):
      nvim/.config/nvim/        -> $env:LOCALAPPDATA\nvim\
      alacritty/.config/alacritty/ -> $env:APPDATA\alacritty\
      windows-terminal/settings.json -> $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_...\LocalState\settings.json
      starship/.config/starship.toml -> $HOME\.config\starship.toml
      claude/.claude/           -> $HOME\.claude\
      vscode/settings.json      -> $env:APPDATA\Code\User\settings.json
      vscode/antigravity-settings.json -> $env:APPDATA\Antigravity\User\settings.json
      vim/.vimrc                -> $HOME\.vimrc

    With -AllUsers, deploys to all user home directories and installs a
    system-wide PowerShell profile. Requires admin for cross-user directories.

.PARAMETER DotfilesRoot
    Path to the dotfiles repo root. Defaults to the parent of the scripts/ directory.

.PARAMETER AllUsers
    Deploy dotfiles to all user home directories under C:\Users\ (requires admin).
    Also installs system-wide PowerShell profiles.

.PARAMETER UseSymlinks
    Use directory junctions/symlinks instead of copying. Requires admin for some targets.

.PARAMETER DryRun
    Show what would be deployed without making changes.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\deploy_dotfiles_windows.ps1
    .\deploy_dotfiles_windows.ps1 -AllUsers
    .\deploy_dotfiles_windows.ps1 -UseSymlinks
    .\deploy_dotfiles_windows.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [string]$DotfilesRoot,
    [switch]$AllUsers,
    [switch]$UseSymlinks,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Resolve dotfiles root
if (-not $DotfilesRoot) {
    $DotfilesRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
}
$SourceBase = Join-Path $DotfilesRoot "files\dotfiles"

# Backup directory (rooted at the running user's profile)
$BackupDir = Join-Path $env:USERPROFILE ".dotsible\backups\dotfiles_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# System accounts to skip when enumerating user homes
$Script:SkipAccounts = @('Default', 'Public', 'defaultuser0', 'defaultuser1', 'All Users', 'TEMP')

# ============================================================================
# LOGGING
# ============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{ "INFO" = "Cyan"; "SUCCESS" = "Green"; "WARN" = "Yellow"; "ERROR" = "Red"; "SKIP" = "DarkGray" }
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

# ============================================================================
# HELPERS
# ============================================================================
function Get-WindowsUserHomes {
    <#
    .SYNOPSIS
        Returns all real user home directories under C:\Users\,
        excluding system accounts (Default, Public, etc.).
    #>
    Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notin $Script:SkipAccounts } |
        ForEach-Object { $_.FullName }
}

function Backup-Item {
    param([string]$Path)
    if (Test-Path $Path) {
        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        }
        # Strip drive letter (e.g. "C:") so the path is safe to nest under BackupDir
        $relativePath = $Path -replace '^[A-Za-z]:', '' | ForEach-Object { $_.TrimStart("\") }
        $backupTarget = Join-Path $BackupDir $relativePath
        $backupParent = Split-Path -Parent $backupTarget
        if (-not (Test-Path $backupParent)) {
            New-Item -ItemType Directory -Path $backupParent -Force | Out-Null
        }
        if ((Get-Item $Path).PSIsContainer) {
            Copy-Item -Path $Path -Destination $backupTarget -Recurse -Force
        } else {
            Copy-Item -Path $Path -Destination $backupTarget -Force
        }
        Write-Log "Backed up: $Path" "INFO"
        return $true
    }
    return $false
}

function Deploy-Directory {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Name
    )

    if (-not (Test-Path $Source)) {
        Write-Log "${Name}: source not found at $Source" "SKIP"
        return
    }

    if ($DryRun) {
        Write-Log "${Name}: would deploy $Source -> $Target" "INFO"
        return
    }

    # Back up existing target
    if (Test-Path $Target) {
        # Check if it's already a symlink/junction pointing to our source
        $item = Get-Item $Target -Force -ErrorAction SilentlyContinue
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $linkTarget = $item.Target
            if ($linkTarget -eq $Source) {
                Write-Log "${Name}: already linked correctly" "SUCCESS"
                return
            }
        }

        if (-not $Force) {
            Write-Log "${Name}: target exists at $Target (use -Force to overwrite)" "WARN"
            return
        }
        Backup-Item -Path $Target
    }

    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    if ($UseSymlinks) {
        if (Test-Path $Target) {
            Remove-Item -Path $Target -Recurse -Force
        }
        try {
            New-Item -ItemType Junction -Path $Target -Target $Source -Force | Out-Null
            Write-Log "${Name}: linked $Target -> $Source" "SUCCESS"
        } catch {
            Write-Log "${Name}: junction failed, falling back to copy: $_" "WARN"
            Copy-Item -Path $Source -Destination $Target -Recurse -Force
            Write-Log "${Name}: copied $Source -> $Target" "SUCCESS"
        }
    } else {
        if (Test-Path $Target) {
            Remove-Item -Path $Target -Recurse -Force
        }
        Copy-Item -Path $Source -Destination $Target -Recurse -Force
        Write-Log "${Name}: copied -> $Target" "SUCCESS"
    }
}

function Deploy-File {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Name
    )

    if (-not (Test-Path $Source)) {
        Write-Log "${Name}: source not found at $Source" "SKIP"
        return
    }

    if ($DryRun) {
        Write-Log "${Name}: would deploy $Source -> $Target" "INFO"
        return
    }

    if (Test-Path $Target) {
        if (-not $Force) {
            Write-Log "${Name}: target exists at $Target (use -Force to overwrite)" "WARN"
            return
        }
        Backup-Item -Path $Target
    }

    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }

    if ($UseSymlinks) {
        if (Test-Path $Target) { Remove-Item $Target -Force }
        try {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
            Write-Log "${Name}: linked $Target -> $Source" "SUCCESS"
        } catch {
            Copy-Item -Path $Source -Destination $Target -Force
            Write-Log "${Name}: symlink failed, copied instead" "WARN"
        }
    } else {
        Copy-Item -Path $Source -Destination $Target -Force
        Write-Log "${Name}: copied -> $Target" "SUCCESS"
    }
}

# ============================================================================
# PER-USER DEPLOYMENT
# Deploys all dotfiles relative to a given user's home directory.
# $UserHome — e.g. C:\Users\mdrozrosario or C:\Users\adminmedr
# ============================================================================
function Deploy-DotfilesToHome {
    param([string]$UserHome)

    $UserName       = Split-Path -Leaf $UserHome
    $UserLocalApp   = Join-Path $UserHome "AppData\Local"
    $UserRoaming    = Join-Path $UserHome "AppData\Roaming"
    $UserDocuments  = Join-Path $UserHome "Documents"
    $UserConfig     = Join-Path $UserHome ".config"

    Write-Host ""
    Write-Host "  -- User: $UserName ($UserHome)" -ForegroundColor White

    # --- Neovim ---
    $nvimSource = Join-Path $SourceBase "nvim\.config\nvim"
    $nvimTarget = Join-Path $UserLocalApp "nvim"
    Deploy-Directory -Source $nvimSource -Target $nvimTarget -Name "[$UserName] Neovim"

    # --- Alacritty ---
    $alacrittySource = Join-Path $SourceBase "alacritty\.config\alacritty"
    $alacrittyTarget = Join-Path $UserRoaming "alacritty"
    Deploy-Directory -Source $alacrittySource -Target $alacrittyTarget -Name "[$UserName] Alacritty"
    if (-not $DryRun -and (Test-Path $alacrittyTarget)) {
        Write-Log "[$UserName] Alacritty: Windows override available at alacritty-windows.toml (add to [general].import)" "INFO"
    }

    # --- lsd ---
    $lsdSource        = Join-Path $SourceBase "lsd\.config\lsd\config.yaml"
    $lsdXdgTarget     = Join-Path $UserConfig  "lsd\config.yaml"
    $lsdAppDataTarget = Join-Path $UserRoaming "lsd\config.yaml"
    Deploy-File -Source $lsdSource -Target $lsdXdgTarget     -Name "[$UserName] lsd (XDG)"
    Deploy-File -Source $lsdSource -Target $lsdAppDataTarget -Name "[$UserName] lsd (AppData)"

    # --- Starship ---
    $starshipSource = Join-Path $SourceBase "starship\.config\starship.toml"
    $starshipTarget = Join-Path $UserConfig "starship.toml"
    Deploy-File -Source $starshipSource -Target $starshipTarget -Name "[$UserName] Starship"

    # --- Claude ---
    $claudeSource = Join-Path $SourceBase "claude\.claude"
    $claudeTarget = Join-Path $UserHome ".claude"
    $claudeFiles  = @("CLAUDE.md", "settings.json", "statusline.ps1", "statusline.sh", "file-suggest.sh")
    foreach ($file in $claudeFiles) {
        $src = Join-Path $claudeSource $file
        $tgt = Join-Path $claudeTarget $file
        Deploy-File -Source $src -Target $tgt -Name "[$UserName] Claude/$file"
    }

    # --- Windows Terminal ---
    # The WindowsTerminal package dir uses a wildcard, so resolve it per user
    $wtSource    = Join-Path $SourceBase "windows-terminal\settings.json"
    $wtPackages  = Join-Path $UserLocalApp "Packages"
    $wtPackage   = Get-ChildItem $wtPackages -Filter "Microsoft.WindowsTerminal_*" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wtPackage) {
        $wtTarget = Join-Path $wtPackage.FullName "LocalState\settings.json"
        Deploy-File -Source $wtSource -Target $wtTarget -Name "[$UserName] Windows Terminal"
    } else {
        Write-Log "[$UserName] Windows Terminal: package directory not found (app may not be installed for this user)" "SKIP"
    }

    # --- VSCode ---
    $vscodeSource = Join-Path $SourceBase "vscode\settings.json"
    $vscodeTarget = Join-Path $UserRoaming "Code\User\settings.json"
    Deploy-File -Source $vscodeSource -Target $vscodeTarget -Name "[$UserName] VSCode"

    # --- Antigravity (VSCode wrapper) ---
    $antigravitySource = Join-Path $SourceBase "vscode\antigravity-settings.json"
    $antigravityTarget = Join-Path $UserRoaming "Antigravity\User\settings.json"
    Deploy-File -Source $antigravitySource -Target $antigravityTarget -Name "[$UserName] Antigravity"

    # --- Vim ---
    $vimSource = Join-Path $SourceBase "vim\.vimrc"
    $vimTarget = Join-Path $UserHome ".vimrc"
    Deploy-File -Source $vimSource -Target $vimTarget -Name "[$UserName] Vim"

    # --- PowerShell Profile (user-level) ---
    $profileSource       = Join-Path $SourceBase "powershell\Microsoft.PowerShell_profile.ps1"
    $pwshAllHostsTarget  = Join-Path $UserDocuments "PowerShell\profile.ps1"
    $ps5AllHostsTarget   = Join-Path $UserDocuments "WindowsPowerShell\profile.ps1"
    $pwshProfileTarget   = Join-Path $UserDocuments "PowerShell\Microsoft.PowerShell_profile.ps1"
    $ps5ProfileTarget    = Join-Path $UserDocuments "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    Deploy-File -Source $profileSource -Target $pwshAllHostsTarget -Name "[$UserName] PS7 AllHosts Profile"
    Deploy-File -Source $profileSource -Target $pwshProfileTarget  -Name "[$UserName] PS7 Profile"
    Deploy-File -Source $profileSource -Target $ps5AllHostsTarget  -Name "[$UserName] PS5.1 AllHosts Profile"
    Deploy-File -Source $profileSource -Target $ps5ProfileTarget   -Name "[$UserName] PS5.1 Profile"

    # --- Scripts (Windows-compatible only) ---
    $scriptsSource = Join-Path $SourceBase "scripts"
    $scriptsTarget = Join-Path $UserHome ".local\bin"
    if (Test-Path $scriptsSource) {
        $windowsScripts = Get-ChildItem -Path $scriptsSource -File | Where-Object {
            $_.Extension -in @(".ps1", ".py", ".bat", ".cmd")
        }
        foreach ($script in $windowsScripts) {
            Deploy-File -Source $script.FullName -Target (Join-Path $scriptsTarget $script.Name) -Name "[$UserName] Scripts/$($script.Name)"
        }
    }
}

# ============================================================================
# SYSTEM-WIDE POWERSHELL PROFILES
# Deploys to $PSHOME so the profile loads for every user automatically,
# regardless of whether their personal Documents\PowerShell directory is set up.
# Requires admin.
# ============================================================================
function Deploy-SystemWideProfiles {
    $profileSource = Join-Path $SourceBase "powershell\Microsoft.PowerShell_profile.ps1"

    if (-not (Test-Path $profileSource)) {
        Write-Log "System-wide PS profile: source not found" "SKIP"
        return
    }

    # PowerShell 7 (pwsh) system profile — typically C:\Program Files\PowerShell\7\
    # Only consider numeric version directories (e.g. "7", "7.4") — skip "Scripts", "Modules", etc.
    $ps7Homes = Get-ChildItem "$env:ProgramFiles\PowerShell" -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -match '^\d' } |
                    Sort-Object { [double]($_.Name -replace '[^\d].*','') } -Descending |
                    Select-Object -First 1
    if ($ps7Homes) {
        $ps7AllUsers = Join-Path $ps7Homes.FullName "profile.ps1"
        Deploy-File -Source $profileSource -Target $ps7AllUsers -Name "[System] PS7 AllUsers Profile"
    } else {
        Write-Log "[System] PS7 not found at $env:ProgramFiles\PowerShell — skipping system-wide PS7 profile" "SKIP"
    }

    # PowerShell 5.1 system profile
    $ps5AllUsers = "$env:WINDIR\System32\WindowsPowerShell\v1.0\profile.ps1"
    Deploy-File -Source $profileSource -Target $ps5AllUsers -Name "[System] PS5.1 AllUsers Profile"
}

# ============================================================================
# MAIN
# ============================================================================
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dotsible - Windows Dotfile Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Source:    $SourceBase" -ForegroundColor DarkGray
Write-Host "  Mode:      $(if ($UseSymlinks) { 'Symlinks/Junctions' } else { 'Copy' })" -ForegroundColor DarkGray
Write-Host "  All Users: $AllUsers" -ForegroundColor DarkGray
Write-Host "  Dry Run:   $DryRun" -ForegroundColor DarkGray
Write-Host "  Force:     $Force" -ForegroundColor DarkGray
Write-Host ""

if ($DryRun) {
    Write-Log "DRY RUN - no changes will be made" "WARN"
    Write-Host ""
}

if ($AllUsers -and -not $isAdmin) {
    Write-Log "WARNING: -AllUsers specified but not running as Administrator." "WARN"
    Write-Log "Cross-user directory access may fail. Re-run as Administrator for full multi-user deployment." "WARN"
    Write-Host ""
}

if ($AllUsers) {
    $userHomes = Get-WindowsUserHomes
    Write-Log "Found $($userHomes.Count) user(s): $($userHomes | ForEach-Object { Split-Path -Leaf $_ } | Join-String -Separator ', ')" "INFO"

    foreach ($userHome in $userHomes) {
        Deploy-DotfilesToHome -UserHome $userHome
    }

    Write-Host ""
    Write-Host "  -- System-wide PowerShell profiles" -ForegroundColor White
    Deploy-SystemWideProfiles
} else {
    Deploy-DotfilesToHome -UserHome $env:USERPROFILE
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if (Test-Path $BackupDir) {
    Write-Host ""
    Write-Host "  Backups saved to: $BackupDir" -ForegroundColor Yellow
}

Write-Host ""

# Linux-only dotfiles (not deployed on Windows)
$skippedApps = @(
    "compton", "cron", "dockerfiles", "etc", "hyprCaps2Esc", "hyprland",
    "i3", "i3blocks", "kitty", "nixos", "picom", "polybar", "rofi",
    "swaync", "systemd", "udevmonCaps2Esc", "walls", "waybar", "weston",
    "wofi", "zsh", "tmux", "zellij", "sesh", "ranger", "radare2",
    "markdown", "prompts", "docs"
)
Write-Log "Skipped Linux-only apps: $($skippedApps.Count) apps" "SKIP"
Write-Host ""
