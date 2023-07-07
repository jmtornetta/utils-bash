#!/bin/bash

run_command_on_staged_files() {
  declare command=("$@")
  staged_files=$(git diff --name-only --cached)

  for cmd in "${command[@]}"; do
    for file in $staged_files; do
      # command must be run without quotes so all arguments are passed to it separately
      ($cmd "$file") &
    done
  done

  wait
}

run_command_on_staged_files "$@"
