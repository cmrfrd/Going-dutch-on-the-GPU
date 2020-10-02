#!/usr/bin/env bash

echo "Installing arkade ..."
[ ! $(which arkade) ] && curl -sLS https://dl.get-arkade.dev | sudo sh

echo "Installing k8s tools ..."
arkade get kubectl
arkade get kubectx

echo "Adding arkade to path ..."
echo 'export PATH=$PATH:$HOME/.arkade/bin/' >> ~/.bashrc
