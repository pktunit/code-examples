#!/bin/bash
##This script rsync's client specified on the command-line and directories specified in /usr/local/medbin/backup_dirs.txt. 

client="${1}"
logdate=$(date +%Y%m%d)
#rundate=$(date +%Y/%m/%d)
#datetime=$(date +%Y-%m-%d:%H:%M:%S)
host=$(uname -n)
dirs=/usr/local/medbin/backup_dirs.txt
#clients=$(grep -v '#' /etc/customers | awk '/ Invoice/ {print "${1}"}')
rm /var/log/company/backup_"${client}.log"
start=$(date +%Y-%m-%d:%H:%M:%S)

cat << EOF > "/var/log/company/backup_${client}.log"
Start - ${start}
-------------------
CLIENT - ${client}"
EOF

for dir in $(cat "${dirs}")
do
cat << EOF > "/var/log/company/backup_${client}.log"
-------------------
DIRECTORY - ${client}/${dir}
-------------------
EOF

rsync -tuvz --partial --exclude="*.gnt" --exclude="*.so" --exclude="*.LOG" --exclude="*.log" --exclude="RPC*" "/company/${client}/${dir}/"* "/mnt/archive/company/${client}/${dir}/" >> "/var/log/company/backup_${client}.log" 2>&1
done

echo >> "/var/log/company/backup_${client}.log"

end=$(date +%Y-%m-%d:%H:%M:%S)
echo "End - ${end}" >> "/var/log/company/backup_${client}.log"

mail -s "$client on ${host} backup complete for ${logdate}" admins@company.com < "/var/log/company/backup_${client}.log"
