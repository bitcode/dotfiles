#!/usr/bin/bash

# Check dependencies
if ! command -v wl-copy >/dev/null; then
    echo "wl-clipboard not found. Please install it and try again."
    exit 1
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

# Recursive function to process files
process_files() {
    local current_dir=$1

    for file in "$current_dir"/*; do
        should_ignore=false

        # Check against ignore list
        if [ "$ignore_list" != "" ]; then
            while IFS= read -r pattern; do
                if [[ "$file" =~ $pattern ]]; then
                    should_ignore=true
                    break 
                fi
            done < "$ignore_list"
        fi

        if ! $should_ignore; then
            if [ -f "$file" ]; then
                # Add file name as a comment at the top
                combined_contents+="# File: $file" 
                combined_contents+=$'\n'

                combined_contents+=$(cat "$file")
                combined_contents+=$'\n'
            elif [ -d "$file" ]; then
                process_files "$file" # Recurse into subdirectories
            else 
                echo "Warning: File not found: $file"
            fi
        fi
    done
}

# Start processing
combined_contents=""
for directory in "$@"; do  # Iterate over provided directories
    process_files "$directory" 
done

# Copy to clipboard (modified for Wayland)
# debug
echo "DEBUG: combined_contents: $combined_contents" 
echo -n "$combined_contents" | wl-copy

echo "Copied the contents of the provided files to clipboard."

