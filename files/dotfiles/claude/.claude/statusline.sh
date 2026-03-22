#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Code — Gruvbox Powerline Statusline
# Requires: bash 3.2+, python3 (macOS/Linux), Nerd Font terminal
# ─────────────────────────────────────────────────────────────────────────────

DATA=$(cat)

# ── JSON parser ───────────────────────────────────────────────────────────────
# One python3 call, one field per line — avoids null-byte issues in bash 3.2
PY_CODE='
import sys, json
try:    data = json.load(sys.stdin)
except: data = {}
def g(path):
    v = data
    for k in path.split("."):
        v = v.get(k) if isinstance(v, dict) else None
    return "" if v is None else str(v)
for f in [
    g("vim.mode"),
    g("model.display_name") or g("model.id"),
    g("agent.name"),
    g("worktree.branch"),
    g("context_window.used_percentage"),
    g("cost.total_cost_usd"),
    g("cost.total_duration_ms"),
    g("cost.total_lines_added"),
    g("cost.total_lines_removed"),
    g("rate_limits.five_hour.used_percentage"),
    g("rate_limits.seven_day.used_percentage"),
    g("cwd"),
]: print(f)
'

{
    read -r VIM_MODE
    read -r MODEL
    read -r AGENT
    read -r WORKTREE_BRANCH
    read -r CTX_RAW
    read -r COST_RAW
    read -r DUR_MS
    read -r LINES_ADD
    read -r LINES_DEL
    read -r RATE_5H
    read -r RATE_7D
    read -r CWD
} < <(printf '%s' "$DATA" | python3 -c "$PY_CODE" 2>/dev/null)

CWD="${CWD:-$PWD}"

# Set safe defaults for any empty fields
VIM_MODE="${VIM_MODE:-}"
MODEL="${MODEL:-}"
CTX_RAW="${CTX_RAW:-0}"
COST_RAW="${COST_RAW:-0}"
DUR_MS="${DUR_MS:-0}"
LINES_ADD="${LINES_ADD:-0}"
LINES_DEL="${LINES_DEL:-0}"

# ── Unicode via printf — works on bash 3.2 (macOS default) ───────────────────
# Nerd Font powerline separators: U+E0B0 (filled ❯) and U+E0B1 (thin ❯)
SEP=$(printf '\xee\x82\xb0')   # U+E0B0
THIN=$(printf '\xee\x82\xb1')  # U+E0B1

# Nerd Font icons (common BMP private use area — widely supported)
ICON_BRANCH=$(printf '\xee\x82\xa0')  # U+E0A0 git branch
ICON_CLOCK=$(printf '\xe2\x8f\xb1')   # U+23F1 ⏱ (standard Unicode)
ICON_BOLT='⚡'                          # U+26A1  (standard Unicode)
ICON_DOLLAR=''  # fmt_cost already includes the $ sign

# ── Gruvbox 256-color palette ─────────────────────────────────────────────────
BG_DARK=235
BG_MID=237
BG_MID2=239
FG_DARK=235
FG_YELLOW=214
FG_GREEN=142
FG_RED=167
FG_AQUA=108
FG_BLUE=109
FG_PURPLE=175
FG_ORANGE=208
FG_GRAY=245

# ── Helpers ───────────────────────────────────────────────────────────────────
int_val() {
    local n
    n=$(printf '%.0f' "${1:-0}" 2>/dev/null) && echo "$n" || echo 0
}

fmt_cost() {
    python3 -c "
try:
    v = float('${1:-0}')
    print('\$%.3f' % v)
except:
    print('\$0.000')
" 2>/dev/null
}

fmt_duration() {
    local ms s
    ms=$(int_val "${1:-0}")
    s=$(( ms / 1000 ))
    if   (( s < 60 ));   then printf '%ds' "$s"
    elif (( s < 3600 )); then printf '%dm%02ds' $(( s/60 )) $(( s%60 ))
    else                      printf '%dh%02dm' $(( s/3600 )) $(( (s%3600)/60 ))
    fi
}

shorten_model() {
    local m="$1"
    # Strip common prefixes and date suffixes
    m="${m#claude-}"
    m="${m#Claude }"
    # Trim trailing date stamps like -20251022
    m=$(echo "$m" | sed 's/-[0-9]\{8\}$//')
    echo "$m"
}

