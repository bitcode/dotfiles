#!/bin/bash

# Create an empty file to store the concatenated contents
output_file="concatenated_contents.txt"
> "$output_file"

# Find all files in the specified directory and its subdirectories
find . -type f | while read -r file; do
  # Exclude the output file from the list of files to process
  if [[ $file != ./$output_file ]]; then
    # Print the file name and append it to the output file
    echo "File: $file" >> "$output_file"
    
    # Print a separator line and append it to the output file
    echo "----------------------------------------------" >> "$output_file"
    
    # Concatenate the file contents to the output file
    cat "$file" >> "$output_file"
    
    # Print an empty line as a separator between files and append it to the output file
    echo "" >> "$output_file"
  fi
done

# Copy the concatenated contents to the clipboard using xclip
cat "$output_file" | xclip -selection clipboard

# Print a message to inform the user that the contents have been copied to the clipboard
echo "The concatenated contents of all files have been copied to the clipboard."
