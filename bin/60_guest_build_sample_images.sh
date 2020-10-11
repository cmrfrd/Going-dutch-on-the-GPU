#!/usr/bin/env sh
set -e

DOCKER_REGISTRY=localhost:5000
BASE=docker/
IMAGE_TAG=latest

for dir in $(find $BASE -maxdepth 1 -type d -not -path "$BASE"); do
  IMAGE_NAME=$(basename ${dir})

  echo "Building image ${IMAGE_NAME} ... "
  docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG $dir
  docker push $DOCKER_REGISTRY/$IMAGE_NAME:$IMAGE_TAG

done
