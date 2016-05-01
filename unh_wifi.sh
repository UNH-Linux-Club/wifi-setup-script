#!/bin/bash
# Contribution of the President, Keith M. Hoodlet, 04.13.2016
#
# Written by the UNH Linux Club
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
	if [ ! $? -eq 1 ]
	then
		echo "Error: distribution not supported."
		exit 1
	fi

	echo -n "System Information: "
	echo "`uname` `uname -r`"
}

start_network() {
	echo -n "Starting network manager... "
	STATUS=$( start network-manager )
	if [[ ! $STATUS -eq 0 ]]
	then
		echo "failed."
		exit 1
	fi
}

check_if_already_registered() {
	echo -n "Scanning registered networks... "
	if [ -f /etc/NetworkManager/system-connections/UNH-Secure ]
	then
		echo "failed!"
		echo "There is already a network named UNH-Secure registered with the system."
		echo "Please forget it and then try again."
		exit 1
	else
		echo "done!"
	fi
}

get_info() {
	read -p "Username: " user
	stty -echo
	read -p "Password: " passw; echo
	stty echo

	# Don't actually do this in production.
	echo "User: $user Password: $passw"
	start_network
	check_if_already_registered
}

# Run the script and attempt to elevate if we can.
# We only print the opening intro if they're running as a standard
# user. If they're running as root, we skip it and go directly to
# the setup. This serves two purposes:
#
# a) it simplifies reducing duplicated code when the script is
#    launched again via sudo; and
# b) if they're advanced enough to be "taking the plunge" as root,
#    we can probably spare them noobish treatment.
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

exit 0
