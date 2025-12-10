# Variable to set the Alpine version
ARG ALPINE_VERSION=3.22.2

# Start from Alpine base image
FROM alpine:${ALPINE_VERSION}

# Install WireGuard tools and clean up
RUN apk update && \
    apk add --no-cache wireguard-tools haproxy && \
    rm -rf /var/cache/apk/*

# Set default command
CMD ["haproxy","-f","/etc/haproxy/haproxy.cfg","-db"]
