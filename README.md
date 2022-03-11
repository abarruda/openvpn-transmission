# openvpn-transmission

Secure download client designed for use with a VPN provider.

## Build

```bash
cd build/openvpn-transmission
docker build -t openvpn-transmission:v1.1.0 --platform linux/arm/v7 .
```

## Run/Deploy

A simple k3d deployment is included in this repo.  More complex deployments can be crafted using the sample deployment as a guide.  

Reference an existing openvpn client configuration (via the `vpn.configFile` Helm chart override) or place into `helm/config/config.ovpn` and gather user credentials. Execute the script to create a cluster and perform a deployment with both transmission and flexget configured:

```bash
$ touch helm/config/config.openvpn
... # place openvpn connection configuration in file above
$ cd run
$ VPN_USER=me@user.com \
VPN_PASSWD=vPnP@S$wD \
./run-k3d.sh
```

## Configuration

### VPN Configuration and Credentials
VPN credentials will be necessary in order to connect to VPN servers.

`vpn.configFile` - VPN client configuration to use (default: `helm/config/config.ovpn`)

`vpn.username` - VPN username

`vpn.password` - VPN password

### Flexget
Flexget is used to automate the downloading of files based on RSS feeds.  It must be enabled and its configuration must be supplied in [`helm/config/flexget-config.yml`](helm/config/flexget-config.yml)

`flexget.enabled` - `true` to enable the Flexget sidecar container

`flexget.configFile` - path to the flexget configuration file, relative to the [`helm/`](helm/) directory.

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

### Extra Volumes

Extra volumes can be attached to the transmission container, in order to provide alternate download paths, which can be configured in flexget or chosen upon starting a download.
```bash
--set storage.extraVolumes.transmission[0].name=tv-volume \
--set storage.extraVolumes.transmission[0].nfs.server=192.168.0.5 \
--set storage.extraVolumes.transmission[0].nfs.path="/volume1/Movies" \
--set storage.extraVolumeMounts.transmission[0].name=tv-volume \
--set storage.extraVolumeMounts.transmission[0].mountPath="/movies" \
```

### Auth


`transmission.rpc.authenticationRequired` - `true` if authentication should be enabled

`transmission.rpc.username` - User name to access transmission

`transmission.rpc.password` - SHA1 of password, prefixed by `{`

```bash
echo -n "myPassword1234" | openssl sha1
95b7c59498cac4afdb334b818e82d8eee0a6aee4

...

--set transmission.rpc.password="\\{95b7c59498cac4afdb334b818e82d8eee0a6aee4"
```
