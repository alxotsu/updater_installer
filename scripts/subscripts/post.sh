#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start post" $DEVICE_NAME

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End post" $DEVICE_NAME
sudo $root/scripts/subscripts/post.sh $DEVICE_NAME