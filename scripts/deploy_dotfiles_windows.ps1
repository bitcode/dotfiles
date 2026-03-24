#Requires -Version 5.1
<#
.SYNOPSIS
    Deploy dotfiles to Windows target locations.

.DESCRIPTION
    Replaces GNU Stow on Windows. Copies dotfiles from files/dotfiles/ to their
    correct Windows locations, with backup support and symlink option.

    Dotfile mapping (Stow source → Windows target):
      nvim/.config/nvim/        → $env:LOCALAPPDATA\nvim\
      alacritty/.config/alacritty/ → $env:APPDATA\alacritty\
      windows-terminal/settings.json → $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_...\LocalState\settings.json
      starship/.config/starship.toml → $HOME\.config\starship.toml
      claude/.claude/           → $HOME\.claude\
      vscode/settings.json      → $env:APPDATA\Code\User\settings.json
      vscode/antigravity-settings.json → $env:APPDATA\Antigravity\User\settings.json
      vim/.vimrc                → $HOME\.vimrc

.PARAMETER DotfilesRoot
    Path to the dotfiles repo root. Defaults to the parent of the scripts/ directory.

.PARAMETER UseSymlinks
    Use directory junctions/symlinks instead of copying. Requires admin for some targets.

.PARAMETER DryRun
    Show what would be deployed without making changes.

.PARAMETER Force
    Overwrite existing files without prompting.

.EXAMPLE
    .\deploy_dotfiles_windows.ps1
    .\deploy_dotfiles_windows.ps1 -UseSymlinks
    .\deploy_dotfiles_windows.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [string]$DotfilesRoot,
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

# Backup directory
$BackupDir = Join-Path $env:USERPROFILE ".dotsible\backups\dotfiles_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

# Logging
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{ "INFO" = "Cyan"; "SUCCESS" = "Green"; "WARN" = "Yellow"; "ERROR" = "Red"; "SKIP" = "DarkGray" }
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $colors[$Level]
}

