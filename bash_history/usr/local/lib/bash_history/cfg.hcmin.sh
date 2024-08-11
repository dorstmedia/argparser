#!/bin/bash
export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend                      # append to history, don't overwrite it

[ "$HIST_PROMPT_COMMAND_METHOD" == "" ] && HIST_PROMPT_COMMAND_METHOD=0
if [ "$HIST_PROMPT_COMMAND_METHOD" == "0" ]; then
  # After each command, append to the history file and reread it
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
elif [ "$HIST_PROMPT_COMMAND_METHOD" == "1" ]; then
  # Save and reload the history after each command finishes
  export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
fi
