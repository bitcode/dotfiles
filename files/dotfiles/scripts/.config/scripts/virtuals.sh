#!/bin/bash

# Define the path to search
path="/home/bit/"

# Find all directories with the name "env" in the defined path
virtual_envs=$(find $path -type d -name "*")

# Check if each directory is a virtual environment
for virtual_env in $virtual_envs
do
  # Check if the virtual environment has a 'bin/python' executable
  if [ -f "$virtual_env/bin/python" ]
  then
    echo "Found Python virtual environment: $virtual_env"
  fi
done
