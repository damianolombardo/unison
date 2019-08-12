#/bin/bash
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin
## Available variables: 
# AVAIL      : available space
# USED       : used space
# SIZE       : partition size
# SERIAL     : disk serial number
# ACTION     : if mounting, ADD; if unmounting, UNMOUNT; if unmounted, REMOVE; if error, ERROR_MOUNT, ERROR_UNMOUNT
# MOUNTPOINT : where the partition is mounted
# FSTYPE     : partition filesystem
# LABEL      : partition label
# DEVICE     : partition device, e.g /dev/sda1
# OWNER      : "udev" if executed by UDEV, otherwise "user"
# PROG_NAME  : program name of this script
# LOGFILE    : log file for this script

case $ACTION in
  'ADD' )
    #
    # Beep that the device is plugged in.
    #
    beep  -l 200 -f 600﻿ -n -l 200 -f 800
    sleep 2

    if [ -d $MOUNTPOINT ]
    then
      if [ $OWNER = "udev" ]
      then
        beep  -l 100 -f 2000 -n -l 150 -f 3000
        beep  -l 100 -f 2000 -n -l 150 -f 3000

        logger Started -t$PROG_NAME
        /usr/local/emhttp/webGui/scripts/notify -e "Unraid Server Notice" -s "Server Backup" -d "USB Backup started $LABEL" -i "normal"
        echo "Started: `date`" > $LOGFILE
        echo "MOUNTPOINT: $MOUNTPOINT" >> $LOGFILE
        echo "USB: $LABEL-$SERIAL" >> $LOGFILE
        logger usb_backup share -t$PROG_NAME
        
        HOSTFSPATH="/hostfs"
        DOCKERMOUNTDIR="$HOSTFSPATH$MOUNTPOINT/" 
        HOSTBACKUPDIR="/mnt/user/usb_backup/$LABEL-$SERIAL/"
        DOCKERBACKUPDIR="$HOSTFSPATH$HOSTBACKUPDIR"
        
        
        
        echo "UNISON 
         $DOCKERMOUNTDIR <---> $DOCKERBACKUPDIR
         $MOUNTPOINT/ <---> $HOSTBACKUPDIR" >> $LOGFILE
        mkdir -p "$HOSTBACKUPDIR" 2>&1 >> $LOGFILE

        echo "FSTYPE: $FSTYPE" >> $LOGFILE
        
        if [[ $FSTYPE == *'fat'* ]]
        then
            echo "Using FAT option" >> $LOGFILE
            docker exec -u 99:100 unison bash -c "unison '$DOCKERMOUNTDIR' '$DOCKERBACKUPDIR' -batch -fat" 2>&1 >> $LOGFILE
        else
            echo "Using NonFAT option" >> $LOGFILE
            docker exec -u 99:100 unison bash -c "unison '$DOCKERMOUNTDIR' '$DOCKERBACKUPDIR' -batch" 2>&1 >> $LOGFILE
       fi
        
        logger Syncing -t$PROG_NAME
        sync

        beep  -l 100 -f 2000 -n -l 150 -f 3000
        beep  -l 100 -f 2000 -n -l 150 -f 3000
        beep  -r 5 -l 100 -f 2000

        logger Unmounting USB Backup -t$PROG_NAME
        /usr/local/sbin/rc.unassigned umount $DEVICE

       echo "Completed: `date`" >> $LOGFILE
        logger USB Backup drive can be removed -t$PROG_NAME

        /usr/local/emhttp/webGui/scripts/notify -e "Unraid Server Notice" -s "Server Backup" -d "USB Backup completed $LABEL" -i "normal"
    fi
    else
        logger USB Backup Drive Not Mounted -t$PROG_NAME
  fi
  ;;

  'REMOVE' )
    #
    # Beep that the device is unmounted.
    #
    beep  -l 200 -f 800 -n -l 200 -f 600
  ;;

  'ERROR_MOUNT' )
	/usr/local/emhttp/webGui/scripts/notify -e "Unraid Server Notice" -s "Server Backup" -d "Could not mount USB Backup" -i "normal"
  ;;

  'ERROR_UNMOUNT' )
	/usr/local/emhttp/webGui/scripts/notify -e "Unraid Server Notice" -s "Server Backup" -d "Could not unmount USB Backup" -i "normal"
  ;;
esac
