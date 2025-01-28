#!/bin/bash

# Directory containing the CSV files (default to current directory if none provided)
directory="${1:-.}"

# Collect data and format it with the column command using a pipe delimiter
{
  echo "File Path | Row Count"  # Add a header row
  echo "----------|----------"  # Add a divider row
  for file in "$directory"/*.csv; do
    if [[ -f "$file" ]]; then
      row_count=$(( $(wc -l < "$file") - 1 ))  # Exclude header
      echo "$file | $row_count"
    fi
  done
  echo
} | column -t -s '|'
