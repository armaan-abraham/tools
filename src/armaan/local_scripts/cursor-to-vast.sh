#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 \"ssh -p PORT USER@HOST [OPTIONS]\" [OPTIONAL_PATH]"
    echo "Example: $0 \"ssh -p 20626 root@38.99.105.118 -L 8080:localhost:8080\" projects/myapp"
    exit 1
}

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
    usage
fi

# Capture the SSH command
ssh_cmd="$1"
extra_path="${2:-}"  # Optional path, empty if not provided

# Parse the SSH command using regex
if [[ $ssh_cmd =~ ssh\ -p\ ([0-9]+)\ ([^@]+)@([^\ ]+) ]]; then
    port="${BASH_REMATCH[1]}"
    user="${BASH_REMATCH[2]}"
    host="${BASH_REMATCH[3]}"
    
    # Construct the path
    if [ -n "$extra_path" ]; then
        path="/root/$extra_path"
    else
        path="/root"
    fi
    
    # Construct the cursor command
    cursor_cmd="cursor --remote ssh-remote+$user@$host:$port $path"
    
    # Execute cursor command
    echo "Executing: $cursor_cmd"
    eval "$cursor_cmd"
else
    echo "Error: Could not parse SSH command. Please use the format:"
    echo "ssh -p PORT USER@HOST [OPTIONS]"
    exit 1
fi