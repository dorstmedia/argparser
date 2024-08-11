#!/bin/bash
echo "# -------------------------------------------------------"
echo "# Flags:"
for flag in "${!flags[@]}"; do echo "# - flags[${flag}]=${flags[$flag]}"; done
echo "# -------------------------------------------------------"
echo "# Opts:"
for opt in "${!opts[@]}";   do echo "# - opts[${opt}]=${opts[$opt]}"; done
echo "# -------------------------------------------------------"
echo "# Args:"
for arg in "${!args[@]}";   do echo "# - args[${arg}]=${args[$arg]}"; done
echo "# -------------------------------------------------------"
