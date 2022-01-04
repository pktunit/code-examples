#!/bin/sh

# Checks For Exceptions and Collisions
check_for_errors () {
CORENAME=$(echo "${FIRSTNAME:0:1}${LASTNAME:0:3}" | tr '[:lower:]' '[:upper:]')
USERNAME=$(echo "${CLIENTCODE}${CORENAME}" | tr '[:upper:]' '[:lower:]')
COLLISION=$(grep -e ^$USERNAME /etc/passwd)
i="0"
if [ ${#LASTNAME} -eq 2 ]; then
	CORENAME=$(echo "${FIRSTNAME:0:1}${LASTNAME:0:2}${i}")
	USERNAME=$(echo "${CLIENTCODE}${CORENAME}" | tr '[:upper:]' '[:lower:]')
fi
while [ "$COLLISION" != "" ]; do
	i=$[$i+1]	
	CORENAME=$(echo "${FIRSTNAME:0:1}${LASTNAME:0:2}${i}" | tr '[:lower:]' '[:upper:]')
	USERNAME=$(echo "${CLIENTCODE}${CORENAME}" | tr '[:upper:]' '[:lower:]')
	COLLISION=$(grep -e ^$USERNAME /etc/passwd)
done
}

# Allows User To Verify Login/Password Information
verify_info () {
read -p "Is this correct? Type (yes) to accept (no) to exit: " ACCEPT
case $ACCEPT in
	"n" | "no" )
	exit 1;;
	"yes" )
	add_user;;
	* )
	verify_info;;
esac
}

# Runs Commands To Add User
add_user () {
     sudo /usr/sbin/useradd -g $CLIENTNAME -d /home/$CLIENTNAME $USERNAME
     echo "$PASS" | sudo /usr/bin/passwd $USERNAME --stdin
}	

# Checks If User Wishes To Launch Core
verify_core () {
echo ""
read -p "Do you wish to launch CORE? Type (yes) to start CORE (no) to exit: " COREACCEPT
case $COREACCEPT in
    "n" | "no" )
    exit 1;;
    "yes" )
    launch_core;;	
    * )
    verify_core;;
esac
}

# Launches CORE
launch_core () {
    cd /medata/$CLIENTNAME/EXE
    . msset.ex
    cobrun ./SMENU NEW STD SMENU.INI

}

# Main 
read -p "First Name: " FIRSTNAME
read -p "Last Name: " LASTNAME
grep -v \# /etc/customers
echo ""
echo "The Client Code is the two character code surrounded by parenthesis."
echo ""
read -p "Client Code: " CLIENTCODE
CLIENTNAME=$(grep \($CLIENTCODE\) /etc/customers | awk '{print $1}')
check_for_errors
echo "Please Verify the following information."
echo ""
echo "*****"
echo "Name: $FIRSTNAME $LASTNAME"
echo "Client: $CLIENTNAME"
echo "CORE Login: $CORENAME"
echo "CORE Password: $CORENAME"
echo "$(hostname) Login: $USERNAME"
PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c8)
echo "$(hostname) Password: $PASS"
#CRYPTPASS=$(perl -e 'print crypt($PASS, "salt")')
echo "*****"
echo ""
verify_info
verify_core
