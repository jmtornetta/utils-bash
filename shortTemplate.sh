#!/usr/bin/env bash
# Author: Jon Tornetta https://github.com/jmtornetta

initialize() {
    local DIR
    DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    local LOG="${BASH_SOURCE[0]}.log"
    body() {
        set -Eeuo pipefail

        # call function, set variables, and write to log file
        echo "Hello world from $DIR"
    }
    printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"
    body "$@" |& tee -a "$LOG"
}
initialize