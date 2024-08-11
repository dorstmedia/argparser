#!/bin/bash

# set a default (must use -e option to include it)
export hcmntextra='date "+%Y%m%d %R"'      # you must be really careful to get the quoting right

# start using it
[ "$hcmnt_variant" == "lite" ] \
&& export PROMPT_COMMAND='hcmnts' \
|| export PROMPT_COMMAND='hcmnt'
