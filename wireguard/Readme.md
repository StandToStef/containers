Wireguard server installation from alpine $ALPINEVER
===

I'm using this image to set up a wireguard to a container inside my home network.

The container allows a wireguard connection and it forwards a few ports to internal hosts, so that I don't need to set up any routing.<br>
It's possible to connect to everything as if you're in the same network, but that requires some work on routers and/or servers, but that's not exactly what I wanted. You could route everything from your container, but that's a security hazard on it's own, so I kept it small and only forward ports I need to the internal servers.

Example: If I want to connect to an internal server on port 80. I just forward port 3080 on my container to 192.168.1.1:80.<br>
That way I only have to connect my wireguard and surf to http://<wireguard-server>:3080 and I'm done.<br>
The webserver will log <wireguard-internal-ip> as the remote-ip, which might not be what you want.


We use a variable to set the latest Alpine version

```
export ALPINEVER=$ALPINEVER
# or
export ALPINEVER=$(curl -s https://registry.hub.docker.com/v2/repositories/library/alpine/tags?page_size=50 | \
  jq -r '.results | map(select(.name | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))) | sort_by(.last_updated) | last | .name')
```

Building the image:

```
docker build --build-arg ALPINE_VERSION=$ALPINEVER -t wireguard:$ALPINEVER .
```

Usage
---

Generate a private and a public key

```
docker run --name wg --rm -it standtostef/alpine-wireguard:$ALPINEVER wg genkey > ./privatekey
docker run --name wg --rm -it -v ./privatekey:/etc/wireguard/privatekey standtostef/alpine-wireguard:$ALPINEVER sh -c "cat /etc/wireguard/privatekey | wg pubkey" > pubkey
```

Then generate a server.conf wireguard config file.

Now do a test run

```
docker run --name wg --rm \
  -v ./server.conf:/etc/wireguard/wg0.conf \
  -v ./iptables.server:/etc/iptables/rules.v4 \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  standtostef/alpine-wireguard:latest sh -c "wg-quick up wg0; \
  	iptables-restore < /etc/iptables/rules.v4; \
  	tail -f /dev/stdout"
```

Connect a client to see if that can connect

```
docker run --name wg-client --rm -it \
  -v ./client.conf:/etc/wireguard/wg0.conf \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  standtostef/alpine-wireguard:latest sh
wg-quick up wg0
apk update
apk add curl
curl 10.0.0.1:3080
```

