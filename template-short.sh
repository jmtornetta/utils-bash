#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta

start() {
    set -Eeuo pipefail
    declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}") # script name
    declare -r nSCRIPT=${SCRIPT%.*} # script name without extension (for log)
    # declare -r TODAY=$(date +"%Y%m%d" | sed 's/^[2-9][0-9]//') # removes first two digits from year
    # declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"  # Optionally include a log file
    # cd "$DIR" # ensure in this function's directory

    body() {
        echo 1>&2 "Running '$nSCRIPT' in '$DIR' from '$(pwd)'..." # Redirect to STDERR so it isn't included in script output
        #~~~ BEGIN SCRIPT ~~~#
        printf "\n%s\n" "Hello World!"
        #~~~ END SCRIPT ~~~#
    }
    # printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"  # Optionally copy STDOUT and STDERR to log
    # body "$@" |& tee -a "$LOG" # Optionally copy stream to log; NOTE: do not use 'tee' with 'select' menus!
    body "$@"
}
start "$@"