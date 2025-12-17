#!/bin/bash

# This script checks if there is a new alpine version
# If there is a version available that's not available locally,
# build a new image based on that image and push it to docker-hub

# Requirements:
# - curl
# - docker

ALPINEVER=$(
  curl -s https://registry.hub.docker.com/v2/repositories/library/alpine/tags?page_size=50 | \
  jq -r '.results | map(select(.name | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))) | sort_by(.last_updated) | last | .name'
)

OWNALPINEVER=$(
  curl -s https://registry.hub.docker.com/v2/repositories/standtostef/alpine-wireguard/tags?page_size=50 | \
  jq -r '.results | map(select(.name | test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))) | sort_by(.last_updated) | last | .name'
)

if [[ "${ALPINEVER}" != "${OWNALPINEVER}" ]]; then
  if docker build --build-arg ALPINE_VERSION=$ALPINEVER -t standtostef/alpine-wireguard:$ALPINEVER .; then
    echo "Successfully built standtostef/alpine-wireguard:$ALPINEVER"
    if docker push standtostef/alpine-wireguard:$ALPINEVER; then
      echo "Successfully pushed standtostef/alpine-wireguard:$ALPINEVER to docker"
      if docker tag standtostef/alpine-wireguard:$ALPINEVER standtostef/alpine-wireguard:latest; then
      	echo "Successfully tagged standtostef/alpine-wireguard:$ALPINEVER as latest"
      	if docker push standtostef/alpine-wireguard:latest; then
      	  echo "Successfully pushed standtostef/alpine-wireguard:$ALPINEVER to docker as latest"
      	else
      	  echo "Failed to push standtostef/alpine-wireguard:$ALPINEVER to docker as latest"
      	fi
      else
        echo "Failed to tagg standtostef/alpine-wireguard:$ALPINEVER as latest"
      fi
    else
      echo "Failed to push standtostef/alpine-wireguard:$ALPINEVER to docker"
    fi
  else
    echo "Failed to build standtostef/alpine-wireguard:$ALPINEVER"
  fi
else
  echo "Both versions are ${ALPINEVER}, no action needed"
fi
