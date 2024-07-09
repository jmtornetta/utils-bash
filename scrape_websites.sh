#!/bin/bash

# Check if at least one domain was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <domain1> [domain2] ..."
  exit 1
fi

# Directory where you want to save the scraped content
base_directory="website-scrapes"

# Iterate over the command-line arguments, which are the domains
for domain in "$@"; do
  echo "Scraping $domain..."
  
  # Create a directory for each domain
  target_directory="$base_directory/$(echo $domain | sed 's/[^a-zA-Z0-9]/_/g')"
  mkdir -p "$target_directory"
  
  # Use wget to download the content
  wget --recursive --page-requisites --adjust-extension --span-hosts --convert-links --domains="$domain" --wait=3 --random-wait --execute robots=off --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" --directory-prefix="$target_directory" "$domain"
  
  echo "Scraping of $domain completed."
done

echo "All specified websites have been scraped."
