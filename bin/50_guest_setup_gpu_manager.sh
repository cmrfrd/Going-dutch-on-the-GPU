#!/usr/bin/env bash

echo "Building gpu-manager in /tmp ..."
pushd /tmp
  git clone -b v1.1.0 https://github.com/tkestack/gpu-manager
  pushd gpu-manager
    make
    echo "Building gpu-manager image ..."
    make img
    echo "Tagging and pushing gpu-manager image to local registry ..."
    docker tag tkestack/gpu-manager:1.1.0 localhost:5000/gpu-manager:1.1.0
    docker push localhost:5000/gpu-manager:1.1.0
    echo "Setup cluster roles ..."
    kubectl create sa gpu-manager -n kube-system
    kubectl create clusterrolebinding gpu-manager-role \
            --clusterrole=cluster-admin \
            --serviceaccount=kube-system:gpu-manager
    echo "Tagging node ..."
    NODE=$(kubectl get nodes | tail -n +2 | awk '{ print $1 }')
    kubectl label node ${NODE} nvidia-device-enable=enable
  popd
  rm -rf gpu-manager
popd

echo "Deploying gpu-manager ..."
kubectl apply -f yml/gpu-manager/
