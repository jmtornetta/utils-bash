#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta
# Usage: Type -h or --help for usage instructions
start() { # collapse this function for readability
  set -Eeuo pipefail

  # Parameters
  declare -ir reqArgs=1 # enter number of required arguments for module
  declare -ar reqParams=( "-P|--param1" ) # enter regex pattern for required parameters for module
  
  # Declarations
  declare -a args # container for arguments less parameters
  declare -A params # associative array container for key-values of parameters
  declare -i flag # a flag is a binary parameter; it has no value pair
  declare -i silent
  declare -i verbose

  # Setup
  declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
  declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}") # script name
  declare -r nSCRIPT=${SCRIPT%.*} # script name without extension (for log)
  declare -r TODAY=$(date +"%Y%m%d" | sed 's/^[2-9][0-9]//') # removes first two digits from year
  declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"
  cd "$DIR" # ensure in this function's directory
  trap cleanup SIGINT SIGTERM ERR EXIT

  cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # add additional script cleanup commands here
  }
  die() {
    declare -r err="$1"
    declare -ir code="${2-1}" # default exit status 1
    printf >&2 "\n%s\n" "#~~~~ ERROR ~~~~#" "$err"
    exit "$code"
  }
  msg() {
    # puts 'printf' delim second, assigns default, and redirects to stderr so only shows in console/log (not script output)
    # shellcheck disable=SC2059
    if [[ "${silent:-}" == 1 ]]; then
      return 0
    elif [[ "$1" =~ (%s|%d|%c|%x|%f|%b) ]]; then
      printf >&2 "$1" "${@:2}"
    else
      printf >&2 "\n%s\n" "${@}" # two line breaks is better for messages following user-input prompts
    fi
  }
  parse_params() { # processes all parameters and then removes them from array of arguments supplied to function
    # default values of variables set from params
    flag=0

    while :; do # run until all parameters are processed; end as soon as an argument is found without a preceding "-"
      case "${1-}" in # '${1-}' sets default to 'null'
      -h | --help) usage ;;
      -v | --verbose) verbose=1 && set -x ;;
      -s | --silent) silent=1 ;;
      -P | --param1) # example; copy-paste this case for more parameters
        ! [[ "${2:-}" =~ ^[a-zA-Z0-9[:blank:]]{1,100}$ ]] && die "Parameter value invalid." # Check parameter format using regex here
        params["$1"]="$2"
        msg "P1 parameter set!" # Sample action
        shift # removes the 'param' value from the array of arguments supplied to script so additional arguments can be processed
        ;;
      -p | --param2) # example; copy-paste this case for more parameters
        ! [[ "${2:-}" =~ ^[a-zA-Z0-9[:blank:]]{1,100}$ ]] && die "Parameter value invalid." # Check parameter format using regex here
        params["$1"]="$2"
        msg "P2 parameter set!" # Sample action
        shift # removes the 'param' value from the array of arguments supplied to script so additional arguments can be processed
        ;;
      -?*) die "Unknown option: $1" ;;
      *) break ;;
      esac
      shift # removes each processed parameter from the array of arguments so additional arguments can be processed
    done

    args=("$@") # assign remaining arguments to 'args'

    set -- "" # Unset args so not referenced by sourced scripts. See https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin.

    # check for required params and arguments
    for i in "${!reqParams[@]}"; do
      [[ ! "${!params[*]}" =~ ${reqParams[i]} ]] && die "Missing required parameter: '${reqParams[i]}'." # if parameter is required
    done
    [[ ${#args[@]} < $reqArgs ]] && die "Missing script arguments." # if argumment is required

    return 0
  }
  join_arr() {
    # Usage: join_arr ", " "${arr[@]}"
    (($#)) || return 1 # At least delimiter required
    declare -- delim="$1" str IFS=
    shift
    str="${*/#/$delim}" # Expand arguments with prefixed delimiter (Empty IFS)
    echo "${str:${#delim}}" # Echo without first delimiter
  }
  usage() {
    cat <<-EOF
USAGE: $SCRIPT -p1 param_value [-p2 param_value] [-h] [-v] [-s] arg1 [arg2...]

Program description goes here.

ARGUMENTS:
1) Required. Argument description.
2) Optional. Argument description.

OPTIONS:
-v, --verbose       Verbose shows line-by-line module messages.
-h, --help        Help shows this usage message.
-s, --silent        Suppresses messages defined in script without suppressing standard output or standard error streams.
-P, --param1        Some required parameter.
-p, --param2        Some optional parameter.

EXAMPLES:
1) Example 1

EOF
    trap '' EXIT # unset the exit trap when '--help' is defined
    exit 0 # exits the script without an error
  }
  body() {
    #~~~ BEGIN SCRIPT ~~~#

    # import "$DIR/vars" # example; include source vars/files here
    # reference args from "${args[@]}" array since they are unset to avoid conflicts
    msg "\n%s\n\n" "Hello World!"

    #~~~ END SCRIPT ~~~#
  }
  footer() {
    # joins arguments array into delimited string; joins parameters array into delimited string of key-value pairs
    [[ "${verbose:-}" != 1 ]] && return
    msg '%s\n' "Inputs for '$SCRIPT' in '$DIR'..." \
    "- arguments: $(join_arr ", " "${args[@]}")" \
    "- parameters: $(declare -a arr; for key in "${!params[@]}"; do arr+=("$key:${params[$key]}"); done; join_arr ", " "${arr[@]}")" \
    "- flag: ${flag}"
  }
  printf '\n\n%s\n%s\n\n' "#~~~$(date)~~~#" "Raw Inputs: $*" >>"$LOG"
  parse_params "$@" # filter parameters from arguments
  body "${args[@]}" && footer "${args[@]}" |& tee -a "$LOG" # pass filtered arguments to main script and stream console to log; NOTE: do not use 'tee' with 'select' menus!
}
start "$@"