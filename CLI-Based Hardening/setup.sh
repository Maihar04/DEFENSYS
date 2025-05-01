#!/bin/bash

for file in *.sh; do
    if [ -f "$file" ]; then
        chmod +x "$file"
    fi
done

echo "Executable permission given."