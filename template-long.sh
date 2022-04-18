#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta
# Usage: Type -h or --help for usage instructions

start() { # collapse this function for readability
    declare -ir reqArgs=1 # enter number of required arguments for module
    declare -ar reqParams=() # enter number of required parameters for module
    declare -a args # container for arguments less parameters
    declare -A params # associative array container for key-values of parameters
    declare -i flag

    declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
    declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}") # script name
    declare -r nSCRIPT=${SCRIPT%.*} # script name without extension (for log)
    declare -r TODAY=$(date +"%Y%m%d")
    declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"
    cd "$DIR" # ensure in this function's directory

    body() {
        set -Eeuo pipefail
        trap cleanup SIGINT SIGTERM ERR EXIT
        cleanup() {
            # add additional script cleanup commands here
            printf "\n%s\n" "Exit Note: Script cleanup complete."
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
            # puts 'printf' delim second, assigns default, and redirects to stderr so only shows in console/log (not script output)
            # shellcheck disable=SC2059
            if [[ "$1" =~ (%s|%d|%c|%x|%f|%b) ]]; then
                printf >&2 "$1" "${@:2}"
            else
                printf >&2 "%s\n" "${@}"
            fi
        }
        die() {
            declare -r err=$1
            declare -ir code=${2-1} # default exit status 1
            msg "$err"
            exit "$code"
        }
        parseParams() { # processes all parameters and then removes them from array of arguments supplied to function
            # default values of variables set from params
            flag=0

            while :; do # run until all parameters are processed; end as soon as an argument is found without a preceding "-"
                case "${1-}" in # '${1-}' sets default to 'null'
                -h | --help) usage ;;
                -v | --verbose) set -x ;;
                -f | --flag) flag=1 && printf "\n%s\n" "Flag set successful." ;; # example flag
                -p1 | --param1) # example; copy-paste this case for more parameters
                    params["$1"]="${2-}"
                    shift # removes the 'param' value from the array of arguments supplied to script so additional arguments can be processed
                    ;;
                -p2 | --param2) # example; copy-paste this case for more parameters
                    params["$1"]="${2-}"
                    shift # removes the 'param' value from the array of arguments supplied to script so additional arguments can be processed
                    ;;

                --no-color) NO_COLOR=1 ;;
                -?*) die "Unknown option: $1" ;;
                *) break ;;
                esac
                shift # removes each processed parameter from the array of arguments so additional arguments can be processed
            done

            args=("$@") # assign remaining arguments to 'args'

            # check for required params and arguments
            for i in "${!reqParams[@]}"; do
                [[ ! "${!params[*]}" =~ ${reqParams[i]} ]] && die "Missing required parameter: '${reqParams[i]}'" # if parameter is required
            done
            [[ ${#args[@]} < $reqArgs ]] && die "Missing script arguments" # if argumment is required

            return 0
        }
        joinArr() {
            (($#)) || return 1 # At least delimiter required
            declare -- delim="$1" str IFS=
            shift
            str="${*/#/$delim}" # Expand arguments with prefixed delimiter (Empty IFS)
            echo "${str:${#delim}}" # Echo without first delimiter
        }
        import() {
            # shellcheck source=/dev/null
            { [[ -f "$1" ]] && source "$@" ; } || msg "Import file does not exist"
        }
        usage() {
            cat <<-EOF
USAGE: $SCRIPT [-h] [-v] [-f] -p param_value arg1 [arg2...]

Program description goes here.

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

EOF
            trap '' EXIT # unsets the exit trap when '--help' is defined
            exit 0 # exits the script without an error
        }

        parseParams "$@" # called after 'usage' is defined
        setupColors

        #~~~ BEGIN SCRIPT ~~~#
        import "$DIR/vars" # example; include source vars/files here
        printf "\n%s\n" "Hello World!"
        #~~~ END SCRIPT ~~~#

        msg "${RED}Inputs for '$SCRIPT' in '$DIR'...${NOFORMAT}" "\n%s\n"
        msg "- arguments: $(joinArr ", " "${args[@]}")" # joins arguments array into delimited string
        msg "- flag: ${flag}"
        msg "- parameters: $(declare -a arr; for key in "${!params[@]}"; do arr+=("$key:${params[$key]}"); done; joinArr ", " "${arr[@]}")" # joins parameters array into delimited string of key-value pairs
    }
    printf '\n\n%s\n\n' "---$(date)---" >>"$LOG"
    body "$@" |& tee -a "$LOG" # pass arguments to functions and stream console to log
}
start "$@" # pass arguments called during script source to body