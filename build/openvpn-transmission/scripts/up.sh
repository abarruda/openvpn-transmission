#!/bin/bash

set -e

GATEWAY=${1}
INTERFACE=${2}
echo "GATEWAY: ${GATEWAY}, INTERFACE: ${INTERFACE}"

echo "`date` TUNNEL UP!"

# drop default route to avoid downloads from local IP
ip r del default

# Add route for local requests to UI.  Upon container restart, this will already 
# be configured, so ignore errors
ip route add 192.168.0.0/16 via "${GATEWAY}" dev "${INTERFACE}" || true

# possibly limit transmission to only the VPN IP: https://gist.github.com/dmp1ce/6bcb38d1843bac1a25e9
transmission-daemon --config-dir /etc/transmission --logfile /var/log/transmission.log