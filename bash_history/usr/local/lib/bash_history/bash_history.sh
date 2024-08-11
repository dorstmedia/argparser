#!/bin/bash

# set either to "hcmnt" for full version 
# or "hcmnts" for compact version
hcmnt_fn="hcmnt" # hcmnt_fn="hcmnts" 
# set a default (must use -e option to include it)

# source selected version of function and start using it
fn_hcmnt_file="$(dirname "${BASH_SOURCE[0]}")/fn.${bash_history_fn}.sh"
[ -f "$fn_hcmnt_file" ] && source "$fn_hcmnt_file" && {
  export hcmntextra='date "+%Y%m%d %R"' \
  export PROMPT_COMMAND="${hcmnt_fn}"
}
