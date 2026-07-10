#!/bin/bash

# Check for required commands
for cmd in git; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: '$cmd' command not found. Please install git."
    exit 1
  fi
done

# Get the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Fetch updates from the remote (to ensure we have recent info).
git fetch origin 

# Determine if the local branch is ahead, behind, or in sync
num_commits_ahead=$(git rev-list --count HEAD..origin/"$current_branch")
num_commits_behind=$(git rev-list --count origin/"$current_branch"..HEAD)

if [ "$num_commits_ahead" -gt 0 ]; then
  echo "Local branch ($current_branch) is ahead of remote by $num_commits_ahead commits."
elif [ "$num_commits_behind" -gt 0 ]; then
  echo "Local branch ($current_branch) is behind remote by $num_commits_behind commits."
else
  echo "Local branch ($current_branch) is in sync with the remote."
fi

