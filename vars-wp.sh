#!/bin/bash
lastSiteID=$(wp site list --fields=blog_id,url --format=csv | tail -n 1 | sed -n 's/\([0-9]\+\).*/\1/p'); declare -irx lastSiteID # Gets the last blog ID value from a multisite