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
}

run_nmcli() {
	echo "Creating UNH-Secure profile..."
	nmcli con add type wifi ifname wlp3s0 con-name UNH-Secure ssid UNH-Secure

	echo "Editing UNH-Secure profile..."
	nmcli con edit UNH-Secure <<EOF
set 802-1x.eap peap
set 802-1x.identity $user
set 802-1x.phase2-auth mschapv2
set 802-11-wireless-security.auth-alg open
set 802-11-wireless-security.key-mgmt wpa-eap
save
quit
EOF

	if [ $? != 0 ]; then
		exit 1
	fi
}

check_if_already_registered() {
	if [ -f /etc/NetworkManager/system-connections/UNH-Secure ]
	then
		echo "There is already a network named UNH-Secure registered with the system."
		echo "Please forget it and then try again."
		exit 1
		# TODO ask user if they would like us to delete it for them
	fi
}

get_info() {
	read -p "Username: " user
	echo
}

main() {
	intro
	echo "======================================"
	echo "This script will attempt to automatically setup the WiFi connection"
	echo "on your new Linux PC. You will need your UNH username."
	echo "(same as Blackboard)."
	echo ""

	# We can assume they are using netowrk manager
	check_if_already_registered
	get_info
	run_nmcli

	echo
	echo "IMPORTANT: Restart your system, then try to connect to UNH-Secure via the wifi menu. Good luck."
}

main

exit 0
