#!/bin/bash
if [ "$LIB_ARGPARSER" == "" ]; then LIB_ARGPARSER="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"; [ -f "${LIB_ARGPARSER}/argparser.lib.sh" ] && source "${LIB_ARGPARSER}/argparser.lib.sh"; fi
declare is_opt; is_opt=false; declare ks; ks=""; declare kl; kl=""; 
declare declare_flags; [ "$argparser_global" == true ] && declare_flags=("-g") || declare_flags=(); 
declare "${declare_flags[@]}" argparser_declared; argparser_declared=true; \
declare "${declare_flags[@]}" params; params=("${@}"); 
declare "${declare_flags[@]}" args; args=(); 
declare "${declare_flags[@]}" flags_l; flags_l=(); \
declare -A "${declare_flags[@]}" flags; 
declare -A "${declare_flags[@]}" opts; 
[ ${#argparser_definitions[@]} -gt 0 ] && {
    declare -A "${declare_flags[@]}" argparser_definitions_reverse; \
    for ks in "${!argparser_definitions[@]}"; do 
        kl="${argparser_definitions[$ks]}"; 
        argparser_definitions_reverse[$kl]="${ks}"; 
    done
}
