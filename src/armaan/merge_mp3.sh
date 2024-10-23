#!/bin/bash

# Check if a folder path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

# Use the provided folder path
folder_path="$1"

# Create a temporary file to store the list of audio files
temp_file="temp_file_list.txt"

# List all MP3 and M4B files in the specified folder, sort them alphabetically, and save to the temporary file
find "$folder_path" -maxdepth 1 \( -name "*.mp3" -o -name "*.m4b" \) | sort | sed "s/^/file '/" | sed "s/$/'/" > "$temp_file"

# Use FFmpeg to merge the files
ffmpeg -f concat -safe 0 -i "$temp_file" -c copy output_merged.mp4

# Remove the temporary file
rm "$temp_file"

echo "All MP3 and M4B files from $folder_path have been merged into output_merged.mp4"
