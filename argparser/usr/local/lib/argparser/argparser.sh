#!/bin/bash
if [ "$LIB_ARGPARSER" == "" ]; then LIB_ARGPARSER="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"; [ -f "${LIB_ARGPARSER}/argparser.lib.sh" ] && source "${LIB_ARGPARSER}/argparser.lib.sh"; fi
[ "$argparser_declared" != true ] && [ -f "$ARGPARSER_INIT" ] && source "$ARGPARSER_INIT"

if [ "$argparser_declared" == true ]; then 
    while [ $# -gt 0 ]; do case $1 in
        -*=* | --*=* )
            opt="$(echo "${1:1}" | cut -d '=' -f1)"
            value="$(echo "${1:1}" | cut -d '=' -f2-99)"
            if [ "${opt:0:1}" == "-" ]; then opt="${opt:1}"
            elif [ "${argparser_definitions[$opt]}" != "" ]; then opt="${argparser_definitions[$opt]}"; fi
            opts["$opt"]="$value"; 
            shift; continue; ;;
        --* | -* )
            is_opt=false
            if [ $# -gt 1 ]; then
                if [ $# -gt 2 ]; then [ "${1:0:1}" == "-" ] && [ "${2:0:1}" != "-" ] && [ "${3:0:1}" == "-" ] && is_opt=true
                else [ "${1:0:1}" == "-" ] && [ "${2:0:1}" != "-" ] && is_opt=true; fi
            fi
            if [ "$is_opt" == true ]; then
                opt="${1:1}"; value="$2"
                if [ "${opt:0:1}" == "-" ]; then opt="${opt:1}"
                elif [ "${argparser_definitions[$opt]}" != "" ]; then opt="${argparser_definitions[$opt]}"; fi
                opts["$opt"]="$value"; 
                shift; shift; continue;
            else
                if [ "${1:0:2}" == "--" ];  then flag="${1:2}"
                elif [ "${1:0:1}" == "-" ]; then 
                    flag="${1:1}"
                    [ "${argparser_definitions[$flag]}" != "" ] && flag="${argparser_definitions[$flag]}"
                fi
                flags_l+=("$flag"); 
                flags[$flag]=true; 
                shift; continue;
            fi
        ;;
        *) args+=("$1"); shift; continue; ;;
    esac done
fi
