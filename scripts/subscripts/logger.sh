#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

log_str="$(date +"%d-%m-%y %T") - $1"

# echo $log_str

server_log=$root/logs/log.txt
echo $log_str >> $server_log

if [ $2 ]; then
    client_log="$root/mnt/$(echo $2 | rev | cut -d'/' -f 1 | rev)/synapse-log/logs/installer/log.txt"
    echo $log_str >> $client_log
fi
