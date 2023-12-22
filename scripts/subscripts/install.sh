#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk=$2

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start install" $DEVICE_NAME

declare -a files_to_copy

if [ ! -f $disk/get-synapse-log ]; then
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Found get-synapse-log file" $DEVICE_NAME

  while read filepath; do
    files_to_copy+=filepath
  done <$disk/get-synapse-log
else
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: get-synapse-log file not found" $DEVICE_NAME
fi

logs_types = ('device', 'driver', 'web', 'master', 'session_manager', 'user_manager')
for log_type in $log_types; do
  log_path="var/log/$log_type.log"
  files_to_copy += log_path
done

#for log_file in `ls -1 /srv/synapse/var/log`;
log_index=1
while [ 1 ]; do
    flag=0
    for log_type in $log_types; do
      log_path="var/log/$log_type.log.$log_index"

      /srv/synapse/
      files_to_copy += log_path
    done
    $log_index++
done







if [[ $filepath == /* ]]; then
      frompath=$filepath
      topath=$disk/synapse-log/manual-selected/other$frompath
    else
      frompath=/srv/synapse/$filepath
      topath=$disk/synapse-log/manual-selected/synapse/$filepath
    fi

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Coping manual selected $frompath -> $topath" $DEVICE_NAME

cp -flr $frompath $topath
result=$?
if [ $result -ne 0 ];
  # TODO find memory overflow error code
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot copy by code $result" $DEVICE_NAME
fi


$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End install" $DEVICE_NAME
$root/scripts/subscripts/update.sh $DEVICE_NAME $disk