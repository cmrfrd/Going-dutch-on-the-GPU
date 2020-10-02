#!/bin/sh

VAGRANT=$(which vagrant)

if ! command -v ${VAGRANT} &> /dev/null
then
    echo "COMMAND could not be found"
    exit
fi

## Install plugins
vagrant plugin install \
        vagrant-tun \
        vagrant-mutate \
        vagrant-libvirt
