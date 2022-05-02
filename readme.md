# About
A collection of bash utilities and templates. Start new projects faster and use consistent best practices.  
## Usage
Copy 'template-long.sh' and modify for standalone modules.  
Copy 'template-short.sh' and modify for short scripts and dependencies.  
Copy individual functions, tests, and variables from respective files/directories a-la-carte.  
## Index
### template-long.sh
Template for a full bash module, requiring arguments, parameters, usage instructions, and error handling.  
### template-short.sh
Template for small bash scripts and utility functions.  
### vars*.sh
Commonly used bash variables which can be sourced into other scripts.
## Credits
1. https://betterdev.blog/minimal-safe-bash-script-template/  
2. http://kfirlavi.herokuapp.com/blog/2012/11/14/defensive-bash-programming/  
# Plan
## Now
+ [ ] Make parse_params die if parameters are not supplied before arguments; or, make script smart enough to parse them differently (hard w/ bash)  
## Later
# Changelog
## 05/02/2021: Refactor
Remove 'easy-ssh' and add plan to 'readme.md'
## 04/29/2021: Release
1. New: 'msg' is now a smart 'printf' and operates with conditional default parameters.  
2. New: 'vars' files hold frequently used variable components.  
3. Refactor: Comments and structure for 'template-long.sh' 
4. Fix: Remove 'import' function; creates scoping problems.  
5. Refactor: Move 'set -e...' to top of script for better error catching.  
6. Refactor: Move closing message prompts to 'footer' function to keep 'body' limited to main script body.  
7. New: 'tests.sh' holds common logical tests.  
## 03/29/2021: Fix
1. Fix: 'body' function collects arguments from 'start' as expected.  
2. Refactor: Standardize heading variables.  
## 01/30/2021: Fix
1. Fix: Broken logfile path.  
2. Fix:  Broken trap clause.  
3. Create simple template.  
## 08/03/2021: Release
Initial template of best practices for safe bash scripting.
