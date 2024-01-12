#!/bin/bash

path=$(readlink -f $0)
root=${path%/*/*/*}

DEVICE_NAME=$1
disk="$root/mnt/$(echo $DEVICE_NAME | rev | cut -d'/' -f 1 | rev)"

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Start install" $DEVICE_NAME

synapse_log=$(date +synapse-log-%Y%m%d-%H%M%S)
mkdir $disk/$synapse_log
mkdir $disk/$synapse_log/dirty-cache
tar -cf $disk/$synapse_log/manual-selected.tar -T /dev/null
tar -cf $disk/$synapse_log/synapse-logs.tar -T /dev/null
touch $disk/$synapse_log/hostid
touch $disk/$synapse_log/htop

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: Created $synapse_log folder" $DEVICE_NAME

hostid > $disk/$synapse_log/hostid

echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')%" >> $disk/$synapse_log/htop
echo "RAM: $(free -m | grep 'Mem' | awk '{print $3}') Mb" >> $disk/$synapse_log/htop
echo -e "\nTop 10 Procs:\n$(ps -eo %cpu,%mem,cmd --sort=-%cpu | awk 'NR<=11 {print $1, $2, $3}')" >> $disk/$synapse_log/htop


if [ -f $disk/get-synapse-log ]; then
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Found get-synapse-log file" $DEVICE_NAME
  while read filepath; do
    if [[ $filepath != var/log/* ]]; then
      files_to_copy+=($filepath)
    fi
  done <$disk/get-synapse-log
else
  $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Not found get-synapse-log file" $DEVICE_NAME
  gzip -9 $disk/$synapse_log/manual-selected.tar
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
    if [[ $filepath == var/log/* ]]; then
      if [ -f $disk/$synapse_log/manual-selected.tar ]; then
        gzip -9 $disk/$synapse_log/manual-selected.tar
      fi
      archive=$synapse_log/synapse-logs.tar
      directory=/srv/synapse/var/log
      frompath=$(echo $filepath | rev | cut -d'/' -f 1 | rev)

    else
      archive=$synapse_log/manual-selected.tar
      directory=$root/buffer/$DEVICE_NAME/$synapse_log

      if [[ $filepath == /* ]]; then
        frompath=other$filepath
        mkdir -p $directory/${frompath%/*}
        cp -rf $filepath $directory/$frompath
      else
        frompath=synapse/$filepath
        mkdir -p $directory/${frompath%/*}
        cp -rf /srv/synapse/$filepath $directory/$frompath
      fi
    fi

    $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Packing $frompath -> $archive" $DEVICE_NAME
    sudo tar -rf $disk/$archive -C $directory $frompath

    result=$?
    if [ $result -ne 0 ]; then
      $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Cannot pack with code $result" $DEVICE_NAME
      if [ $result -eq 8 ]; then  # TODO check memory overflow exit code
        $root/scripts/subscripts/logger.sh "$DEVICE_NAME: Memory overflow. Stop packing." $DEVICE_NAME
        break
      fi
    fi
done

gzip -9 $disk/$synapse_log/synapse-logs.tar
rm -r $root/buffer/$DEVICE_NAME/$synapse_log

$root/scripts/subscripts/logger.sh "$DEVICE_NAME: End install" $DEVICE_NAME
sudo $root/scripts/subscripts/update.sh $DEVICE_NAME
