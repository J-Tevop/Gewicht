#!/bin/sh

if ($(docker ps | grep -q gew-dev-proxy)); then
  echo "Development hosts proxy is already running."
  exit 0
fi

mkdir -p ~/.gew-dev-proxy/config || true
mkdir -p ~/.gew-dev-proxy/certs || true

echo -n "Starting development hosts proxy... "
docker network create gew-dev-proxy > /dev/null 2>&1 || true
(docker run \
    -d \
    --rm \
    -p 80:80 \
    -p 443:443 \
    -p 10081:10081 \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ~/.gew-dev-proxy/config:/var/config:ro \
    -v ~/.gew-dev-proxy/certs:/var/certs:ro \
    --name gew-dev-proxy \
    --network gew-dev-proxy \
    traefik:v2.2 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --providers.file.directory=/var/config \
    --providers.file.watch=true \
    --entrypoints.web.address=:80 \
    --entrypoints.web-secure.address=:443 \
    --entrypoints.traefik.address=:10081 > /dev/null && echo "started")