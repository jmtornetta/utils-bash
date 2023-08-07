#!/bin/bash

run_command_on_git_diff_files() {
  declare -a command=()
  declare staged_only_param="--cached"

  # Process command-line options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a | --all)
        unset staged_only_param
        shift
        ;;
      *)
        command+=("$1")
        shift
        ;;
    esac
  done

  diff_files=$(git diff --name-only $staged_only_param)

  for cmd in "${command[@]}"; do
    for file in $diff_files; do
      # command must be run without quotes so all arguments are passed to it separately
      ($cmd "$file") & # run each command concurrently
    done
  done

  wait
}

run_command_on_git_diff_files "$@"
