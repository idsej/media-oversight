#!/bin/bash

# This script finds all .mkv and .mp4 files, sorts them by duration,
# saves filename and duration to a csv file.
# Requires ffmpeg

OUTPUT_FILE="duration_sorted.csv"
total_seconds=0
file_count=0
data_to_sort=""

echo "FileName,DurationMinutes (rounded),FileSizeGB" > "$OUTPUT_FILE"
echo "Scanning files..."

# colleting data 
while IFS= read -r -d '' file; do
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file")
    
    # Get file size in bytes
    filesize_bytes=$(stat -c %s "$file")

    if [[ -n "$duration" && -n "$filesize_bytes" ]]; then
        # Store duration, filesize, and file path, separated by tabs
        data_to_sort+="$duration\t$filesize_bytes\t$file"$'\n'
        
        total_seconds=$(echo "$total_seconds + $duration" | bc)
        ((file_count++))
    else
        echo "Warning: Could not get metadata for: $file"
    fi
done < <(find . -path './$RECYCLE.BIN' -prune -o -path './System Volume Information' -prune -o -type f \( -iname "*.mkv" -o -iname "*.mp4" \) -print0)

# sort and write
if [[ -n "$data_to_sort" ]]; then
    echo "Sorting and writing to file..."
    printf "%s" "$data_to_sort" | sort -rn | while IFS=$'\t' read -r duration filesize_bytes file; do
        if [[ -n "$file" ]]; then
            filename_only="${file##*/}"
            precise_minutes=$(echo "scale=4; $duration / 60" | bc)
            
	    # calculate gigabytes with 2 decimal places
            filesize_gb=$(echo "scale=2; $filesize_bytes / (1024*1024*1024)" | bc)
            
            echo "\"$filename_only\",$rounded_minutes,$filesize_gb" >> "$OUTPUT_FILE"
	fi
    done
fi
echo "--------------------------------------------------"
echo "Done. Processed $file_count file(s)."
echo "Sorted data saved to $OUTPUT_FILE"

if (( $(echo "$total_seconds > 0" | bc -l) )); then
    total_seconds_rounded=$(printf "%.0f" "$total_seconds")

    hours=$((total_seconds_rounded / 3600))
    minutes=$(( (total_seconds_rounded % 3600) / 60 ))

    printf "Total Duration: %d Hours, %d Minutes\n" $hours $minutes
fi
