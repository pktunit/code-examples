#!/bin/bash
##
##This script rsync's client specified on the command-line and directories specified in /usr/local/medbin/backup_dirs.txt. 
##
client=$1
RUNDATE=$(date +%Y/%m/%d)
LOGDATE=$(date +%Y%m%d)
DATETIME=$(date +%Y-%m-%d:%H:%M:%S)
HOST=`uname -n`
DIRS=/usr/local/medbin/backup_dirs.txt
#CLIENTS=$(grep -v '#' /etc/customers | awk '/ Invoice/ {print $1}')
rm /var/log/company/backup_$client.log
START=$(date +%Y-%m-%d:%H:%M:%S)

echo 'Start - ' $START >> /var/log/company/backup_$client.log
echo '-------------------' >> /var/log/company/backup_$client.log
echo ' ' >> /var/log/company/backup_$client.log

echo "CLIENT - " $client >> /var/log/company/backup_$client.log

for dir in $(cat $DIRS)
do
	echo '-------------------' >> /var/log/company/backup_$client.log
	echo "DIRECTORY - " $client/$dir >> /var/log/company/backup_$client.log 
	echo '-------------------' >> /var/log/company/backup_$client.log
	echo ' ' >> /var/log/company/backup_$client.log

	rsync -tuvz --partial --exclude="*.gnt" --exclude="*.so" --exclude="*.LOG" --exclude="*.log" --exclude="RPC*" /company/$client/$dir/* /mnt/archive/company/$client/$dir/ >> /var/log/company/backup_$client.log 2>&1
done

echo ' ' >> /var/log/company/backup_$client.log

END=$(date +%Y-%m-%d:%H:%M:%S)
echo 'End - '$END >> /var/log/company/backup_$client.log

cat /var/log/company/backup_$client.log | mail -s "$client on $HOST backup complete for $LOGDATE" admins@company.com
