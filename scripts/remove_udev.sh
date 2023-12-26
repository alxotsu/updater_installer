#!/bin/bash

sudo rm /etc/udev/rules.d/updater.rules
sudo udevadm control --reload-rules && udevadm trigger

echo "rules remove"

