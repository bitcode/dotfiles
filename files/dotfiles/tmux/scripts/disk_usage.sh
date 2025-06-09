#!/bin/bash

# This script prints the used disk space percentage of the root filesystem.

# Command to get disk usage percentage of the root filesystem.
disk_usage=$(df -h / | awk 'NR==2 {print $5}')

# Output the disk usage. The '%' sign is already included in the df output.
echo $disk_usage
