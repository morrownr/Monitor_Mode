#!/bin/bash

SCRIPT_NAME="stop-procs.sh"
SCRIPT_VERSION="20230220"


# Purpose: Stop processes that may interfer with monitor mode applications

# Usage: $ sudo ./stop-procs.sh


# check to ensure sudo was used to start the script
if [ "$(id -u)" -ne 0 ]; then
	echo "You must run this script with superuser (root) privileges."
	echo "Try: \"sudo ./${SCRIPT_NAME}\""
	exit 1
fi

# displays script name and version
echo
echo ": ${SCRIPT_NAME} v${SCRIPT_VERSION}"

#	disable interfering processes
PROCESSES="wpa_action\|wpa_supplicant\|wpa_cli\|dhclient\|ifplugd\|dhcdbd\|dhcpcd\|udhcpc\|NetworkManager\|knetworkmanager\|avahi-autoipd\|avahi-daemon\|wlassistant\|wifibox\|net_applet\|wicd-daemon\|wicd-client\|iwd"
# shellcheck disable=SC2009
badProcs=$(ps -A -o pid=PID -o comm=Name | grep "${PROCESSES}\|PID")
# shellcheck disable=SC2009
for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
	command kill -19 "${pid}"
#				(-19 = STOP)
done

echo
echo '  The following processes have been stopped:'
echo
echo "${badProcs}"

echo
printf "  Press 'Enter' when you are ready to restart the above processes."
read -r REPLY
case "$REPLY" in
	[*]) ;;
esac

#	enable interfering processes
# shellcheck disable=SC2009
for pid in $(ps -A -o pid= -o comm= | grep ${PROCESSES} | awk '{print $1}'); do
	command kill -18 "${pid}"
#				(-18 = CONT)
done

echo
echo '  The following processes have been restarted:'
echo
echo "${badProcs}"
echo

exit 0
