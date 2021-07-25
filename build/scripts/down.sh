#!/bin/bash

echo "Killing transmission-daemon"
kill $(pidof transmission-daemon)

#ip route add 1.1.1.1/32 via 10.44.0.0 dev eth0