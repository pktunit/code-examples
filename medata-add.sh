#!/bin/bash

# checks For Exceptions and Collisions
check_for_errors () {
corename=$(echo "${firstname:0:1}${lastname:0:3}" | tr '[:lower:]' '[:upper:]')
username=$(echo "${clientcode}${corename}" | tr '[:upper:]' '[:lower:]')
collision=$(grep -e "^${username}" /etc/passwd)
i="0"
if [ ${#lastname} -eq 2 ]; then
	corename="${firstname:0:1}${lastname:0:2}${i}"
	username=$(echo "${clientcode}${corename}" | tr '[:upper:]' '[:lower:]')
fi
while [ "$collision" != "" ]; do
  i=$((i+1))
	corename=$(echo "${firstname:0:1}${lastname:0:2}${i}" | tr '[:lower:]' '[:upper:]')
	username=$(echo "${clientcode}${corename}" | tr '[:upper:]' '[:lower:]')
	collision=$(grep -e "^${username}" /etc/passwd)
done
}

# allows User To Verify Login/Password Information
verify_info () {
read -rp "is this correct? Type (yes) to accept (no) to exit: " accept
case $accept in
	"n" | "no" )
	exit 1;;
	"yes" )
	add_user;;
	* )
	verify_info;;
esac
}

# runs Commands To Add User
add_user () {
     sudo /usr/sbin/useradd -g "${clientname}" -d "/home/${clientname} ${username}"
     echo "${pass}" | sudo /usr/bin/passwd "${username}" --stdin
}	

# checks If User Wishes To Launch Core
verify_core () {
echo ""
read -rp "do you wish to launch CORE? Type (yes) to start CORE (no) to exit: " coreaccept
case $coreaccept in
    "n" | "no" )
    exit 1;;
    "yes" )
    launch_core;;	
    * )
    verify_core;;
esac
}

# launches CORE
launch_core () {
    cd "/medata/$clientname/EXE" || return
    ./msset.ex
    cobrun ./smenu NEW STD SMENU.INI

}

# main 
read -rp "First Name: " firstname
read -rp "Last Name: " lastname
grep -v "#" /etc/customers
echo ""
echo "the Client Code is the two character code surrounded by parenthesis."
echo ""
read -rp "Client Code: " clientcode
clientname=$(grep "(${clientcode})" /etc/customers | awk '{print $1}')
check_for_errors
echo "please Verify the following information."
echo ""
echo "*****"
echo "Name: $firstname ${lastname}"
echo "Client: ${clientname}"
echo "Core Login: ${corename}"
echo "Core Password: ${corename}"
echo "$(hostname) login: ${username}"
pass=$(</dev/urandom tr -dc A-Za-z0-9 | head -c8)
echo "$(hostname) password: ${pass}"
#cryptpass=$(perl -e 'print crypt(${pass}, "salt")')
echo "*****"
echo ""
verify_info
verify_core
