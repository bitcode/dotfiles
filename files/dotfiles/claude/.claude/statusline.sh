#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Code — Gruvbox Powerline Statusline
# Requires: bash 3.2+, python3 (macOS/Linux)
# Nerd Font recommended for icons and powerline separators
# ─────────────────────────────────────────────────────────────────────────────

DATA=$(cat)

# ── JSON parser: one python3 call extracts everything ────────────────────────
read -r -d '' PY_PARSE << 'PYEOF'
import sys, json, os

try:
    data = json.loads(sys.stdin.read())
except Exception:
    data = {}

def g(path, default=''):
    v = data
    for k in path.split('.'):
        if isinstance(v, dict): v = v.get(k)
        else: v = None; break
    return '' if v is None else str(v)

fields = [
    g('vim.mode'),
    g('model.display_name') or g('model.id'),
    g('agent.name'),
    g('worktree.branch'),
    g('context_window.used_percentage'),
    g('cost.total_cost_usd'),
    g('cost.total_duration_ms'),
    g('cost.total_lines_added'),
    g('cost.total_lines_removed'),
    g('rate_limits.five_hour.used_percentage'),
    g('rate_limits.seven_day.used_percentage'),
]
print('\x00'.join(fields))
PYEOF

IFS=$'\x00' read -r -a F <<< "$(echo "$DATA" | python3 -c "$PY_PARSE" 2>/dev/null)"

VIM_MODE="${F[0]:-}"
MODEL="${F[1]:-}"
AGENT="${F[2]:-}"
WORKTREE_BRANCH="${F[3]:-}"
CTX_RAW="${F[4]:-0}"
COST_RAW="${F[5]:-0}"
DUR_MS="${F[6]:-0}"
LINES_ADD="${F[7]:-0}"
LINES_DEL="${F[8]:-0}"
RATE_5H="${F[9]:-}"
RATE_7D="${F[10]:-}"

# ── Gruvbox 256-color palette ─────────────────────────────────────────────────
# Segment backgrounds (numeric codes for separator logic)
BG_DARK=235   # gruvbox bg
BG_MID=237    # gruvbox bg1
BG_MID2=239   # gruvbox bg2

# Foreground codes
FG_DARK=235
FG_LIGHT=229
FG_YELLOW=214
FG_GREEN=142
FG_RED=167
FG_AQUA=108
FG_BLUE=109
FG_PURPLE=175
FG_ORANGE=208
FG_GRAY=245

# Powerline separators (Nerd Font U+E0B0 / U+E0B1)
SEP=$'\ue0b0'   # hard right arrow ❯ filled
THIN=$'\ue0b1'  # thin right arrow ❯ outline

# ── Helpers ───────────────────────────────────────────────────────────────────
int_val() { printf '%.0f' "${1:-0}" 2>/dev/null || echo 0; }

fmt_cost() {
    python3 -c "v=float('${1:-0}'); print(f'\${v:.3f}')" 2>/dev/null || echo '$0.000'
}

fmt_duration() {
    local ms=$(int_val "${1:-0}")
    local s=$(( ms / 1000 ))
    if   (( s < 60 ));   then printf '%ds' "$s"
    elif (( s < 3600 )); then printf '%dm%02ds' $(( s/60 )) $(( s%60 ))
    else                      printf '%dh%02dm' $(( s/3600 )) $(( (s%3600)/60 ))
    fi
}

# 10-char context progress bar using block chars
ctx_bar() {
    local pct=$(int_val "${1:-0}")
    local filled=$(( pct / 10 ))
    local bar=''
    for (( i=0; i<10; i++ )); do
        (( i < filled )) && bar+='▓' || bar+='░'
    done
    echo "$bar"
}

# ── Segment array (parallel: fg bg text) ─────────────────────────────────────
SEG_FG=()
SEG_BG=()
SEG_TXT=()

push() {
    SEG_FG+=("$1")
    SEG_BG+=("$2")
    SEG_TXT+=("$3")
}

# ── Build segments ────────────────────────────────────────────────────────────

