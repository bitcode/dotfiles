#!/usr/bin/bash

# Check dependencies (with auto-install)
if ! command -v xclip >/dev/null; then
  echo "xclip not found. Attempting to install..."
  sudo apt-get install xclip || { echo "Installation failed. Please install xclip manually."; exit 1; }
fi

# Usage guidance
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-i ignore_list] directory1 [directory2 ...]"
  exit 1
fi

# Process the -i flag for an ignore list (optional)
ignore_list=""
if [ "$1" == "-i" ]; then
  ignore_list="$2"
  shift 2 # Shift arguments to drop -i and the ignore list file
fi

# Recursive function with refinements
process_files() {
  local current_dir=$1

  for file in "$current_dir"/*; do
    should_ignore=false

    # More precise ignore list check
    if [ "$ignore_list" != "" ] && grep -qFf "$ignore_list" <<< "$file"; then 
      should_ignore=true
    fi

    if ! $should_ignore; then
     if [ -f "$file" ]; then
       # Print file path for debug
       echo "Processing file: $file"

       # Improved comment with full file path
       printf "# File: %s\n" "$file" >> "$master_file" 

       # Debug: Print file content
       cat "$file"

       # Send file contents to clipboard
       xclip -selection clipboard < "$file"

       # Additionally, append to master.txt
       cat "$file" >> "$master_file" 

     elif [ -d "$file" ]; then
       process_files "$file"
     else 
       echo "Warning: File not found: $file"
     fi
   fi
 done
}

# Start processing
master_file="master.txt"

for directory in "$@"; do
  process_files "$directory" 
done

# Copy from master.txt to clipboard
xclip -selection clipboard < "$master_file"
echo "Copied the contents of master.txt to clipboard."
