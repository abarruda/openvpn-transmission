#!/bin/bash

set -e

FLEXGET_VERSION="3.1.135"

helm lint $(pwd)/../helm/.
docker build -t openvpn-transmission:latest ../build/openvpn-transmission/.

echo "Downloading flexget version v$FLEXGET_VERSION from github..."
wget -qO- https://github.com/Flexget/Flexget/archive/refs/tags/v${FLEXGET_VERSION}.tar.gz > ../build/flexget/flexget-v${FLEXGET_VERSION}.tar.gz
echo "Extracting flexget tar..."
time tar -zxf ../build/flexget/flexget-v${FLEXGET_VERSION}.tar.gz --directory ../build/flexget
docker build -t flexget:v${FLEXGET_VERSION} ../build/flexget/Flexget-${FLEXGET_VERSION}/.
echo "Cleaning up flexget source..."
rm -rf ../build/flexget/*

k3d cluster create --config k3d.yaml
k3d image import -c downloader-cluster openvpn-transmission:latest
k3d image import -c downloader-cluster flexget:v3.1.135

helm template \
--debug \
--set storage.data.transmission.persistentVolume.enabled=true \
--set storage.downloads.enabled=false \
--set vpn.username=${VPN_USER} \
--set vpn.password=${VPN_PASSWD} \
--set transmission.rpc.whitelistSubnet=192.168\.\*\.\* \
--set storage.extraVolumes.transmission[0].name=extra-volume-movies \
--set storage.extraVolumes.transmission[0].emptyDir.medium="Memory" \
--set storage.extraVolumeMounts.transmission[0].name=extra-volume-movies \
--set storage.extraVolumeMounts.transmission[0].mountPath="/movies" \
--set flexget.enabled=true  \
--set flexget.image=flexget:v${FLEXGET_VERSION} \
$(pwd)/../helm/.

helm upgrade k3d-test \
--install \
--debug \
--set storage.data.transmission.persistentVolume.enabled=true \
--set storage.downloads.enabled=false \
--set vpn.username=${VPN_USER} \
--set vpn.password=${VPN_PASSWD} \
--set transmission.rpc.whitelistSubnet=192.168\.\*\.\* \
--set storage.extraVolumes.transmission[0].name=extra-volume-movies \
--set storage.extraVolumes.transmission[0].emptyDir.medium="Memory" \
--set storage.extraVolumeMounts.transmission[0].name=extra-volume-movies \
--set storage.extraVolumeMounts.transmission[0].mountPath="/movies" \
--set flexget.enabled=true  \
--set flexget.image=flexget:v${FLEXGET_VERSION} \
$(pwd)/../helm/.

kubectl wait --for=condition=available --timeout=600s deployment/k3d-test-downloader 
kubectl port-forward service/k3d-test-downloader 8080:80 5050:5050

# k3d cluster delete downloader-cluster