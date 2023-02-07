#!/bin/bash

SCRIPT_NAME="start-mon.sh"
SCRIPT_VERSION="20230206"


# Purpose: Start and configure monitor mode on the provided wifi interface

# Usage: $ sudo ./start-mon.sh [interface:wlan0]


clear

# check to ensure sudo was used to start the script
if [ "$(id -u)" -ne 0 ]; then
	echo "You must run this script with superuser (root) privileges."
	echo "Try: \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# check to ensure iw is installed
if ! command -v iw >/dev/null 2>&1; then
	echo "A required package is not installed."
	echo "Please install the following package: iw"
	echo "Once the package is installed, please run \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# check to ensure ip is installed
if ! command -v ip >/dev/null 2>&1; then
	echo "A required package is not installed."
	echo "Please install the following package: ip"
	echo "Once the package is installed, please run \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# check to ensure rfkill is installed
if ! command -v rfkill >/dev/null 2>&1; then
	echo "A required package is not installed."
	echo "Please install the following package: rfkill"
	echo "Once the package is installed, please run \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# ensure WiFi radio is not blocked
sudo rfkill unblock wlan

# assign default monitor mode interface name
iface0mon='wlan0mon'

# assign default channel
chan=6

# activate option to set automatic (1) or manual (2) interface mode
#
# option 1: if you only have one wlan interface (automatic detection)
#iface0=`iw dev | grep 'Interface' | sed 's/Interface //'`
#
# option 2: if you have more than one wlan interface (default wlan0)
iface0=${1:-wlan0}


# set iface0 down
ip link set dev "$iface0" down
RESULT=$?
# if interface was successfully taken down, continue
if [ "$RESULT" = "0" ]; then
#	disable interfering processes
	PROCESSES="wpa_action\|wpa_supplicant\|wpa_cli\|dhclient\|ifplugd\|dhcdbd\|dhcpcd\|udhcpc\|NetworkManager\|knetworkmanager\|avahi-autoipd\|avahi-daemon\|wlassistant\|wifibox\|net_applet\|wicd-daemon\|wicd-client\|iwd"
