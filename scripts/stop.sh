#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*}

DEVICE_NAME=$1
mount_point="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"

sudo systemd-mount --umount $mount_point
rmdir $mount_point

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Disconnected"
