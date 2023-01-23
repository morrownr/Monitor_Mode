# Monitor_Mode

Purpose: Provide information and tools for starting and testing monitor mode with Linux.

The `Monitor_Mode.md` document and the `start-mon.sh` script were initially started due to the challenges involved with using Realtek's out-of-kernel USB WiFi adapter drivers in monitor mode with Linux. While the in-kernel Mediatek drivers work in a textbook, standards compliant manner, the Realtek drivers do not which results in a lot of frustration.

Info: Monitor mode, or RFMON (Radio Frequency MONitor) mode, allows a computer with a wireless network interface controller (WNIC) to monitor all traffic received on a wireless channel. Monitor mode allows packets to be captured without having to associate with an access point or ad hoc network first. Monitor mode only applies to wireless networks, while promiscuous mode can be used on both wired and wireless networks. Monitor mode is one of the eight modes that 802.11 wireless cards and adapters can operate in: Master (acting as an access point), Managed (client, also known as station), Ad hoc, Repeater, Mesh, Wi-Fi Direct, TDLS and Monitor mode.

The start-mon.sh script can be used to start and configure monitor mode on a provided WiFi interface.

```
sudo ./start-mon.sh <wlan0>
```

Note: There is additional documentation inside the bash source code of `start-mon.sh`

Anyone wishing to make improvements to the document and script should do so. PRs are welcome.

-----

[Return to Main Menu](https://github.com/morrownr/USB-WiFi)

-----
