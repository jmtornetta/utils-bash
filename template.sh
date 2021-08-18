#!/usr/bin/env bash
# Author: Jon Tornetta https://github.com/jmtornetta
# Usage: Type -h or --help for usage instructions
initialize () {
    local DIR
    DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    local LOG="$DIR/${BASH_SOURCE[0]}.log"
body () {
    set -Eeuo pipefail
    trap cleanup SIGINT SIGTERM ERR EXIT
usage() {
    cat <<- EOF
    USAGE: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]
    
    Program deletes files from filesystems to release space. 
    It gets config file that define fileystem paths to work on, and whitelist rules to 
    keep certain files.

    OPTIONS:
       -c --config              configuration file containing the rules. use --help-config to see the syntax.
       -n --pretend             do not really delete, just how what you are going to do.
       -t --test                run unit test to check the program
       -v --verbose             Verbose. You can specify more then one -v to have more verbose
       -x --debug               debug
       -h --help                show this help
          --help-config         configuration help
    
    EXAMPLES:
       1) Example 1
       2) Example 2
       3) Example 3
       
    CREDITS: 
        1) https://betterdev.blog/minimal-safe-bash-script-template/
        2) http://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/
EOF
}
    cleanup() {
        trap - SIGINT SIGTERM ERR EXIT
        # script cleanup here
    }
    setupColors() {
        if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
            NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
        else
            # shellcheck disable=SC2034  # Unused variables left for readability
            NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
        fi
    }
    msg() {
        echo >&2 -e "${1-}"
    }

    die() {
        local msg=$1
        local code=${2-1} # default exit status 1
        msg "$msg"
        exit "$code"
    }

    parseParams() {
        # default values of variables set from params
        flag=0
        param=''

        while :; do
            case "${1-}" in
            -h | --help) usage ;;
            -v | --verbose) set -x ;;
            #-f | --flag) flag=1 ;; # example flag
            #-p | --param) ;; # example required named parameter
            --no-color) NO_COLOR=1
            param="${2-}" # example if parameter is required
            shift
            ;;
            -?*) die "Unknown option: $1" ;;
            *) break ;;
            esac
            shift
        done

        args=("$@")

        # check required params and arguments
        #[[ -z "${param-}" ]] && die "Missing required parameter: param" # if parameter is required
        #[[ ${#args[@]} -eq 0 ]] && die "Missing script arguments" # if argumment is required

        return 0
    }

    parseParams "$@"
    setupColors

    # INSERT script logic here

    msg "${RED}Read parameters:${NOFORMAT}"
    msg "- flag: ${flag}"
    msg "- param: ${param}"
    msg "- arguments: ${args[*]-}"
    
# call function, set variables, and write to log file
echo "hello world"

}
printf '\n\n%s\n\n' "---$(date)---" >> "$LOG"
body "$@" |& tee -a "$LOG"
}
initialize