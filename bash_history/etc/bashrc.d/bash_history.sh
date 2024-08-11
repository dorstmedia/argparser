#!/bin/bash
bash_history_lib_file="/usr/local/lib/bash_history/bash_history.sh"
if [ -f "$bash_history_lib_file" ]; then 
  source "$bash_history_lib_file"; 
fi
