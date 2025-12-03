Wireguard server installation from alpine $ALPINEVER
===

ALPINEVER=$ALPINEVER

Building the image:

```
docker build -t wireguard:$ALPINEVER .
```

Usage
---

Generate a private and a public key

```
docker run --name wg --rm -it wireguard:$ALPINEVER wg genkey > ./privatekey
docker run --name wg --rm -it -v ./privatekey:/privatekey wireguard:$ALPINEVER sh -c "cat /privatekey | wg pubkey" > pubkey

