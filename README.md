# Duration Sorter
This script scans folders for .mkv fnd .mp4 iles, checks how long each video is, and creates a sorted list in a CSV file.

## What It Does
* Finds all .mkv and .mp4 video files in the current folder and any subfolders.
* Creates a CSV file (lengths_sorted.csv) listing each video from longest to shortest.
* Tells you the total combined duration of all videos.

## Requirements
This script requires FFmpeg and bc to be installed.

`sudo apt update && sudo apt install ffmpeg bc`

## How to Use
1. Save the Script: Save the main script's code into a file called duration.sh.
2. Run it: Move the script to the folder with your videos and run:

`./duration.sh`

When it's done, you will find a duration_sorted.csv file in the same folder.

