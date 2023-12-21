#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk=$2

$root/scripts/subscripts/logger.sh "Start install $DEVICE_NAME" $DEVICE_NAME
