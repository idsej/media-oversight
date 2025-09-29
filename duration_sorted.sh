#!/bin/bash
# This script finds all .mkv files, sorts them by duration,
# saves filename, duration, and file size to a CSV file.
# Requires ffmpeg and bc.

OUTPUT_FILE="duration_size_sorted.csv"
total_seconds=0
processed_file_count=0

# Initialize the output file with headers
echo "FileName,DurationMinutes,FileSizeGB" > "$OUTPUT_FILE"
echo "Scanning for video files and processing..."

process_file() {
    local file="$1"
    # Use ffprobe to get the duration in seconds.
    # LC_NUMERIC=C ensures the decimal point is a '.', regardless of system locale.
    local duration
    duration=$(LC_NUMERIC=C ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)

    local filesize_bytes
    filesize_bytes=$(stat -c %s "$file")

    if [[ "$duration" =~ ^[0-9]+(\.[0-9]*)?$ && -n "$filesize_bytes" ]]; then
        printf "%s\t%s\t%s\n" "$duration" "$filesize_bytes" "$file"
    else
        echo "Warning: Could not get valid metadata for: '$file' (duration found: '$duration')" >&2
    fi
}

export -f process_file

while IFS=$'\t' read -r duration filesize_bytes file; do
    if [[ -n "$file" ]]; then
        filename_only="${file##*/}"
        minutes=$(LC_NUMERIC=C echo "scale=2; $duration / 60" | bc)
        filesize_gb=$(LC_NUMERIC=C echo "scale=2; $filesize_bytes / (1024*1024*1024)" | bc)

        echo "\"$filename_only\",$minutes,$filesize_gb" >> "$OUTPUT_FILE"
        
        # Add to totals
        total_seconds=$(LC_NUMERIC=C echo "$total_seconds + $duration" | bc)
        ((processed_file_count++))
    fi
done < <(find . -path './$RECYCLE.BIN' -prune -o -path './System Volume Information' -prune -o -type f -iname "*.mkv" -print0 | xargs -0 -I {} bash -c 'process_file "{}"' | LC_NUMERIC=C sort -rn)


echo "--------------------------------------------------"
echo "Done. Processed $processed_file_count file(s)."
echo "Sorted data saved to $OUTPUT_FILE"

if (( $(echo "$total_seconds > 0" | bc -l) )); then
    total_seconds_int=${total_seconds%.*}
    hours=$((total_seconds_int / 3600))
    minutes=$(( (total_seconds_int % 3600) / 60 ))
    seconds=$((total_seconds_int % 60))
    printf "Total Duration: %02d:%02d:%02d\n" $hours $minutes $seconds
fi


