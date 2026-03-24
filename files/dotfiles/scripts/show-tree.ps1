function Show-Tree {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, Position=0)]
        [string]$Path = '.',

        [Parameter()]
        [string[]]$ExcludeDirs = @('.venv', 'lib', 'include', 'site-packages', '__pycache__', '.git', 'node_modules'),

        [Parameter()]
        [switch]$ShowFiles,

        [Parameter()]
        [switch]$ShowSize = $false
    )

    # Set ShowFiles to true by default if not explicitly set to false
    if (-not $PSBoundParameters.ContainsKey('ShowFiles')) {
        $ShowFiles = $true
    }

    # Store parameters in script scope for use in nested function
    $script:ShowFiles = $ShowFiles
    $script:ShowSize = $ShowSize

    # Compile the exclusion list into a single regex pattern.
    $regexExclude = $ExcludeDirs -join '|'
    $script:regex = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList "\\($regexExclude)\\"

    # Helper function to perform the recursion.
    function Get-Tree(
        [string]$targetDir,
        [string]$indent
    ) {
        # Get items, but filter out any matching the exclusion regex.
        try {
            $items = Get-ChildItem -Path $targetDir -Force -ErrorAction Stop | Where-Object {
                -not $script:regex.IsMatch($_.FullName)
            }
        } catch {
            # Handle potential access denied errors gracefully.
            Write-Warning "Could not access '$targetDir'. Skipping."
            return
        }

        # Filter to show only directories if ShowFiles is false
        if (-not $script:ShowFiles) {
            $items = $items | Where-Object { $_.PSIsContainer }
        }

        $lastItem = if ($items -and $items.Count -gt 0) { $items[-1] } else { $null }

        foreach ($item in $items) {
            $isLast = ($null -ne $lastItem) -and ($item.FullName -eq $lastItem.FullName)
            if ($isLast) {
                $prefix = "$([char]0x2514)$([char]0x2500)$([char]0x2500) "
            } else {
                $prefix = "$([char]0x251C)$([char]0x2500)$([char]0x2500) "
            }
            
            $suffix = ''
            if ($script:ShowSize -and -not $item.PSIsContainer) {
                $size = $item.Length
                if ($size -ge 1GB) { $suffix = " ($([math]::Round($size / 1GB, 2)) GB)" }
                elseif ($size -ge 1MB) { $suffix = " ($([math]::Round($size / 1MB, 2)) MB)" }
                elseif ($size -ge 1KB) { $suffix = " ($([math]::Round($size / 1KB, 2)) KB)" }
                else { $suffix = " ($size B)" }
            }

            Write-Output "$indent$prefix$($item.Name)$suffix"

            if ($item.PSIsContainer) {
                if ($isLast) {
                    $newIndent = $indent + '    '
                } else {
                    $newIndent = $indent + "$([char]0x2502)   "
                }
                Get-Tree -targetDir $item.FullName -indent $newIndent
            }
        }
    }

    # Initial call to the recursive helper function.
    $resolvedPath = Resolve-Path -Path $Path
    Write-Output $resolvedPath.Path
    Get-Tree -targetDir $resolvedPath.Path -indent ''
}
