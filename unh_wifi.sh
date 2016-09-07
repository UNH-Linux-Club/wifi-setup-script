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
	echo "Finding network interface..."
	interface=$(ip link | grep wlan)

	if [ $? == 0 ]; then
		interface=$(ip link | grep wlan | cut -d ':' -f 2 | xargs)
	else
		interface=$(ip link | grep wlp)

		if [ $? == 0 ]; then
			interface=$(ip link | grep wlp | cut -d ':' -f 2 | xargs)
		else
			ip link
			echo
			echo "Cannot find interface! Is your wireless card working?"
		fi
	fi

	echo "Creating UNH-Secure profile..."
	nmcli con add type wifi ifname $interface con-name UNH-Secure ssid UNH-Secure

	echo "Editing UNH-Secure profile..."
	nmcli con modify UNH-Secure 802-1x.eap peap 802-1x.identity $user 802-1x.password $passw 802-1x.phase2-auth mschapv2 802-11-wireless-security.auth-alg open 802-11-wireless-security.key-mgmt wpa-eap

	if [ $? == 0 ]; then
		echo "Done!"
	else
		exit 1
	fi
}

check_if_already_registered() {
	if [ -f /etc/NetworkManager/system-connections/UNH-Secure ]
	then
		echo "There is already a network named UNH-Secure registered with the system."
		echo "Please forget it and then try again."

		read -n 1 -p "Would you like us to remove it? [yn] " yn
		echo # read -n 1 doesn't make a new line

		case $yn in
			[Yy]* )
				nmcli con delete UNH-Secure
				echo
				;;
			[Nn]* )
				exit 1
				;;
			* ) echo "Please answer Yes or No"; exit;;
		esac
	fi
}

get_info() {
	read -p "Username: " user
	echo

	bad=true

	while $bad; do
		read -s -p "Password (the text will not show up): " passw
		echo
		read -s -p "Type your password again to verify: " passwTest
		echo

		if [ $passw != $passwTest ]; then
			echo "Passwords do not match, try again..."
			echo
		else
			bad=false
		fi
	done
}

main() {
	intro
	echo "======================================"
	echo "This script will attempt to automatically setup the WiFi connection"
	echo "on your new Linux PC. You will need your UNH username."
	echo "(same as Blackboard)."
	echo

	# We can assume they are using netowrk manager
	check_if_already_registered
	get_info
	run_nmcli

	echo
	echo "IMPORTANT: Restart your system, then try to connect to UNH-Secure via the wifi menu. Good luck."
}

main

exit 0
