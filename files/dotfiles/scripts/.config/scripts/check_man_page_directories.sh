#!/bin/bash

# Initialize an associative array to hold man page directories to avoid duplicates
declare -A man_dirs

# Function to add directories to the associative array
add_dir() {
    if [[ -d "$1" ]]; then
        man_dirs["$1"]=1
    fi
}

# Use manpath command to get initial list of man directories
if command -v manpath > /dev/null; then
    IFS=':' read -ra DIRS <<< "$(manpath 2>/dev/null)"
    for dir in "${DIRS[@]}"; do
        add_dir "$dir"
    done
fi

# Read directories from /etc/manpath.config and /etc/man.config if they exist
for config in /etc/manpath.config /etc/man.config; do
    if [[ -f "$config" ]]; then
        # Extract lines that start with MANPATH, cut on space and take the second field
        grep '^MANPATH' "$config" | cut -d ' ' -f 2 | while read -r line; do
            add_dir "$line"
        done
    fi
done

# Check directories relative to each entry in $PATH
IFS=':' read -ra PATH_DIRS <<< "$PATH"
for path_dir in "${PATH_DIRS[@]}"; do
    # Check for common man directories relative to $PATH entries
    add_dir "$path_dir/man"
    add_dir "$path_dir/../man"
done

# Check custom and usual locations under /opt
find /opt -type d -name man -print 2>/dev/null | while read -r line; do
    add_dir "$line"
done

# Check the entire file system for directories containing man pages
# Note: This can be very slow and potentially produce a lot of output; use with caution!
# find / -type f \( -name '*.[1-9]' -o -name '*.[1-9].gz' \) -print 2>/dev/null | while read -r line; do
#     add_dir "$(dirname "$line")"
# done

# Print all unique directories
for dir in "${!man_dirs[@]}"; do
    echo "$dir"
done
