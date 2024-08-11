#!/bin/bash

if [ ! -d "/usr/local/lib/argparser" ]; then mkdir -p "/usr/local/lib/argparser"; fi
if [ ! -d "/etc/profile.d" ]; then mkdir -p "/etc/profile.d"; fi

if [ ! -f "/usr/local/lib/argparser/argparser.lib.sh" ]; then
  if [ -d "/tmp/argparser" ]; then rm -rf "/tmp/argparser"; fi
  git clone https://github.com/dorstmedia/argparser /tmp/argparser &>/dev/null \
  && chmod -R 777 /tmp/argparser \
  || return 1
  
  which rsync &>/dev/null && {
    rsync -av --update --remove-source-files "/tmp/argparser/etc/profile.d/" "/etc/profile.d/" \
    && rm -rf /tmp/argparser/etc \
    && rsync -av --update --remove-source-files "/tmp/argparser/" "/usr/local/lib/argparser/" \
    && rm -rf /tmp/argparser \
  } || {
    mv -f /tmp/argparser/etc/profile.d/* /etc/profile.d/
    mv -f /tmp/argparser/* /usr/local/lib/argparser/
  }
  [ -d /tmp/argparser ] && rm -rf /tmp/argparser
  
  && 
  
  #  && mv -f /tmp/argparser/etc/profile.d/*.sh /etc/profile.d/ \

fi
source "/usr/local/lib/argparser/argparser.lib.sh"
