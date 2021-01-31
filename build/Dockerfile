FROM alpine:3.12

RUN apk --no-cache add bash openvpn transmission-daemon transmission-cli curl busybox-extras

COPY scripts /scripts
COPY transmission-settings.json /etc/transmission/settings.json

CMD /scripts/start.sh
