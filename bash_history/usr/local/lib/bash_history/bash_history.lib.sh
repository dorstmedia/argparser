#!/bin/bash
hc_src_err=false; src_file_name="";

# set variant to "hcmnt" for full version 
hc_variant="hcmnt" 

# set variant to "hcmnts" for compact version 
# hc_variant="hcmnts" 

# set variant to "lite" for extended minimal version 
# hc_variant="lite" 

# set variant to "min" for minimal version 
# hc_variant="min" 

if [ "$hc_variant" == "hcmnt" ] || [ "$hc_variant" == "hcmnt" ]; then 
  src_file_name="fn.${hc_variant}.sh";
  if [ "$src_file_name" != "" ]; then
    # set source file for function or lib
    src_file="$(dirname "${BASH_SOURCE[0]}")/${src_file_name}"
    # check if src file exists
    if [ -f "$src_file" ]; then
      # source selected version of function and start using it
      source "$src_file" || hc_src_err=true
      # check if src file was sourced successfully
      if [ "$hc_src_err" == false ]; then
        export hcmntextra='date "+%Y%m%d %R"' \
        export PROMPT_COMMAND="${hc_variant}"        
      fi
    fi
  fi
elif [ "$hc_variant" == "lite" ] || [ "$hc_variant" == "min" ]; then
    export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
    export HISTSIZE=100000                   # big big history
    export HISTFILESIZE=100000               # big big history
    # When the shell exits, append to the history file instead of overwriting it
    shopt -s histappend                      # append to history, don't overwrite it
    if [ "$hc_variant" == "lite" ]; then
      # After each command, append to the history file and reread it
      PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
    elif [ "$hc_variant" == "min" ]; then
      # Save and reload the history after each command finishes
      export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
    fi
  fi
fi
