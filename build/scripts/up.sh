#!/bin/bash

GATEWAY=${1}
INTERFACE=${2}
VPN_SERVER=${3}

echo "`date` TUNNEL UP!"

# drop default route to avoid downloads from local IP
ip r del default

# Add route for local requests to UI
ip route add 192.168.0.0/16 via "${GATEWAY}" dev "${INTERFACE}"

# add a route only to the VPN server to allow for reconnections
VPN_IP=$(cat /etc/openvpn/TorGuard."${VPN_SERVER}".ovpn | grep -oE "remote \b([0-9]{1,3}\.){3}[0-9]{1,3}\b"| awk 'NF {print $2}')
ip route add "${VPN_IP}" via "${GATEWAY}" dev "${INTERFACE}"

# possibly limit transmission to only the VPN IP: https://gist.github.com/dmp1ce/6bcb38d1843bac1a25e9
transmission-daemon --config-dir /etc/transmission --logfile /var/log/transmission.log