# ============================================================================
# DOTSIBLE - PowerShell Profile (Windows equivalent of .zshrc)
# ============================================================================
# Deployed by: scripts/deploy_dotfiles_windows.ps1
# Target:      $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"
$env:LANG = "en_US.UTF-8"

# XDG Base Directory Specification (Windows-adapted)
if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = "$HOME\.config" }
if (-not $env:XDG_DATA_HOME)   { $env:XDG_DATA_HOME = "$HOME\.local\share" }
if (-not $env:XDG_CACHE_HOME)  { $env:XDG_CACHE_HOME = "$HOME\.cache" }
if (-not $env:XDG_STATE_HOME)  { $env:XDG_STATE_HOME = "$HOME\.local\state" }

# Create XDG directories if they don't exist
foreach ($dir in @($env:XDG_CONFIG_HOME, $env:XDG_DATA_HOME, $env:XDG_CACHE_HOME, $env:XDG_STATE_HOME)) {
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# Development environment
$env:GO111MODULE = "on"
$env:GOPATH = "$HOME\go"
$env:PYTHONDONTWRITEBYTECODE = "1"
$env:PYTHONUNBUFFERED = "1"
$env:DOCKER_BUILDKIT = "1"
$env:COMPOSE_DOCKER_CLI_BUILD = "1"

# ============================================================================
# PATH ADDITIONS
# ============================================================================
$pathAdditions = @(
    "$HOME\.cargo\bin",
    "$HOME\.local\bin",
    "$HOME\go\bin",
    "$HOME\bin",
    "$HOME\scoop\shims",
    "C:\tools\neovim\nvim-win64\bin"
)
foreach ($p in $pathAdditions) {
    if ((Test-Path $p) -and ($env:PATH -notlike "*$p*")) {
        $env:PATH = "$p;$env:PATH"
    }
}

# ============================================================================
# PSREADLINE CONFIGURATION
# ============================================================================
# PS7 auto-loads PSReadLine; on PS5.1 import only if not already present
if (-not (Get-Module PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
}
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -EditMode Vi
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 50000
    Set-PSReadLineOption -HistoryNoDuplicates

    # Prediction — PS7+ only
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
        Set-PSReadLineOption -Colors @{ InlinePrediction = [ConsoleColor]::DarkGray } -ErrorAction SilentlyContinue
    }

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord "Ctrl+r" -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Chord "Ctrl+f" -Function ForwardWord
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        Set-PSReadLineKeyHandler -Chord "Ctrl+j" -Function AcceptSuggestion
    }
}

# ============================================================================
# MODULES
# ============================================================================
# Direct imports — avoids the slow Get-Module -ListAvailable filesystem scan
Import-Module posh-git      -ErrorAction SilentlyContinue
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
Import-Module PSFzf          -ErrorAction SilentlyContinue

if (Get-Module PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    $env:FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"
    $env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
    $env:FZF_ALT_C_COMMAND   = "fd --type d --hidden --follow --exclude .git"
}

# ============================================================================
# ALIASES (equivalent to .zshrc aliases)
# ============================================================================

# Enhanced ls/dir (lsd if available — provides Nerd Font icons in listings)
# Remove built-in ls/dir aliases first so our functions take effect cleanly
@('ls', 'dir') | ForEach-Object {
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        Remove-Alias -Name $_ -Force -ErrorAction SilentlyContinue
    } else {
        Remove-Item "Alias:$_" -Force -ErrorAction SilentlyContinue
    }
}

if (Get-Command lsd -ErrorAction SilentlyContinue) {
    function ls  { lsd --icon never @args }
    function dir { lsd --icon never -la @args }
    function l   { lsd --icon never -l @args }
    function la  { lsd --icon never -la @args }
    function ll  { lsd --icon never -la @args }
    function lt  { lsd --icon never --tree @args }
} else {
    function ls  { Get-ChildItem @args }
    function dir { Get-ChildItem -Force @args }
    function l   { Get-ChildItem @args }
    function la  { Get-ChildItem -Force @args }
    function ll  { Get-ChildItem -Force @args | Format-Table Mode, LastWriteTime, Length, Name }
}