ctx_bar() {
    local pct filled bar i
    pct=$(int_val "${1:-0}")
    # Clamp to 0-100
    (( pct < 0 ))   && pct=0
    (( pct > 100 )) && pct=100
    filled=$(( pct / 10 ))
    bar=''
    for (( i=0; i<10; i++ )); do
        (( i < filled )) && bar="${bar}▓" || bar="${bar}░"
    done
    printf '%s %d%%' "$bar" "$pct"
}

# ── Git info (cached, 3-second TTL) ──────────────────────────────────────────
# Returns: branch|repo|staged|modified|untracked  (pipe-delimited)
git_info() {
    local cwd="$1"
    local cache_key cache_file mtime now age

    cache_key=$(echo "$cwd" | cksum | awk '{print $1}')
    cache_file="/tmp/ccs-git-${cache_key}"

    # Serve from cache if fresh
    if [[ -f "$cache_file" ]]; then
        if [[ "$(uname)" == "Darwin" ]]; then
            mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        else
            mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        fi
        now=$(date +%s)
        age=$(( now - mtime ))
        if (( age < 3 )); then
            cat "$cache_file"
            return
        fi
    fi

    # Not in git? Return empty
    git -C "$cwd" rev-parse --git-dir &>/dev/null || { echo ""; return; }

    local branch repo status_out staged modified untracked
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)
    repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)")
    status_out=$(git -C "$cwd" status --porcelain 2>/dev/null)

    # X = index (staged), Y = worktree (unstaged)
    staged=$(printf '%s\n' "$status_out"   | grep -cE '^[^? ]'  || echo 0)
    modified=$(printf '%s\n' "$status_out" | grep -cE '^.[^? ]' || echo 0)
    untracked=$(printf '%s\n' "$status_out"| grep -c  '^??'      || echo 0)

    printf '%s|%s|%s|%s|%s' "$branch" "$repo" "$staged" "$modified" "$untracked" \
        | tee "$cache_file"
}

# ── Segment arrays ────────────────────────────────────────────────────────────
SEG_FG=()
SEG_BG=()
SEG_TXT=()

push() { SEG_FG+=("$1"); SEG_BG+=("$2"); SEG_TXT+=("$3"); }

# ── Build segments ────────────────────────────────────────────────────────────

# [1] Vim mode / session badge
if [[ -n "$VIM_MODE" ]]; then
    case "$VIM_MODE" in
        NORMAL) push $FG_DARK $FG_BLUE   "N $VIM_MODE" ;;
        INSERT) push $FG_DARK $FG_GREEN  "I $VIM_MODE" ;;
        VISUAL) push $FG_DARK $FG_ORANGE "V $VIM_MODE" ;;
        *)      push $FG_DARK $FG_PURPLE "? $VIM_MODE" ;;
    esac
else
    push $FG_DARK $FG_BLUE "✦ CLAUDE"
fi

# [2] Model name
if [[ -n "$MODEL" ]]; then
    SHORT=$(shorten_model "$MODEL")
    push $FG_YELLOW $BG_MID "◈ ${SHORT}"
fi

# [3] Agent (if active)
[[ -n "$AGENT" ]] && push $FG_PURPLE $BG_MID2 "@ ${AGENT}"

