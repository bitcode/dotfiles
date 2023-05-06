#!/bin/bash

# Check if xclip is installed
if ! command -v xclip >/dev/null; then
    echo "xclip not found. Please install it and try again."
    exit 1
fi

# Check if any arguments are provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 file1 [file2 ...]"
    exit 1
fi

# Concatenate the contents of all provided files
combined_contents=""
for file in "$@"; do
    if [ -f "$file" ]; then
        combined_contents+=$(cat "$file")
        combined_contents+=$'\n' # Add a newline after the content of each file
    else
        echo "File not found: $file"
    fi
done

# Copy the combined content to clipboard using xclip
echo -n "$combined_contents" | xclip -selection clipboard

echo "Copied the contents of the provided files to clipboard."

