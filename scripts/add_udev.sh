#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*}

# sudo touch /etc/systemd/system/systemd-udevd.service
# sudo echo "MountFlags=shared" > /etc/systemd/system/systemd-udevd.service


sudo sed -e "s|__ROOT__|$root|" $root/templates/updater.rules > /etc/udev/rules.d/updater.rules

sudo udevadm control --reload-rules && udevadm trigger

echo "rules add:"
sudo cat /etc/udev/rules.d/updater.rules