#	unset match
#	match="$(ps -A -o comm= | grep ${PROCESSES} | grep -v grep | wc -l)"
	badProcs=$(ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID")
	for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
		command kill -19 "${pid}"   # -19 = STOP
	done
	clear
	echo
	echo ' The following processes have been stopped:'
	echo
	echo "${badProcs}"
	echo
	echo ' Note: The above processes can be returned'
	echo ' to a normal state at the end of this script.'
	echo
	read -p " Press any key to continue... " -n 1 -r

#	display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '"$iface0"
	echo ' --------------------------------'
	iface_name=$(iw dev "$iface0" info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' "$iface_name"
	iface_type=$(iw dev "$iface0" info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' "$iface_type"
	iface_state=$(ip addr show "$iface0" | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' "$iface_state"
	iface_addr=$(iw dev "$iface0" info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' "$iface_addr"
	echo ' --------------------------------'
	echo


#	set addr (has to be done before renaming the interface)
	iface_addr_orig=$iface_addr
	read -p " Do you want to set a new addr? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What addr do you want? ( e.g. 12:34:56:78:90:ab ) " iface_addr
#		need code to ID bad addresses
		ip link set dev "$iface0" address "$iface_addr"
	fi


#	set monitor mode
#	iw dev <devname> set monitor <flag>
#		Valid monitor flags are:
#		none:     no special flags
#		fcsfail:  show frames with FCS errors
#		control:  show control frames
#		otherbss: show frames from other BSSes
#		cook:     use cooked mode
#		active:   use active mode (ACK incoming unicast packets)
#		mumimo-groupid <GROUP_ID>: use MUMIMO according to a group id
#		mumimo-follow-mac <MAC_ADDRESS>: use MUMIMO according to a MAC address
	iw dev "$iface0" set monitor none


#	rename interface
	ip link set dev "$iface0" name $iface0mon


#	bring the interface up
	ip link set dev $iface0mon up

#	display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '"$iface0"
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' "$iface_name"
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' "$iface_type"
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' "$iface_state"
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' "$iface_addr"
	iface_chan=$(iw dev $iface0mon info | grep 'channel' | sed 's/channel //' | sed -e 's/^[ \t]*//')
	echo '    chan  - ' "$iface_chan"
	echo ' --------------------------------'
	echo

#	set channel
	read -p " Do you want to set the channel? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		read -p " What channel do you want to set? " chan
#		Documentation:
#		iw dev <devname> set channel <channel> [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#		iw dev <devname> set freq <freq> [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
#		iw dev <devname> set freq <control freq> [5|10|20|40|80|80+80|160] [<center1_freq> [<center2_freq>]]
#		Select one or modify as required:
		iw dev $iface0mon set channel "$chan"
#		iw dev $iface0mon set channel $chan HT40-
#		iw dev $iface0mon set channel $chan 80MHz
#		To test if channel was set correctly:
#		aireplay-ng --test <wlan0>
	fi

#	display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '"$iface0"
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' "$iface_name"
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' "$iface_type"
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' "$iface_state"
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' "$iface_addr"
	iface_chan=$(iw dev $iface0mon info | grep 'channel' | sed 's/channel //' | sed -e 's/^[ \t]*//')
	echo '    chan  - ' "$iface_chan"
	iface_txpw=$(iw dev $iface0mon info | grep 'txpower' | sed 's/txpower //' | sed -e 's/^[ \t]*//')
	echo '    txpw  - ' "$iface_txpw"
	echo ' --------------------------------'
	echo


#	set txpw
	read -p " Do you want to set the txpower? [y/N] " -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo " Note: Some USB WiFi adapters will not allow the txpw to be set."
		read -p " What txpw setting do you want to attempt to set? ( e.g. 2300 = 23 dBm ) " iface_txpw
		iw dev $iface0mon set txpower fixed "$iface_txpw"
	fi


#	display interface settings
	clear
	echo
	echo ' --------------------------------'
	echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
	echo ' --------------------------------'
	echo '    WiFi Interface:'
	echo '             '"$iface0"
	echo ' --------------------------------'
	iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
	echo '    name  - ' "$iface_name"
	iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
	echo '    type  - ' "$iface_type"
	iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
	echo '    state - ' "$iface_state"
	iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
	echo '    addr  - ' "$iface_addr"
	iface_chan=$(iw dev $iface0mon info | grep 'channel' | sed 's/channel //' | sed -e 's/^[ \t]*//')
	echo '    chan  - ' "$iface_chan"
	iface_txpw=$(iw dev $iface0mon info | grep 'txpower' | sed 's/txpower //' | sed -e 's/^[ \t]*//')
	echo '    txpw  - ' "$iface_txpw"
	echo ' --------------------------------'
	echo
	echo ' Note: DORMANT = interface is up '
	echo '       but inactive.             '
	echo

#	interface ready
	echo " The Interface is now ready for Monitor Mode use."
	echo
	echo ' You can place this terminal in'
	echo ' the background while you run any'
	echo ' applications you wish to run.'
	echo
	read -p " Press any key to continue... " -n 1 -r
	echo


#	return the adapter to original settings or not
	read -p " Do you want to return the adapter to original settings? [Y/n] " -n 1 -r
	if [[ $REPLY =~ ^[Nn]$ ]]
	then
#		display interface settings
		clear
		echo
		echo ' --------------------------------'
		echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
		echo ' --------------------------------'
		echo '    WiFi Interface:'
		echo '             '"$iface0"
		echo ' --------------------------------'
		iface_name=$(iw dev $iface0mon info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
		echo '    name  - ' "$iface_name"
		iface_type=$(iw dev $iface0mon info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
		echo '    type  - ' "$iface_type"
		iface_state=$(ip addr show $iface0mon | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
		echo '    state - ' "$iface_state"
		iface_addr=$(iw dev $iface0mon info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
		echo '    addr  - ' "$iface_addr"
		echo ' --------------------------------'
		echo
		exit 0
	else
		ip link set dev $iface0mon down
		ip link set dev $iface0mon address "$iface_addr_orig"
		iw $iface0mon set type managed
		ip link set dev $iface0mon name "$iface0"
		ip link set dev "$iface0" up
#		enable interfering processes
		for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
			command kill -18 "${pid}"   # -18 = CONT
		done
#		display interface settings
		clear
		echo
		echo ' --------------------------------'
		echo -e "    ${SCRIPT_NAME} ${SCRIPT_VERSION}"
		echo ' --------------------------------'
		echo '    WiFi Interface:'
		echo '             '"$iface0"
		echo ' --------------------------------'
		iface_name=$(iw dev "$iface0" info | grep 'Interface' | sed 's/Interface //' | sed -e 's/^[ \t]*//')
		echo '    name  - ' "$iface_name"
		iface_type=$(iw dev "$iface0" info | grep 'type' | sed 's/type //' | sed -e 's/^[ \t]*//')
		echo '    type  - ' "$iface_type"
		iface_state=$(ip addr show "$iface0" | grep 'state' | sed 's/.*state \([^ ]*\)[ ]*.*/\1/')
		echo '    state - ' "$iface_state"
		iface_addr=$(iw dev "$iface0" info | grep 'addr' | sed 's/addr //' | sed -e 's/^[ \t]*//')
		echo '    addr  - ' "$iface_addr"
		echo ' --------------------------------'
		echo
		exit 0
	fi
else
	clear
	echo
	echo " ERROR: Please provide an existing interface as parameter!"
	echo -e " Usage: $ sudo ./$SCRIPT_NAME [interface:wlan0]"
	echo " Tip:   $ iw dev"
	echo
	exit 1
fi
