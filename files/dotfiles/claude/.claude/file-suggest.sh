#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Claude Code — @ file suggestion script
# Triggered when you type @ in the prompt. Receives JSON {"query": "..."} on
# stdin, returns a JSON array of matching file paths on stdout.
#
# Priority:
#   1. fd  — fast, respects .gitignore, best option
#   2. find — POSIX fallback
# ─────────────────────────────────────────────────────────────────────────────

# Resolve python command (python3 on Unix, python on Windows)
if command -v python3 &>/dev/null; then
    PY=python3
else
    PY=python
fi

DATA=$(cat)
QUERY=$(printf '%s' "$DATA" | $PY -c "
import sys, json
try:    print(json.load(sys.stdin).get('query', ''), end='')
except: print('', end='')
" 2>/dev/null)

CWD="${PWD}"
MAX=60

# ── Search ────────────────────────────────────────────────────────────────────
if command -v fd &>/dev/null; then
    # fd: fast, respects .gitignore; --hidden so paths like .config/nvim/ are searched
    RESULTS=$(fd \
        --type f \
        --hidden \
        --max-depth 10 \
        --search-path "$CWD" \
        --color never \
        "$QUERY" 2>/dev/null | head -"$MAX")
else
    # find fallback: skip common noise dirs
    PATTERN="*${QUERY}*"
    RESULTS=$(find "$CWD" -type f -name "$PATTERN" \
        \( \
            -path "*/.git/*" \
            -o -path "*/node_modules/*" \
            -o -path "*/.cache/*" \
            -o -path "*/dist/*" \
            -o -path "*/__pycache__/*" \
            -o -path "*/.mypy_cache/*" \
        \) -prune -o -type f -name "$PATTERN" -print \
        2>/dev/null | head -"$MAX")
fi

# ── Output: JSON array of relative paths ─────────────────────────────────────
printf '%s\n' "$RESULTS" | $PY -c "
import sys, json, os
cwd = os.getcwd()
paths = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    try:
        rel = os.path.relpath(line, cwd)
        # Prefer relative paths — skip if they escape root (../../...)
        if not rel.startswith('../../../'):
            paths.append(rel)
        else:
            paths.append(line)
    except Exception:
        paths.append(line)
print(json.dumps(paths))
" 2>/dev/null || echo '[]'
