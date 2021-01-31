#!/bin/bash

echo "Killing transmission-daemon"
kill $(pidof transmission-daemon)