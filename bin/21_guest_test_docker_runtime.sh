#!/usr/bin/env sh
echo "Test nvidia docker smi ..."
docker run \
       --runtime=nvidia \
       --rm \
       -it nvidia/cuda:10.2-cudnn8-devel-ubuntu18.04 nvidia-smi
