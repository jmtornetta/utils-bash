#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta

start() {
    declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}") # script name
    declare -r nSCRIPT=${SCRIPT%.*} # script name without extension (for log)
    declare -r TODAY=$(date +"%Y%m%d")
    declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"
    cd "$DIR" # ensure in this function's directory

    body() {
        set -Eeuo pipefail
        #~~~ BEGIN SCRIPT ~~~#
        printf "\n%s\n" "Hello World!"
        #~~~ END SCRIPT ~~~#
    }
    printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"
    body "$@" |& tee -a "$LOG" # pass arguments to functions and stream console to log
}
start "$@" # pass arguments called during script source to body