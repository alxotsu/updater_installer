#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

log_str="$(date +"%d-%m-%y %T") - $1"

server_log=$root/logs/log.txt
echo $log_str >> $server_log