# [4] Git — repo, branch, and dirty status
GIT_RAW=$(git_info "$CWD")
if [[ -n "$GIT_RAW" ]]; then
    IFS='|' read -r GIT_BRANCH GIT_REPO GIT_STAGED GIT_MODIFIED GIT_UNTRACKED <<< "$GIT_RAW"
    GIT_STAGED=$(int_val "$GIT_STAGED")
    GIT_MODIFIED=$(int_val "$GIT_MODIFIED")
    GIT_UNTRACKED=$(int_val "$GIT_UNTRACKED")

    # Label: repo:branch (truncate branch to 24 chars)
    GIT_BRANCH_SHORT="${GIT_BRANCH:0:24}"
    GIT_LABEL="${ICON_BRANCH} ${GIT_REPO}:${GIT_BRANCH_SHORT}"

    # Status indicators
    GIT_DIRTY=""
    (( GIT_STAGED    > 0 )) && GIT_DIRTY="${GIT_DIRTY} ●${GIT_STAGED}"
    (( GIT_MODIFIED  > 0 )) && GIT_DIRTY="${GIT_DIRTY} ~${GIT_MODIFIED}"
    (( GIT_UNTRACKED > 0 )) && GIT_DIRTY="${GIT_DIRTY} ?${GIT_UNTRACKED}"

    if [[ -z "$GIT_DIRTY" ]]; then
        # Clean — green checkmark
        push $FG_GREEN $BG_MID2 "${GIT_LABEL} ✔"
    elif (( GIT_STAGED > 0 && GIT_MODIFIED == 0 && GIT_UNTRACKED == 0 )); then
        # Staged only — ready to commit (yellow)
        push $FG_YELLOW $BG_MID2 "${GIT_LABEL}${GIT_DIRTY}"
    else
        # Unstaged changes present — needs attention (orange/red)
        push $FG_ORANGE $BG_MID2 "${GIT_LABEL}${GIT_DIRTY}"
    fi
fi

# [5] Worktree branch (if in a Claude Code worktree)
[[ -n "$WORKTREE_BRANCH" ]] && push $FG_AQUA $BG_MID "${ICON_BRANCH} ${WORKTREE_BRANCH}"

# [5] Context window progress bar
CTX_PCT=$(int_val "$CTX_RAW")
# Guard: only show if we got a real value
if [[ -n "$CTX_RAW" && "$CTX_RAW" != "0" ]]; then
    BAR=$(ctx_bar "$CTX_PCT")
    if   (( CTX_PCT >= 90 )); then push $FG_RED    $BG_DARK "$BAR"
    elif (( CTX_PCT >= 70 )); then push $FG_YELLOW $BG_DARK "$BAR"
    else                           push $FG_GREEN  $BG_DARK "$BAR"
    fi
fi

# [6] Session cost
COST_FMT=$(fmt_cost "$COST_RAW")
push $FG_AQUA $BG_MID "${COST_FMT}"

# [7] Lines added/removed (only when nonzero)
ADD=$(int_val "$LINES_ADD")
DEL=$(int_val "$LINES_DEL")
(( ADD > 0 || DEL > 0 )) && push $FG_GREEN $BG_MID2 "+${ADD}/-${DEL}"

# [8] Rate limit — 5-hour window (only on Claude.ai Pro/Max)
if [[ -n "$RATE_5H" && "$RATE_5H" != "0" ]]; then
    R5=$(int_val "$RATE_5H")
    if   (( R5 >= 80 )); then push $FG_RED    $BG_DARK "${ICON_BOLT} ${R5}%"
    elif (( R5 >= 50 )); then push $FG_YELLOW $BG_DARK "${ICON_BOLT} ${R5}%"
    else                      push $FG_GRAY   $BG_DARK "${ICON_BOLT} ${R5}%"
    fi
fi

# [9] Session duration
DUR=$(fmt_duration "$DUR_MS")
push $FG_GRAY $BG_MID "${ICON_CLOCK} ${DUR}"

# ── Render powerline ──────────────────────────────────────────────────────────
N=${#SEG_FG[@]}
LINE=''

for (( i=0; i<N; i++ )); do
    sfg=${SEG_FG[$i]}
    sbg=${SEG_BG[$i]}
    stxt=${SEG_TXT[$i]}

    if (( i == 0 )); then
        LINE="${LINE}\033[38;5;${sfg}m\033[48;5;${sbg}m ${stxt} "
    else
        prev_bg=${SEG_BG[$((i-1))]}
        if [[ "$prev_bg" == "$sbg" ]]; then
            # Same bg: thin separator
            LINE="${LINE}\033[38;5;${FG_GRAY}m${THIN}\033[38;5;${sfg}m ${stxt} "
        else
            # Different bg: hard powerline arrow
            LINE="${LINE}\033[38;5;${prev_bg}m\033[48;5;${sbg}m${SEP}\033[38;5;${sfg}m ${stxt} "
        fi
    fi
done

# Final arrow back to terminal background
if (( N > 0 )); then
    last_bg=${SEG_BG[$((N-1))]}
    LINE="${LINE}\033[0m\033[38;5;${last_bg}m${SEP}\033[0m"
fi

printf "%b\n" "$LINE"
