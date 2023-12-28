#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

log_str="$(date +"%d-%m-%y %T") - $1"

echo $log_str & disown

server_log=$root/logs/installer.log
echo $log_str >> $server_log

if [ $2 ]; then
    client_log="$root/mnt/$(echo $2 | rev | cut -d'/' -f 1 | rev)/logs/installer.log"
    echo $log_str >> $client_log
fi
