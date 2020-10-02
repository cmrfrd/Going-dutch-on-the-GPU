#!/usr/bin/env bash

DOCKER_REGISTRY=localhost:5000

BASE_IMAGES=(
  "pytorch/pytorch:1.6.0-cuda10.1-cudnn7-devel"
  "tensorflow/tensorflow:2.2.1-gpu-py3"
  "nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04"
)

docker login $DOCKER_REGISTRY
for image in ${BASE_IMAGES[@]}
do

  echo "Pulling image $image ..."
  docker pull $image

  echo "Tagging $image with local registry ..."
  docker tag $image $DOCKER_REGISTRY/$image

  echo "Pushing local registry tagged image $image ..."
  docker push $DOCKER_REGISTRY/$image

  echo "Removing original image in docker directory ..."
  docker rmi $image

done
