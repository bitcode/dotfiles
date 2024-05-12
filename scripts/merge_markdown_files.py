import os
import sys

# Check if the correct number of arguments are provided
if len(sys.argv) != 3:
    print("Usage: python script.py <input_dir> <output_file>")
    sys.exit(1)

# Read the directory and output file name from command-line arguments
input_dir = sys.argv[1]
output_file = sys.argv[2]

# Ensure the output file path is in the same directory as the input files
output_file = os.path.join(input_dir, output_file)

# Get a list of all Markdown files in the directory
markdown_files = [f for f in os.listdir(input_dir) if f.endswith('.md')]

# Open the output file for writing
with open(output_file, 'w', encoding='utf-8') as outfile:
    # Iterate through the Markdown files and append their contents to the output file
    for filename in markdown_files:
        with open(os.path.join(input_dir, filename), 'r', encoding='utf-8') as infile:
            outfile.write(infile.read())
            outfile.write('\n\n')  # Add an extra newline between files

print(f'Merged {len(markdown_files)} Markdown files into {output_file}.')
