#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1

sleep 1
device_info=$(df -T $DEVICE_NAME | tail -n 1 | awk '{print $2} {print $5}')
file_system=$(echo $device_info | cut -d " " -f 1)
free_space=$(echo $device_info | cut -d " " -f 2)

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: File system: $file_system. Free Space: $free_space Kb"

mount_point="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"
mkdir $mount_point
sudo chmod 777 $mount_point 
sudo systemd-mount $DEVICE_NAME $mount_point

res=$?
if [ $res -ne 0 ] && [ $res -ne 141 ]; then
  # algoritm
  # extract disk
  # sudo system-mount --umount $mount_point
  # remove .mount
  # sudo systemctl daemon-reload
  # reboot server
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: FATAL ERROR cannot mount on $mount_point error code: $res"
  exit $res
fi

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: mounted on $mount_point"

if [ ! -f $mount_point/synapse-key ] || [ ! -r $mount_point/synapse-key ]; then
    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot read"
    exit 0
fi

cp -f $root/synapse-key $mount_point/synapse-key

if [ $? -ne 0 ]; then
    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot write"
    exit 0
fi

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Connected" $DEVICE_NAME
sudo $root/scripts/subscripts/install.sh $DEVICE_NAME
