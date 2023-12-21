#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*}

DEVICE_NAME=$1

$root/scripts/subscripts/logger.sh "Start connection new device: $DEVICE_NAME."

$root/scripts/subscripts/pre.sh $DEVICE_NAME & disown 
