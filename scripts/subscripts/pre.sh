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

$root/scripts/subscripts/logger.sh "$DEVICE_NAME mounted on $mount_point"

$root/scripts/subscripts/logger.sh "Connected $DEVICE_NAME"

if [ ! -f $mount_point/synapse-key ] || [ ! -r $mount_point/synapse-key ]; then
    $root/scripts/subscripts/logger.sh "Cannot find synapse-key file on $DEVICE_NAME or cannot read"
    exit 0
fi

rm $mount_point/synapse-log.tar
rm -r $mount_point/synapse-log
mkdir $mount_point/synapse-log

if [ ! -d $mount_point/synapse-log ]; then
    $root/scripts/subscripts/logger.sh "Cannot recreate synapse-log file on $DEVICE_NAME"
    exit 0
fi

mkdir $mount_point/synapse-log/logs
mkdir $mount_point/synapse-log/logs/synapse
mkdir $mount_point/synapse-log/logs/installer
touch $mount_point/synapse-log/logs/installer/log.txt
mkdir $mount_point/synapse-log/cache
mkdir $mount_point/synapse-log/manual-selected
mkdir $mount_point/synapse-log/current-states

$root/scripts/subscripts/install.sh $DEVICE_NAME $mount_point
