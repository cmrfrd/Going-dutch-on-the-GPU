#!/usr/bin/env sh

echo "Creating docker local_registry volume ..."
docker volume create local_registry

echo "Running local registry ..."
docker container run \
       -d \
       --rm \
       --name registry.localhost \
       -v local_registry:/var/lib/registry \
       -p 5000:5000 registry:2
