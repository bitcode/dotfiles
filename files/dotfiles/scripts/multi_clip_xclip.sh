#!/usr/bin/bash

# Check dependencies (with auto-install)
if ! command -v xclip >/dev/null; then
  echo "xclip not found. Attempting to install..."
  sudo apt-get install xclip || { echo "Installation failed. Please install xclip manually."; exit 1; }
fi

# Set default directory to the current directory if no arguments are provided
if [ $# -eq 0 ] || ([ "$1" == "-i" ] && [ $# -eq 2 ]); then
  set -- "${@:1:1}" "." "${@:2}" # Add current directory as an argument if missing
fi

# Usage guidance
if [ $# -lt 1 ]; then
  echo "Usage: $0 [-i ignore_list] directory1 [directory2 ...]"
  exit 1
fi

# Process the -i flag for an ignore list (optional)
ignore_list=""
if [ "$1" == "-i" ]; then
  ignore_list="$2"
  shift 2 # Shift arguments to drop -i and the ignore list file
fi

# Recursive function to process files
process_files() {
  local current_dir=$1

  for file in "$current_dir"/*; do
    should_ignore=false

    # Check against ignore list
    if [ -n "$ignore_list" ] && grep -qFf "$ignore_list" <<< "$file"; then 
      should_ignore=true
    fi

    if ! $should_ignore; then
      if [ -f "$file" ]; then
        # Print file path for debug
        echo "Processing file: $file"

        # Append file path to master.txt
        printf "# File: %s\n" "$file" >> "$master_file"

        # Append file contents to master.txt
        cat "$file" >> "$master_file"

      elif [ -d "$file" ]; then
        process_files "$file"
      else 
        echo "Warning: File not found: $file"
      fi
    fi
  done
}

# Initialize master file
master_file="master.txt"
: > "$master_file" # Clear the contents of master.txt before starting

# Start processing directories
for directory in "$@"; do
  process_files "$directory"
done

# Copy from master.txt to clipboard
xclip -selection clipboard < "$master_file"
echo "Copied the contents of master.txt to clipboard."
