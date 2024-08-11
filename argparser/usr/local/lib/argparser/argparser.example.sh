#!/bin/bash
# Set "LIB_ARGPARSER" to define a folder containing all files of this repo
# You can also add this to your .bashrc to set this globally
# Declare and export lib path and source lib file to declare and export global variables
export LIB_ARGPARSER="/root/.local/lib/argparser"; [ -f "${LIB_ARGPARSER}/argparser.lib.sh" ] && source "${LIB_ARGPARSER}/argparser.lib.sh"

# Declare yout arguments and source "argparser.sh" here to parse script arguments 
#   declare -A argparser_definitions; argparser_definitions=( ["p"]="path" )
#   [ -f "${LIB_ARGPARSER}/argparser.sh" ] && source "${LIB_ARGPARSER}/argparser.sh"
# Source debug file to print parsed arguments
#   [ -f "${LIB_ARGPARSER}/argparser.debug.sh" ] && source "${LIB_ARGPARSER}/argparser.debug.sh"

argparser_example_function(){ \
    # Declare flag definitions before you source argparser.sh
    # Define your flags to translate short flags/opts to fulltext flags/opts
    # In this example is defined:
    #   -p=test is same as --path=test 
    #   -t is same as --test
    declare -A argparser_definitions; argparser_definitions=( \
        ["p"]="path" \
        ["t"]="test" \
    )
    # Source here to parse function arguments 
    source "argparser.sh"
    # Source debug file to print parsed arguments
    source "argparser_debug.sh" # Output will look like this:
    # -------------------------------------------------------
    # Flags:
    # - flags[test]=true
    # -------------------------------------------------------
    # Opts:
    # - opts[path]=test
    # -------------------------------------------------------
    # Args:
    # - args[0]=xyz
    # -------------------------------------------------------

    # You can also read stdin to pipe to this funcion
    # and parse arguments simultaniously 
    
    local lines=(); local line="";
    # read stdin and loop lines
    while read -r line; do 
      # save all input lines in array
      lines+=("$line"); 
      # use parsed arguments in loop
	    echo "${flags_l[@]} - ${line}"; 
    done
    # or use parsed arguments anywhere else inside the function
    echo "${flags_l[@]}"
    # Use stdin lines from line sarray
    for line in "${lines[@]}"; do 
      echo "${line}"; 
    done
}
# pipe output to your function and use flags/opts/args for example to customize output
ls | argparser_example_function -t -p=test "xyz"

