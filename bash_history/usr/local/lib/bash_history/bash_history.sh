#!/bin/bash
hc_src_err=false; src_file_name="";

# set variant to "hcmnt" for full version 
hc_variant="hcmnt" 

# set variant to "hcmnts" for compact version 
# hc_variant="hcmnts" 

# set variant to "hcmin" for minimal version 
# hc_variant="hcmin" 

if [ "$hc_variant" == "hcmnt" ] || [ "$hc_variant" == "hcmnt" ]; then src_file_name="fn.${hc_variant}.sh"
elif [ "$hc_variant" == "hcmin" ]; then src_file_name="cfg.${hc_variant}.sh"; fi
if [ "$src_file_name" != "" ]; then
  # set source file for function or lib
  src_file="$(dirname "${BASH_SOURCE[0]}")/${src_file_name}"
  # check if src file exists
  if [ -f "$src_file" ]; then
    # source selected version of function and start using it
    source "$src_file" || hc_src_err=true
    # check if src file was sourced successfully
    if [ "$hc_src_err" == false ]; then
      if [ "$hc_variant" == "hcmnt" ] || [ "$hc_variant" == "hcmnt" ]; then 
          # set hcmnt/hcmnts variant specific stuff
          export hcmntextra='date "+%Y%m%d %R"' \
          export PROMPT_COMMAND="${hc_variant}"
      fi
    fi
  fi
fi
  

  