function Backup-Item {
    param([string]$Path)
    if (Test-Path $Path) {
        if (-not (Test-Path $BackupDir)) {
            New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        }
        $relativePath = $Path.Replace($env:USERPROFILE, "").TrimStart("\")
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
        # Remove existing target to create fresh link
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
# Dotfile deployment map
# ============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Dotsible - Windows Dotfile Deployment" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Source:    $SourceBase" -ForegroundColor DarkGray
Write-Host "  Mode:      $(if ($UseSymlinks) { 'Symlinks/Junctions' } else { 'Copy' })" -ForegroundColor DarkGray
Write-Host "  Dry Run:   $DryRun" -ForegroundColor DarkGray
Write-Host "  Force:     $Force" -ForegroundColor DarkGray
Write-Host ""

if ($DryRun) {
    Write-Log "DRY RUN - no changes will be made" "WARN"
    Write-Host ""
}

# --- Neovim ---
$nvimSource = Join-Path $SourceBase "nvim\.config\nvim"
$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
Deploy-Directory -Source $nvimSource -Target $nvimTarget -Name "Neovim"

# --- Alacritty ---
# Deploy the main config, then note the Windows override file
$alacrittySource = Join-Path $SourceBase "alacritty\.config\alacritty"
$alacrittyTarget = Join-Path $env:APPDATA "alacritty"
Deploy-Directory -Source $alacrittySource -Target $alacrittyTarget -Name "Alacritty"
# Remind about Windows override (alacritty-windows.toml ships in the dir)
if (-not $DryRun -and (Test-Path $alacrittyTarget)) {
    Write-Log "Alacritty: Windows override available at alacritty-windows.toml (add to [general].import)" "INFO"
}

# --- lsd ---
$lsdSource = Join-Path $SourceBase "lsd\.config\lsd\config.yaml"
$lsdXdgTarget = Join-Path $env:USERPROFILE ".config\lsd\config.yaml"
$lsdAppDataTarget = Join-Path $env:APPDATA "lsd\config.yaml"
Deploy-File -Source $lsdSource -Target $lsdXdgTarget -Name "lsd (XDG)"
Deploy-File -Source $lsdSource -Target $lsdAppDataTarget -Name "lsd (AppData)"

# --- Starship ---
$starshipSource = Join-Path $SourceBase "starship\.config\starship.toml"
$starshipTarget = Join-Path $env:USERPROFILE ".config\starship.toml"
Deploy-File -Source $starshipSource -Target $starshipTarget -Name "Starship"

# --- Claude ---
$claudeSource = Join-Path $SourceBase "claude\.claude"
$claudeTarget = Join-Path $env:USERPROFILE ".claude"
# Claude is special — we deploy individual files, not the whole dir (user may have local state)
$claudeFiles = @("CLAUDE.md", "settings.json", "statusline.ps1", "statusline.sh", "file-suggest.sh")
foreach ($file in $claudeFiles) {
    $src = Join-Path $claudeSource $file
    $tgt = Join-Path $claudeTarget $file
    Deploy-File -Source $src -Target $tgt -Name "Claude/$file"
}

# --- Windows Terminal ---
$wtSource = Join-Path $SourceBase "windows-terminal\settings.json"
$wtTarget = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Deploy-File -Source $wtSource -Target $wtTarget -Name "Windows Terminal"

# --- VSCode ---
$vscodeSource = Join-Path $SourceBase "vscode\settings.json"
$vscodeTarget = Join-Path $env:APPDATA "Code\User\settings.json"
Deploy-File -Source $vscodeSource -Target $vscodeTarget -Name "VSCode"

# --- Antigravity (VSCode wrapper) ---
$antigravitySource = Join-Path $SourceBase "vscode\antigravity-settings.json"
$antigravityTarget = Join-Path $env:APPDATA "Antigravity\User\settings.json"
Deploy-File -Source $antigravitySource -Target $antigravityTarget -Name "Antigravity"

# --- Vim ---
$vimSource = Join-Path $SourceBase "vim\.vimrc"
$vimTarget = Join-Path $env:USERPROFILE ".vimrc"
Deploy-File -Source $vimSource -Target $vimTarget -Name "Vim"

# --- PowerShell Profile ---
$profileSource = Join-Path $SourceBase "powershell\Microsoft.PowerShell_profile.ps1"
# AllHosts profile (loads in every host: terminal, VS Code, ISE, etc.)
$pwshAllHostsTarget = Join-Path $env:USERPROFILE "Documents\PowerShell\profile.ps1"
$ps5AllHostsTarget = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\profile.ps1"
# CurrentHost profiles (standard terminal only)
$pwshProfileTarget = Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ps5ProfileTarget = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
Deploy-File -Source $profileSource -Target $pwshAllHostsTarget -Name "PowerShell 7 AllHosts Profile"
Deploy-File -Source $profileSource -Target $pwshProfileTarget -Name "PowerShell 7 Profile"
Deploy-File -Source $profileSource -Target $ps5AllHostsTarget -Name "PowerShell 5.1 AllHosts Profile"
Deploy-File -Source $profileSource -Target $ps5ProfileTarget -Name "PowerShell 5.1 Profile"

# --- Scripts (Windows-compatible only) ---
$scriptsSource = Join-Path $SourceBase "scripts"
$scriptsTarget = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $scriptsSource) {
    # Only deploy .ps1 files and .py files (Windows-compatible)
    $windowsScripts = Get-ChildItem -Path $scriptsSource -File | Where-Object {
        $_.Extension -in @(".ps1", ".py", ".bat", ".cmd")
    }
    foreach ($script in $windowsScripts) {
        Deploy-File -Source $script.FullName -Target (Join-Path $scriptsTarget $script.Name) -Name "Scripts/$($script.Name)"
    }
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Targets:" -ForegroundColor White
Write-Host "    Neovim:    $nvimTarget" -ForegroundColor DarkGray
Write-Host "    Alacritty: $alacrittyTarget" -ForegroundColor DarkGray
Write-Host "    WinTerm:   $wtTarget" -ForegroundColor DarkGray
Write-Host "    Starship:  $starshipTarget" -ForegroundColor DarkGray
Write-Host "    Claude:    $claudeTarget" -ForegroundColor DarkGray
Write-Host "    VSCode:    $vscodeTarget" -ForegroundColor DarkGray
Write-Host "    Antigrav:  $antigravityTarget" -ForegroundColor DarkGray
Write-Host "    Vim:       $vimTarget" -ForegroundColor DarkGray
Write-Host "    PS Profile: $pwshProfileTarget" -ForegroundColor DarkGray
Write-Host "    Scripts:   $scriptsTarget" -ForegroundColor DarkGray

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
