#!/bin/bash
# Contribution of the President, Keith M. Hoodlet, 04.13.2016
#
# Written by the UNH Linux Club
read_passwd() {
	stty -echo
	read -p "Password: " passw; echo
	stty echo
}

check_reqs() {
	# Make sure we're running Linux and not on a Mac
	OS_NAME=`uname`
	if [ ! $OS_NAME == "Linux" ]
	then
		return 0
	fi

	# Check if we're running a supported distro
	# TODO: Don't assume /etc/issue exists
	IS_MINT=$( grep -ic "Linux Mint" /etc/issue )
	IS_UBUNTU=$( grep -ic "Ubuntu" /etc/issue )
	if [[ ! $IS_MINT -eq 1 ]] && [[ ! $IS_UBUNTU -eq 1 ]]
	then
		return 0
	fi

	return 1
}

intro() {
	echo "======================================"
	echo "===== UNH Easy WiFi Setup Script ====="
	echo "======================================"
	echo ""

	check_reqs
	if [ $? -eq 0 ]
	then
		echo "Error: distribution not supported."
		exit 1
	fi

	echo -n "System Information: "
	echo "`uname` `uname -r`"
}

get_info() {
	read -p "Username: " user
	stty -echo
	read -p "Password: " passw; echo
	stty echo

	# Don't actually do this in production.
	echo "User: $user Password: $passw"
}

# Run the script and cx
if [ $EUID != 0 ]
then
	intro

	echo "Root access is needed to run this script. Attempting to elevate permissions..."
	echo ""
	exec sudo "$0" "$@"
else
	echo "======================================"
	echo "This script will attempt to automatically setup the WiFi connection"
	echo "on your new Linux PC. You will need your UNH username and password"
	echo "(same as Blackboard)."
	echo ""

	get_info
fi

# Get user input.

exit 0
