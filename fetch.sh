#!/bin/bash
# Author: Jon Tornetta https://github.com/jmtornetta
# Usage: Type -h or --help for usage instructions
start() { # collapse this function for readability
  set -Eeuo pipefail

  # Parameters
  declare -ir reqArgs=1 # enter number of required arguments for module

  # Declarations
  declare -a args   # container for arguments less parameters
  declare -a params # container for key-values of parameters; not using associative array because multiple parameters can have same key for curl.
  declare -i silent
  declare -i verbose

  # Setup
  declare -r DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
  declare -r SCRIPT=$(basename "${BASH_SOURCE[0]}")          # script name
  declare -r nSCRIPT=${SCRIPT%.*}                            # script name without extension (for log)
  declare -r TODAY=$(date +"%Y%m%d" | sed 's/^[2-9][0-9]//') # removes first two digits from year
  declare -r LOG="/tmp/$TODAY-$nSCRIPT.log"
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

    while :; do       # run until all parameters are processed; end as soon as an argument is found without a preceding "-"
      case "${1-}" in # '${1-}' sets default to 'null'
      -h | --help) usage ;;
      -v | --verbose) verbose=1 && set -x ;;
      -s | --silent) silent=1 ;;
      -[1-3a-zA-Z]* | --[a-zA-z]*) # match any parameter that begins with - or -- and has at least one letter after it
        # ! [[ "${1:1}" =~ [a-zA-Z] ]] && die "Parameter value invalid." # Check parameter format using regex here
        # ensure that the parameter is not a flag
        { [[ "${2:0}" == - ]] && params+=("$1"); } || { params+=("$1" "$2") && shift; }
        ;;
      *)
        [[ -z "${1:-}" ]] && break
        # add to args
        args+=("$1")
        ;;
      esac
      shift # removes each processed parameter from the array of arguments so additional arguments can be processed
    done

    set -- "" # Unset args so not referenced by sourced scripts. See https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin.

    [[ ${#args[@]} < $reqArgs ]] && die "Missing script arguments." # if argumment is required

    return 0
  }
  join_arr() {
    # Usage: join_arr ", " "${arr[@]}"
    (($#)) || return 1 # At least delimiter required
    declare -- delim="$1" str IFS=
    shift
    str="${*/#/$delim}"     # Expand arguments with prefixed delimiter (Empty IFS)
    echo "${str:${#delim}}" # Echo without first delimiter
  }
  usage() {
    cat <<-EOF
USAGE: $SCRIPT [-h] [-v] [-s] URL [METHOD]

A simple 'curl' with sensible defaults for web development. Accepts all 'curl' options.

See all 'curl' options via 'curl --help all'.

ARGUMENTS:
1) Required. URL.
2) Optional. METHOD.

OPTIONS:
-v, --verbose       Verbose shows line-by-line module messages.
-h, --help          Help shows this usage message.
-s, --silent        Suppresses messages defined in script without suppressing standard output or standard error streams.

EXAMPLES:
1) ./fetch.sh "https://google.com" "POST" -d  --output myfile.txt -s

EOF
    trap '' EXIT # unset the exit trap when '--help' is defined
    exit 0       # exits the script without an error
  }
  body() {
    #~~~ BEGIN SCRIPT ~~~#

    # Define an array of valid HTTP methods
    declare -ar valid_methods=("GET" "POST" "PUT" "DELETE" "PATCH")
    declare -r url="$1"
    declare -r method="${2:-${valid_methods[0]}}"
    # default curl options. inherit silent/verbose and pass to curl.
    declare -a curl_opts=(-# -H 'Accept: */*' -H 'Content-Type:application/json' ${silent:+"-s"} ${silent:+"-S"} ${verbose:+"-v"})

    curl_opts+=("${params[@]}")

    [ !${silent:-} ] && msg "%s\n" "URL: '$url'" "METHOD: '$method'" "OPTIONS: $(join_arr ' | ' "${curl_opts[@]}")"

    # Check if the provided method is in the list of valid methods
    if ! [[ " ${valid_methods[@]} " =~ " $method " ]]; then
      echo "Invalid HTTP method. Valid methods: ${valid_methods[*]}"
      return 1
    fi

    # Execute the curl command
    curl "${curl_opts[@]}" -X "$method" "$url"

    #~~~ END SCRIPT ~~~#
  }
  footer() {
    # joins arguments array into delimited string; joins parameters array into delimited string of key-value pairs
    [[ "${verbose:-}" != 1 ]] && return
    msg '%s\n' "Inputs for '$SCRIPT' in '$DIR'..." \
      "- arguments: $(join_arr ", " "${args[@]}")" \
      "- parameters: $(join_arr ", " "${params[@]}")"
  }
  printf '\n\n%s\n%s\n\n' "#~~~$(date)~~~#" "Raw Inputs: $*" >>"$LOG"
  parse_params "$@"                                         # filter parameters from arguments
  body "${args[@]}" && footer "${args[@]}" |& tee -a "$LOG" # pass filtered arguments to main script and stream console to log; NOTE: do not use 'tee' with 'select' menus!
}
start "$@"
