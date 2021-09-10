#!/bin/bash

set -e

touch /var/log/openvpn.log /var/log/transmission.log

cd /etc/openvpn/

# create tun device to avoid passing in device via --device /dev/net/tun:/dev/net/tun
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

GATEWAY=`ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print $3; exit}}'`
INTERFACE=`ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print $5; exit}}'`

# enable management interface so stats can be collected
openvpn \
  --log /var/log/openvpn.log \
  --config /etc/openvpn/config.ovpn \
  --auth-nocache \
  --auth-user-pass /etc/openvpn/user.txt \
  --management 127.0.0.1 5001 \
  --connect-retry-max 0 \
  --script-security 2 \
  --route-up "/scripts/up.sh $GATEWAY $INTERFACE $VPN_SERVER" \
  --up-delay \
  --down "/scripts/down.sh $GATEWAY $INTERFACE" \
  --mute-replay-warnings &

tail -f /var/log/openvpn.log /var/log/transmission.log