#!/usr/bin/env bash
# Loads ~/.claude/.env.research into the current shell.
# Source it: . "$HOME/.claude/skills/deep-research/scripts/load-env.sh"

ENV_FILE="${1:-$HOME/.claude/.env.research}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Credentials file not found: $ENV_FILE" >&2
    return 1 2>/dev/null || exit 1
fi

set -a
# shellcheck disable=SC1090
source <(grep -E '^[A-Z_][A-Z0-9_]*=' "$ENV_FILE")
set +a

if [[ -z "$FIRECRAWL_API_KEY" ]]; then
    echo "warning: FIRECRAWL_API_KEY empty after loading $ENV_FILE" >&2
fi
