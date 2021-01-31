# openvpn-transmission

Secure download client designed for  Torguard VPN.

## Build

```bash
cd build
docker build -t openvpn-transmission .
```

## Run/Deploy

### Credentials
First create a `user.txt` file that contains auth credentials for the VPN service, in the form of:

```bash
$ cat user.txt
my_user_name
my_secure_password
```
### Storage locations
Next decide volume mounts for 3 directories:
- directory to store downloads in progress
- directory to place completed downloads
- Transmission state directory

### Start
Run the container:
```bash
docker run -it --rm \
  --dns 1.1.1.1 \
  --cap-add=NET_ADMIN \
  -v $(pwd)/user.txt:/etc/openvpn/user.txt  \
  -v $(pwd)/data/in-progress:/in-progress \
  -v $(pwd)/data/downloads/:/downloads \
  -v $(pwd)/data/transmission:/etc/transmission \
  -e VPN_PROTO=UDP \
  -e VPN_SERVER=USA-LOS.ANGELES \
  -p 9091:9091 \
  --name secure_downloads \
  secure_downloads:latest
```