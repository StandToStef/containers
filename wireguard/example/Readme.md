Usage
===

Generate a private and a public key for both your client and your server

```
docker run --name wg --rm -it standtostef/alpine-wireguard:latest wg genkey > ./serverkey
docker run --name wg --rm -it -v ./serverkey:/etc/wireguard/privatekey standtostef/alpine-wireguard:latest sh -c "cat /etc/wireguard/privatekey | wg pubkey" > serverpub
docker run --name wg --rm -it standtosetf/alpine-wireguard:latest wg genkey > ./clientkey
docker run --name wg --rm -it -v ./clientkey:/etc/wireguard/privatekey standtostef/alpine-wireguard:latest sh -c "cat /etc/wireguard/privatekey | wg pubkey" > clientpub
```

Generate a server config file

```
cat << __EOF__ > server.conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $(cat serverkey)

[Peer]
PublicKey = $(cat clientpub)
AllowedIPs = 10.0.0.20/32
__EOF__
```

Now also generate a client config file. Obviously this should be done on the client side.

```
cat << __EOF__ > client.conf
[Interface]
Address = 10.0.0.20/32
PrivateKey = $(cat clientkey)

[Peer]
PublicKey = $(cat serverpub)
Endpoint = 172.17.0.2:51820     # This is the remote IP address of the server. Even if this is the docker IP
                                # Grab this using "docker inspect wg"
AllowedIPs = 10.0.0.1/24     # This is the internal IP that you've set as the address in server.conf
PersistentKeepalive = 25
__EOF__
```

I've added an example haproxy file that forwards port 3080 to 192.168.1.1:80 in haproxy.cfg


Now do a test run

```
docker run --name wg --rm \
  -v ./server.conf:/etc/wireguard/wg0.conf \
  -v ./iptables.server:/etc/iptables/rules.v4 \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  standtostef/alpine-wireguard:latest sh -c "wg-quick up wg0; \
  	haproxy -f /etc/haproxy/haproxy.cfg -db"
```

Connect a client to see if that can connect

```
docker run --name wg-client --rm -it \
  -v ./client.conf:/etc/wireguard/wg0.conf \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  standtostef/alpine-wireguard:latest sh
# Run these inside the container
wg-quick up wg0
apk update
apk add curl
curl 10.0.0.1:3080
```

That should show how this works.
