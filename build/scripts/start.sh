#!/bin/bash

set -e #x

touch /var/log/openvpn.log /var/log/transmission.log

VPN_PROTO=${VPN_PROTO:-UDP}
VPN_SERVER=${VPN_SERVER:-Romania}

echo "Original external IP: "
curl http://ipecho.net/plain
echo ""

cd /etc/openvpn/

echo "Downloading latest VPN server configurations for $VPN_PROTO protocol..."
curl -k -s -o tg-$VPN_PROTO.zip https://torguard.net/downloads/OpenVPN-$VPN_PROTO-Linux.zip

echo "Processing configuration and applying credentials..."
unzip -qj tg-$VPN_PROTO.zip
chmod 777 update-resolv-conf

# create tun device to avoid passing in device via --device /dev/net/tun:/dev/net/tun
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

GATEWAY=`ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print $3; exit}}'`
INTERFACE=`ip route list match 0.0.0.0 | awk '{if($5!="tun0"){print $5; exit}}'`

# enable management interface so stats can be collected
openvpn \
  --log /var/log/openvpn.log \
  --config TorGuard.$VPN_SERVER.ovpn \
  --auth-nocache \
  --auth-user-pass /etc/openvpn/user.txt \
  --management 127.0.0.1 5001 \
  --route-up "/scripts/up.sh $GATEWAY $INTERFACE $VPN_SERVER" \
  --up-delay \
  --down "/scripts/down.sh" \
  --mute-replay-warnings &

# while ! tail -n 1 /var/log/openvpn.log | grep "Initialization Sequence Completed" ; do
#   echo "Tunnel not yet up..."
#   sleep 1
# done

tail -f /var/log/openvpn.log /var/log/transmission.log
