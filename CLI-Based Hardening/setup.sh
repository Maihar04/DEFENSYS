#!/bin/bash

# Make all .sh files in the current directory executable
for file in *.sh; do
    if [ -f "$file" ]; then
        chmod +x "$file"
    fi
done

echo "Executable permission given to all files in the current directory."
