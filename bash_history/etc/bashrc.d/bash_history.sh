#!/bin/bash
lib_root="/usr/local/lib"

lib_name="bash_history"
lib_dir="${lib_root}/${lib_name}"
lib_file="${lib_dir}/${lib_name}.lib.sh"
if [ -f "$lib_file" ]; then source "$lib_file"; fi
