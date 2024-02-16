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
  wget --restrict-file-names=windows --recursive --page-requisites --adjust-extension --span-hosts --convert-links --no-parent --domains "$domain" --wait=3 --random-wait --execute robots=off --user-agent="Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" --directory-prefix="$target_directory" "$domain"
  
  echo "Scraping of $domain completed."
done

echo "All specified websites have been scraped."
