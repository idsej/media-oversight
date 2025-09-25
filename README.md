# MKV Duration Sorter
This script scans folders for .mkv files, checks how long each video is, and creates a sorted list in a CSV file.

## What It Does
* Finds all .mkv video files in the current folder and any subfolders.
* Creates a CSV file (mkv_lengths_sorted.csv) listing each video from longest to shortest.
* Tells you the total combined duration of all videos.

## Requirements
This script requires FFmpeg and bc to be installed.

`sudo apt update && sudo apt install ffmpeg bc`

## How to Use
1. Save the Script: Save the main script's code into a file called mkv_duration.sh.
2. Run it: Move the script to the folder with your videos and run:

`./mkv_duration.sh`

When it's done, you will find a mkv_lengths_sorted.csv file in the same folder.

## Example Output File
```
FileName,DurationSeconds,DurationMinutes
"My_Longest_Movie.mkv",7230.50,120.50
"Some_Other_Video.mkv",3599.98,59.99
"Short_Clip.mkv",180.15,3.00
