#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta

start() {
    source "" # load variables from config file
    local DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    local SCRIPT=$(basename "${BASH_SOURCE[0]}")
    local nSCRIPT=${SCRIPT%.*}
    local today=$(date +"%Y%m%d")
    local LOG="/tmp/$today-$nSCRIPT.log"
    cd "$DIR"                     # ensure in this function's directory

    body() {
        set -Eeuo pipefail

        # call function, set variables, and write to log file
        echo "Hello world from $DIR"

    }
    printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"
    body "$@" |& tee -a "$LOG" # pass arguments to functions and stream console to log
}
start "$@" # pass arguments called during script source to body