# Enhanced cat (bat if available)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope -Force
    function catn { bat --style=plain @args }
}

# Git aliases
Set-Alias -Name lg -Value lazygit -ErrorAction SilentlyContinue
function gs  { git status @args }
function gd  { git diff @args }
function gl  { git log --oneline -20 @args }
function gp  { git push @args }
function gpl { git pull @args }

# Navigation
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Common shortcuts
Set-Alias -Name c -Value Clear-Host
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue
function dc { Set-Location .. }
function path { $env:PATH -split ";" | ForEach-Object { $_ } }
function myip { (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content.Trim() }

# ============================================================================
# UTILITY FUNCTIONS (equivalent to .zshrc functions)
# ============================================================================

# Create directory and cd into it
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

# Quick backup
function backup {
    param([string]$Path)
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item $Path "$Path.bak-$timestamp"
}

# Weather
function weather {
    param([string]$Location = "")
    (Invoke-WebRequest -Uri "https://wttr.in/$Location" -UseBasicParsing).Content
}

# Quick note
function note {
    $text = $args -join " "
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path "$HOME\notes.txt" -Value "${timestamp}: $text"
}

function notes {
    if (Test-Path "$HOME\notes.txt") { Get-Content "$HOME\notes.txt" }
    else { Write-Host "No notes found. Use 'note <text>' to create one." }
}

# Git functions
function gclone {
    param([string]$Url)
    git clone $Url
    $repoName = [System.IO.Path]::GetFileNameWithoutExtension($Url)
    Set-Location $repoName
}

function gcommit {
    param([string]$Message)
    git add .
    git commit -m $Message
}

function gpush {
    param([string]$Message)
    git add .
    git commit -m $Message
    git push
}

# Python venv helper
function venv {
    param(
        [ValidateSet("create", "activate", "deactivate")]
        [string]$Action,
        [string]$Name = "venv"
    )
    switch ($Action) {
        "create"     { python -m venv $Name }
        "activate"   { & ".\$Name\Scripts\Activate.ps1" }
        "deactivate" { deactivate }
        default      { Write-Host "Usage: venv {create|activate|deactivate} [name]" }
    }
}

# Docker helpers
function dps { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function dexec {
    param([string]$Container)
    docker exec -it $Container /bin/bash
}

# System info
function sysinfo {
    Write-Host "System Information:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host "Hostname:     $env:COMPUTERNAME"
    Write-Host "OS:           $([System.Environment]::OSVersion.VersionString)"
    Write-Host "Architecture: $env:PROCESSOR_ARCHITECTURE"
    Write-Host "User:         $env:USERNAME"
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "Memory:       $([math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1))GB / $([math]::Round($os.TotalVisibleMemorySize / 1MB, 1))GB"
    Write-Host "Uptime:       $((Get-Date) - $os.LastBootUpTime)"
}

# Quick HTTP server
function serve {
    param([int]$Port = 8000)
    python -m http.server $Port
}

# Edit configs
function Edit-Profile { nvim $PROFILE }
function Edit-Nvim    { nvim "$env:LOCALAPPDATA\nvim\init.lua" }
Set-Alias -Name profileconfig -Value Edit-Profile
Set-Alias -Name nvimconfig -Value Edit-Nvim

# ============================================================================
# STARSHIP PROMPT
# ============================================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ============================================================================
# ZOXIDE (smart cd)
# ============================================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}

# ============================================================================
# COMPLETIONS
# ============================================================================
# Git completions (via posh-git, loaded above)

# dotnet completions
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# winget completions
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        winget complete --word="$wordToComplete" --commandline "$commandAst" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}
