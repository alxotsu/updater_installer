#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1

sleep 1
device_info=$(df -T $DEVICE_NAME | tail -n 1 | awk '{print $2} {print $5}')
file_system=$(echo $device_info | cut -d " " -f 1)
free_space=$(echo $device_info | cut -d " " -f 2)

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: File system: $file_system. Free Space: $free_space"

mount_point="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"
mkdir $mount_point
sudo chmod 777 $mount_point 
sudo systemd-mount $DEVICE_NAME $mount_point

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: mounted on $mount_point"

if [ ! -f $mount_point/synapse-key ] || [ ! -r $mount_point/synapse-key ]; then
    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot read"
    exit 0
fi

rm $mount_point/synapse-log.tar*
rm -r $mount_point/synapse-log
mkdir $mount_point/synapse-log

if [ $? -ne 0 ]; then
    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot write"
    exit 0
fi

mkdir $mount_point/synapse-log/logs
mkdir $mount_point/synapse-log/logs/synapse
mkdir $mount_point/synapse-log/cache
mkdir $mount_point/synapse-log/manual-selected
mkdir $mount_point/synapse-log/current-states
mkdir -p $mount_point/logs

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Connected" $DEVICE_NAME
sudo $root/scripts/subscripts/install.sh $DEVICE_NAME
