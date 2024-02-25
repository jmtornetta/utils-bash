#!/bin/bash

# Check if at least one argument is provided (YouTube URL)
if [ $# -lt 1 ]; then
    echo "Usage: $0 <YouTube Video URL> [additional yt-dlp parameters...]"
    exit 1
fi

declare -r YOUTUBE_URL="$1"  # Extract the first argument as the YouTube URL
shift  # Remove the first argument (YouTube URL) and keep any additional parameters

# Get the current date and time in the format YYMMDDHHMMSS
declare -r current_datetime=$(date "+%y%m%d%H%M%S")
# Define the output filename template
declare -r output_prefix="/tmp/${current_datetime}"
declare -r OUTPUT_TEMPLATE="${output_prefix}-%(title)s.%(ext)s"

# Use yt-dlp to download the auto-generated subtitles directly into the temporary file without adding extra extensions
yt-dlp --skip-download --restrict-filenames --trim-filenames "50" --write-auto-sub --sub-format srt --convert-subs srt --quiet -o "${OUTPUT_TEMPLATE}" "${YOUTUBE_URL}" "$@"

declare -a files=(${output_prefix}-*)
echo "${files[@]}"
# Check if the subtitles file was created
if [ ${#files[@]} -eq 1 ]; then
    # sed -e 's/^WEBVTT.*$//' -e '/^$/d' -e 's/^[0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]\{3\} --> [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}\.[0-9]\{3\}$//' -e '/^NOTE.*$/' -e '/^$/d' "${files[0]}"
    echo "Subtitles have been downloaded and saved to ${files[0]}" >&2
    cat "${files[0]}"
    # Further processing of the subtitles file can be done here if needed
else
    [ ${#files} -gt 1 ] && echo "Error: More than one subtitle file was extracted." || echo "Error: No output file." >&2
    echo "Subtitles were not downloaded." >&2
fi