#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start install" $DEVICE_NAME

echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')%" >> $disk/synapse-log/cache/htop
echo "RAM: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')%" >> $disk/synapse-log/cache/htop
echo -e "\nTop 10 Procs:\n$(ps -eo %cpu,%mem,cmd --sort=-%cpu | awk 'NR<=11 {print $1, $2, $3}')" >> $disk/synapse-log/cache/htop

if [ -f $disk/get-synapse-log ]; then
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Found get-synapse-log file"
  while read filepath; do
    files_to_copy+=($filepath)
  done <$disk/get-synapse-log
else
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Not found get-synapse-log file"
fi

declare -a logs_types=('device' 'driver' 'web' 'master' 'session_manager' 'user_manager')
for log_type in ${logs_types[*]}; do
  log_path="var/log/$log_type.log"
  files_to_copy+=($log_path)
done

#for log_file in `ls -1 /srv/synapse/var/log`;
log_index=1
while true; do
  flag=false
  for log_type in ${logs_types[*]}; do
    log_path="var/log/$log_type.log.$log_index"
    if [ -f /srv/synapse/$log_path ]; then
	    flag=true
      files_to_copy+=($log_path)
    fi
  done
  if [ "$flag" = false ]; then
    break
  fi
  log_index=$((log_index + 1))
done

for filepath in ${files_to_copy[*]}; do
    if [[ $filepath == *var/log/* ]]; then
      frompath=/srv/synapse/$filepath
      topath="/synapse-log/logs/synapse/$(echo $frompath | rev | cut -d'/' -f 1 | rev)"
    elif [[ $filepath == /* ]]; then
      frompath=$filepath
      topath=/synapse-log/manual-selected/other$frompath
    else
      frompath=/srv/synapse/$filepath
      topath=/synapse-log/manual-selected/synapse/$filepath
    fi
    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Coping $frompath -> $topath" $DEVICE_NAME

    mkdir -p "$disk${topath%/*}"
    sudo cp -rf $frompath "$disk$topath"
    result=$?
    if [ $result -ne 0 ]; then
      $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot copy with code $result" $DEVICE_NAME
      if [ $result -eq 8 ]; then
        $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Memory overflow. Stop coping." $DEVICE_NAME
        break
      fi
    fi
done

# TODO have problems with memory using
touch $disk/synapse-log.tar.gz
$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start compressing $disk/synapse-log -> $disk/synapse-log.tar.gz" $DEVICE_NAME
pwdnow=$(pwd)
cd $disk
tar -cvzf synapse-log.tar.gz synapse-log && rm -r synapse-log
cd $pwdnow
$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End compressing synapse-log." $DEVICE_NAME

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End install" $DEVICE_NAME
sudo $root/scripts/subscripts/update.sh $DEVICE_NAME
