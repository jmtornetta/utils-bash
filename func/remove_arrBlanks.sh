#!/bin/bash
remove_arrBlanks() {
    # Usage: Provide array as input. Function removes empty items and rebuilds array using the same name. 
    # Example 1 (commmon): remove_arrBlanks inputArray
    # Example 2 (create new array from list): readarray -t newArray < <(remove_arrBlanks "hate" "" "empty" "array" "items")
    
    if [[ $# -eq 1 ]]; then # Input is an array variable.
        declare -n localArray="${1}" # Declare variable 'linked' to input (i.e. same namespace)
    elif [[ $# -gt 1 ]]; then # Input is a free array.
        declare localArray=( "${@}" ) # Put input array arguments into new array
    else echo "Usage: Provide array variable or array as an argument." && exit 1
    fi
    for i in "${!localArray[@]}"; do
        [[ -n "${localArray[${i}]}" ]] && finalArray+=( "${localArray[$i]}" ) # Add non-empty strings
    done && printf '%s\n' "${finalArray[@]}"
    localArray=( "${finalArray[@]}" ) && unset finalArray && unset -n localArray # Store new array in namespace variable and clean up
}