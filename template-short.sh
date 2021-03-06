#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta

start() {
    set -Eeuo pipefail
    declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}") # script name
    declare -r nSCRIPT=${SCRIPT%.*} # script name without extension (for log)
    declare -r TODAY=$(date +"%Y%m%d" | sed 's/^[2-9][0-9]//') # removes first two digits from year
    declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"
    cd "$DIR" # ensure in this function's directory

    body() {
        #~~~ BEGIN SCRIPT ~~~#
        printf "\n%s\n" "Hello World!"
        #~~~ END SCRIPT ~~~#
    }
    printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"
    body "$@" |& tee -a "$LOG" # pass arguments to functions and stream console to log; NOTE: do not use 'tee' with 'select' menus!
}
start "$@"