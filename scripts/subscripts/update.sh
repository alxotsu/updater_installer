#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start update" $DEVICE_NAME

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End update" $DEVICE_NAME
