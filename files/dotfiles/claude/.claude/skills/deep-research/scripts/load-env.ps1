# Loads ~/.claude/.env.research into the current PowerShell session.
# Dot-source this script: . "$HOME\.claude\skills\deep-research\scripts\load-env.ps1"
# Skips blank lines and comments. Does not overwrite already-set vars unless -Force.

[CmdletBinding()]
param(
    [switch]$Force,
    [string]$Path = (Join-Path $HOME '.claude\.env.research')
)

if (-not (Test-Path $Path)) {
    Write-Error "Credentials file not found: $Path. Copy the template from the skill README."
    return
}

Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if (-not $line -or $line.StartsWith('#')) { return }
    $eq = $line.IndexOf('=')
    if ($eq -lt 1) { return }
    $name = $line.Substring(0, $eq).Trim()
    $value = $line.Substring($eq + 1).Trim().Trim('"').Trim("'")
    $current = [Environment]::GetEnvironmentVariable($name, 'Process')
    if ($Force -or -not $current) {
        Set-Item -Path "Env:$name" -Value $value
    }
}

if (-not $env:FIRECRAWL_API_KEY) {
    Write-Warning 'FIRECRAWL_API_KEY is empty after loading .env.research'
}
