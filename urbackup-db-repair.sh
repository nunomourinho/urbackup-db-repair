#!/bin/bash

urbackuppath=`cat /etc/urbackup/backupfolder`
urbackuppath="/dados/urbackup"
backuppath="/dados"


echo backup databases
tar cvfz $backuppath/backup-urbackup-$(date +"%m_%d_%Y")-$RANDOM.tar.gz $urbackuppath/backup_server*
if [ $? -eq 0 ]; then
    echo Backup Sucessfull
else
    echo Error in backup. Aborting!
    exit 1
fi

for f in $urbackuppath/backup_server*.db; do
   echo "Testing database " $f
   echo "PRAGMA integrity_check;" | sqlite3 $f | grep ok
   if [ $? -eq 0 ]; then
       echo Database with no errors. Skiping recovery
   else
       echo Database with errors. Implementing recovery actions.
       echo "1) Rename damaged database" $f $f.DAMAGED
       mv $f $f.DAMAGED
       echo "2) clone data from damaged database to recovered database" $f.DAMAGED
       echo .clone $f | sqlite3 $f.DAMAGED
       echo "3) Deleting" $f.DAMAGED
       rm $f.DAMAGED*
   fi
done;

chown urbackup:urbackup $urbackuppath -R


