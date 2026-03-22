# ─────────────────────────────────────────────────────────────────────────────
# Claude Code — Powerline Statusline (Windows PowerShell)
# ─────────────────────────────────────────────────────────────────────────────

$json = [Console]::In.ReadToEnd()
try { $d = $json | ConvertFrom-Json } catch { $d = @{} }

function gv($obj, $path) {
    $parts = $path -split '\.'
    $v = $obj
    foreach ($p in $parts) {
        if ($v -is [PSCustomObject] -and $v.PSObject.Properties[$p]) {
            $v = $v.$p
        } else { return '' }
    }
    return if ($null -eq $v) { '' } else { "$v" }
}

$vimMode   = gv $d 'vim.mode'
$model     = if (gv $d 'model.display_name') { gv $d 'model.display_name' } else { gv $d 'model.id' }
$agent     = gv $d 'agent.name'
$wt        = gv $d 'worktree.branch'
$ctxPct    = [math]::Floor([double](gv $d 'context_window.used_percentage'))
$cost      = [double](gv $d 'cost.total_cost_usd')
$durMs     = [int64](gv $d 'cost.total_duration_ms')
$linesAdd  = [int](gv $d 'cost.total_lines_added')
$linesDel  = [int](gv $d 'cost.total_lines_removed')
$rate5h    = gv $d 'rate_limits.five_hour.used_percentage'

# ANSI helpers
function fg($c) { "`e[38;5;${c}m" }
function bg($c) { "`e[48;5;${c}m" }
$R = "`e[0m"
$SEP = [char]0xE0B0  # Nerd Font powerline arrow

# Gruvbox palette
$BG_DARK = 235; $BG_MID = 237; $BG_MID2 = 239
$FG_DARK = 235; $FG_LIGHT = 229; $FG_YELLOW = 214
$FG_GREEN = 142; $FG_RED = 167; $FG_AQUA = 108
$FG_BLUE = 109; $FG_PURPLE = 175; $FG_ORANGE = 208; $FG_GRAY = 245

# Context progress bar
function ctxBar($pct) {
    $filled = [math]::Floor($pct / 10)
    $bar = ''
    for ($i = 0; $i -lt 10; $i++) {
        $bar += if ($i -lt $filled) { [char]0x2593 } else { [char]0x2591 }
    }
    return $bar
}

# Format duration
function fmtDur($ms) {
    $s = [math]::Floor($ms / 1000)
    if     ($s -lt 60)   { "${s}s" }
    elseif ($s -lt 3600) { "{0}m{1:D2}s" -f [math]::Floor($s/60), ($s%60) }
    else                 { "{0}h{1:D2}m" -f [math]::Floor($s/3600), ([math]::Floor($s/3600*60)%60) }
}

# Segments: [fg, bg, text]
$segs = [System.Collections.Generic.List[object]]::new()
function push($f, $b, $t) { $segs.Add(@($f, $b, $t)) }

# [1] Vim mode / badge
if ($vimMode) {
    switch ($vimMode) {
        'NORMAL' { push $FG_DARK $FG_BLUE  " $vimMode" }
        'INSERT' { push $FG_DARK $FG_GREEN " $vimMode" }
        'VISUAL' { push $FG_DARK $FG_ORANGE "V $vimMode" }
        default  { push $FG_DARK $FG_PURPLE "? $vimMode" }
    }
} else { push $FG_DARK $FG_BLUE " CLAUDE" }

# [2] Model
if ($model) {
    $short = $model -replace '^claude-', '' -replace '-\d{8}$', ''
    push $FG_YELLOW $BG_MID ">> $short"
}

# [3] Agent
if ($agent) { push $FG_PURPLE $BG_MID2 "@ $agent" }

# [4] Worktree
if ($wt) { push $FG_AQUA $BG_MID "* $wt" }

# [5] Context bar
if ($ctxPct -gt 0) {
    $bar = ctxBar $ctxPct
    $fgCtx = if ($ctxPct -ge 90) { $FG_RED } elseif ($ctxPct -ge 70) { $FG_YELLOW } else { $FG_GREEN }
    push $fgCtx $BG_DARK "$bar ${ctxPct}%"
}

# [6] Cost
push $FG_AQUA $BG_MID ("$ {0:F3}" -f $cost)

# [7] Lines changed
if ($linesAdd -gt 0 -or $linesDel -gt 0) {
    push $FG_GREEN $BG_MID2 "+$linesAdd $(fg $FG_RED)-$linesDel"
}

# [8] Rate limit
if ($rate5h) {
    $r = [math]::Floor([double]$rate5h)
    $fgR = if ($r -ge 80) { $FG_RED } elseif ($r -ge 50) { $FG_YELLOW } else { $FG_GRAY }
    push $fgR $BG_DARK "! ${r}%"
}

# [9] Duration
push $FG_GRAY $BG_MID ("~ " + (fmtDur $durMs))

# ── Render ────────────────────────────────────────────────────────────────────
$line = ''
for ($i = 0; $i -lt $segs.Count; $i++) {
    $sf, $sb, $st = $segs[$i]
    if ($i -eq 0) {
        $line += "$(fg $sf)$(bg $sb) $st "
    } else {
        $pb = $segs[$i-1][1]
        if ($pb -eq $sb) {
            $line += "$(fg $FG_GRAY)|$(fg $sf) $st "
        } else {
            $line += "$(fg $pb)$(bg $sb)$SEP$(fg $sf) $st "
        }
    }
}
if ($segs.Count -gt 0) {
    $lastBg = $segs[$segs.Count - 1][1]
    $line += "${R}$(fg $lastBg)${SEP}${R}"
}

Write-Host $line -NoNewline
Write-Host ''
