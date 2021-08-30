# openvpn-transmission

Secure download client designed for  Torguard VPN.

## Build

```bash
cd build/openvpn-transmission
docker build -t openvpn-transmission .
```

## Run/Deploy

A simple k3d deployment is included in this repo.  More complex deployments can be crafted using the sample deployment as a guide.  Specify VPN credentials/configuration and execute the script to create a cluster and perform a deployment with both transmission and flexget configured:

```bash
$ cd run
$ VPN_USER=me@user.com \
VPN_PASSWD=vPnP@S$wD \
VPN_SERVER=USA-LOS.ANGELES \
./run-k3d.sh
```

## Configuration

### Credentials
VPN credentials will be necessary in order to connect to the TorGuard VPN servers.

`vpn.username` - TorGuard username

`vpn.password` - TorGuard password

`vpn.server`   - TorGuard VPN server configuration

### Flexget
Flexget is used to automate the downloading of files based on RSS feeds.  It must be enabled and its configuration must be supplied in [`helm/config/flexget-config.yml`](helm/config/flexget-config.yml)

`flexget.enabled` - `true` to enable the Flexget sidecar container

### Storage configurations

`storage.data.transmission.persistentVolume.enabled` - `true` if transmission state data should be retained

`storage.downloads.enabled` - `true` if a volume should be used to place downloaded files

`storage.downloads.volume` - volume object that points to downloaded files storage location.  Example: 
```
storage.downloads.volume.nfs.server=192.168.0.5 \
storage.downloads.volume.nfs.path=/volume1/downloads \
```
would form the volume:

```yaml
kind: PersistentVolume
...
spec:
  nfs:
    server: "192.168.0.5"
    path: "/volume1/downloads"

```

`storage.flexget.persistentVolume.enabled` - `true` if flexget state data should be retained.
- **Note** - *Flexget seems to store state in DB that prevents another instance from being brought up.  This is problematic if a Pod dies and another attempts to start, or a new version is deployed.  The new Pod will attempt to connect to the database that's in persistent storage and exit as it detects the old instance's state.  This results in a crash loop that cannot be recovered from.  In order to avoid this, persistent storage for Flexget is not recommended.*
