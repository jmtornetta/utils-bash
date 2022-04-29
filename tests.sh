#!/bin/bash

# Yes/No Prompt
printf '\n%s\t' "Say yes [y/N]?" && read -n 1 -r prompt
[[ $prompt =~ ^[Yy]?$ ]] && echo "You responded yes!"