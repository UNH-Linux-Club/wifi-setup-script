#!/bin/bash
# Contribution of the President, Keith M. Hoodlet, 04.13.2016
#
# Written by the UNH Linux Club
read_passwd() {
	stty -echo
	read -p "Password: " passw; echo
	stty echo
}

check_your_privilege() {
	if [ "$(whoami)" != 'root' ]; then
		echo "You have no permission to run $0 as non-root user."
		exit 1;
	fi
}

check_reqs() {
	set OS_NAME = `uname`
	if [ ! $OS_NAME == "Linux" ]
	then
		return 0
	fi

	return 1
}

main() {
	echo "======================================"
	echo "===== UNH Easy WiFi Setup Script ====="
	echo "======================================"
	echo ""

	#check_your_privilege
	check_reqs
	if [ $? -eq 0 ]
	then
		echo "Error: distribution not supported."
		exit 1
	fi
	
	echo -n "System Information: "
	echo "`uname` `uname -r`"
}

# Run the script.
main
exit 0
