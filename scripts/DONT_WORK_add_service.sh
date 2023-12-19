#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*}

sudo sed -e "s|__ROOT__|$root|" $root/templates/updater.mount > /etc/systemd/system/updater.mount 

sudo systemctl enable updater.mount
sudo systemctl start updater.mount