# [1] Vim mode / session badge
if [[ -n "$VIM_MODE" ]]; then
    case "$VIM_MODE" in
        NORMAL) push $FG_DARK $FG_BLUE   " $VIM_MODE" ;;
        INSERT) push $FG_DARK $FG_GREEN  " $VIM_MODE" ;;
        VISUAL) push $FG_DARK $FG_ORANGE "󰸿 $VIM_MODE" ;;
        *)      push $FG_DARK $FG_PURPLE " $VIM_MODE" ;;
    esac
else
    push $FG_DARK $FG_BLUE " CLAUDE"
fi

# [2] Model name
if [[ -n "$MODEL" ]]; then
    # Shorten common model names
    SHORT="${MODEL/claude-/}"
    SHORT="${SHORT//-20[0-9][0-9][0-9][0-9][0-9][0-9]/}"
    push $FG_YELLOW $BG_MID "󱙺 ${SHORT}"
fi

# [3] Agent (if active)
[[ -n "$AGENT" ]] && push $FG_PURPLE $BG_MID2 " ${AGENT}"

# [4] Worktree branch (if in a worktree)
[[ -n "$WORKTREE_BRANCH" ]] && push $FG_AQUA $BG_MID " ${WORKTREE_BRANCH}"

# [5] Context window progress bar
CTX_PCT=$(int_val "$CTX_RAW")
if [[ "$CTX_PCT" -gt 0 ]] || [[ "${F[4]}" != "" ]]; then
    BAR=$(ctx_bar "$CTX_PCT")
    if   (( CTX_PCT >= 90 )); then push $FG_RED    $BG_DARK "${BAR} ${CTX_PCT}%"
    elif (( CTX_PCT >= 70 )); then push $FG_YELLOW $BG_DARK "${BAR} ${CTX_PCT}%"
    else                           push $FG_GREEN  $BG_DARK "${BAR} ${CTX_PCT}%"
    fi
fi

# [6] Session cost
COST_FMT=$(fmt_cost "$COST_RAW")
push $FG_AQUA $BG_MID "󰗾 ${COST_FMT}"

# [7] Lines added/removed (only if nonzero)
ADD=$(int_val "$LINES_ADD")
DEL=$(int_val "$LINES_DEL")
if (( ADD > 0 || DEL > 0 )); then
    push $FG_GREEN $BG_MID2 "+${ADD} \033[38;5;${FG_RED}m-${DEL}"
fi

# [8] Rate limit — 5-hour window
if [[ -n "$RATE_5H" ]]; then
    R5=$(int_val "$RATE_5H")
    if   (( R5 >= 80 )); then push $FG_RED    $BG_DARK "⚡ ${R5}%"
    elif (( R5 >= 50 )); then push $FG_YELLOW $BG_DARK "⚡ ${R5}%"
    else                      push $FG_GRAY   $BG_DARK "⚡ ${R5}%"
    fi
fi

# [9] Session duration
DUR=$(fmt_duration "$DUR_MS")
push $FG_GRAY $BG_MID "󱑂 ${DUR}"

# ── Render powerline ──────────────────────────────────────────────────────────
N=${#SEG_FG[@]}
LINE=''

for (( i=0; i<N; i++ )); do
    fg=${SEG_FG[$i]}
    bg=${SEG_BG[$i]}
    txt=${SEG_TXT[$i]}

    if (( i == 0 )); then
        # First segment: no leading separator
        LINE+="\033[38;5;${fg}m\033[48;5;${bg}m ${txt} "
    else
        prev_bg=${SEG_BG[$((i-1))]}
        if [[ "$prev_bg" == "$bg" ]]; then
            # Same background: use thin separator, no bg change
            LINE+="\033[38;5;${FG_GRAY}m${THIN}\033[38;5;${fg}m ${txt} "
        else
            # Different background: hard powerline arrow
            LINE+="\033[38;5;${prev_bg}m\033[48;5;${bg}m${SEP}\033[38;5;${fg}m ${txt} "
        fi
    fi
done

# Final arrow back to terminal background
if (( N > 0 )); then
    last_bg=${SEG_BG[$((N-1))]}
    LINE+="\033[0m\033[38;5;${last_bg}m${SEP}\033[0m"
fi

printf "%b\n" "$LINE"
