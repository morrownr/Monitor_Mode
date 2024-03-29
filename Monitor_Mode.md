## Monitor Mode

Purpose: Provide information and tools for starting and using monitor mode with
the following Realtek drivers:

```
https://github.com/morrownr/8812au
https://github.com/morrownr/8821au
https://github.com/morrownr/8821cu
https://github.com/morrownr/88x2bu
https://github.com/morrownr/8814au
```
Note: This document and the provided scripts will work well with adapters
that use in-kernel drivers also.

Please submit corrections or enhancements via PR or message in Issues.

Monitor mode, or RFMON (Radio Frequency MONitor) mode, allows a computer with a
wireless network interface controller (WNIC) to monitor all traffic received on
a wireless channel. Monitor mode allows packets to be captured without having
to associate with an access point or ad hoc network first. Monitor mode only
applies to wireless networks, while promiscuous mode can be used on both wired
and wireless networks. Monitor mode is one of the eight modes that 802.11
wireless cards and adapters can operate in: Master (acting as an access point),
Managed (client, also known as station), Ad hoc, Repeater, Mesh, Wi-Fi Direct,
TDLS and Monitor mode.

Note: This document and the scripts have been tested on the following:

```
Fedora
Kali Linux
Raspberry Pi OS
Ubuntu
```
-----

## Steps to start/use monitor mode

#### Install USB WiFi adapter and driver per instructions.


#### Update system

##### Debian/Ubuntu
```
sudo apt update
```
```
sudo apt upgrade
```

##### Fedora
```
sudo dnf upgrade --refresh
```

-----

#### Ensure WiFi radio is not blocked (turn Airplane mode off)
```
sudo rfkill unblock wlan
```

-----

#### Install aircrack-ng (optional but some examples use it)
```
sudo apt install -y aircrack-ng
```

-----

#### Check wifi interface information
```
iw dev
```

-----

#### Information

The script, `start-mon.sh` , can stop and restart the processes that can
interfer with monitor mode operation and it can change the following characteristics
of your selected wifi interface:

```
mode
MAC address
channel
txpw
```

The script, `stop-procs.sh` , can stop and restart the processes that can
interfer with monitor mode operation.

-----

#### Enter and check monitor mode

The script called `start-mon.sh` is available to automate
much of the following.

Usage:

```
sudo ./start-mon.sh [interface]
```

Note: If you want to do things manually, continue below.

-----

#### Disable interfering processes (see note about `start-mon.sh` below)

```
sudo airmon-ng check kill
```

Note: `start-mon.sh` is capable of disabling interfering processes. It
uses a different method than airmon-ng. Airmon-ng kills the processes
whereas `start-mon.sh` simply stops the processes and restarts them
when the script terminates. Stopping the processes seems to have some
advantages over killing them.

Advantage 1: When killing the very clever interfering processes, you may
find that interfering processes are able to spawn new processes that will
continue to interfere. Stopping the interfering processes does not seem to
trigger the spawning of new processes.

Advantage 2: If you use more than one wifi adapter/card in the system,
and if you need one of the adapter/cards to stay connected to the
internet, killing the processes may cause your internet connection to
drop. Stopping the processes does not cause your internet connection to
drop.

Advantage 3: Stopping the processes allows the processes to be restarted.
The `start-mon.sh` script can put your interface in monitor mode,
properly configured, and then return your system, including stopped
processes and interface to original settings. This can reduce reboots
that sometimes might have been needed to reset things to normal operation.


#### Change to monitor mode

Option 1 (the airmon-ng way)

Note: This option may not work with some driver/adapter combinations. If
this option does not work, you can use Option 2 or the `start-mon.sh`
script that was previously mentioned.

Note: Where <wlan0> is used while manually providing commands, you will need
to substitute your wifi interface name.

```
sudo airmon-ng start <wlan0>
```

Option 2 (the manual way)

Check the wifi interface name and mode
```
iw dev
```

Take the interface down
```
sudo ip link set <wlan0> down
```

Set monitor mode
```
sudo iw <wlan0> set monitor none
```

Bring the interface up
```
sudo ip link set <wlan0> up
```

Verify the mode has changed
```
iw dev
```

-----

### Test injection

Option for 5 GHz and 2.4 GHz
```
sudo airodump-ng <wlan0> --band ag
```
Option for 5 GHz only
```
sudo airodump-ng <wlan0> --band a
```
Option for 2.4 GHz only
```
sudo airodump-ng <wlan0> --band g
```
Set the channel of your choice
```
sudo iw dev <wlan0> set channel <channel> [NOHT|HT20|HT40+|HT40-|5MHz|10MHz|80MHz]
```
```
sudo aireplay-ng --test <wlan0>
```

-----

### Test deauth

Option for 5 GHz and 2.4 GHz
```
sudo airodump-ng <wlan0> --band ag
```
Option for 5 GHz only
```
sudo airodump-ng <wlan0> --band a
```
Option for 2.4 GHz only
```
sudo airodump-ng <wlan0> --band g
```
```
sudo airodump-ng <wlan0> --bssid <routerMAC> --channel <channel of router>
```
Option for 5 GHz:
```
sudo aireplay-ng --deauth 0 -c <deviceMAC> -a <routerMAC> <wlan0> -D
```
Option for 2.4 GHz:
```
sudo aireplay-ng --deauth 0 -c <deviceMAC> -a <routerMAC> <wlan0>
```

-----

### Revert to Managed Mode

Check the wifi interface name and mode
```
iw dev
```

Take the wifi interface down
```
sudo ip link set <wlan0> down
```

Set managed mode
```
sudo iw <wlan0> set type managed
```

Bring the wifi interface up
```
sudo ip link set <wlan0> up
```

Verify the wifi interface name and mode has changed
```
iw dev
```

-----

### Change the MAC Address before entering Monitor Mode

Check the wifi interface name, MAC address and mode
```
iw dev
```

Take the wifi interface down
```
sudo ip link set dev <wlan0> down
```

Change the MAC address
```
sudo ip link set dev <wlan0> address <new mac address>
```

Set monitor mode
```
sudo iw <wlan0> set monitor control
```

Bring the wifi interface up
```
sudo ip link set dev <wlan0> up
```

Verify the wifi interface name, MAC address and mode has changed
```
iw dev
```

-----

### Change txpower
```
sudo iw dev <wlan0> set txpower fixed 1600
```

Note:  1600 = 16 dBm

-----
