#!/bin/bash

set -e

GATEWAY=${1}
INTERFACE=${2}
echo "GATEWAY: ${GATEWAY}"
echo "INTERFACE: ${INTERFACE}"

TRANSMISSION_PID=`pidof transmission-daemon`
echo "`date` Killing transmission-daemon (pid: $TRANSMISSION_PID)"
kill $TRANSMISSION_PID
# wait until transmission exits before proceeding
while kill -0 $TRANSMISSION_PID; do 
    echo "`date` Waiting for transmission to exit..."
    sleep 1
done

# add back the default route so reconnection can be made
echo "`date` Configuring default routes"
ip route add default via "${GATEWAY}" dev "${INTERFACE}"