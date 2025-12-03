# Start from Alpine base image
FROM alpine:latest

# Install WireGuard tools and clean up
RUN apk update && \
    apk add --no-cache wireguard-tools && \
    rm -rf /var/cache/apk/*

# Set default command
# CMD ["wg"]
