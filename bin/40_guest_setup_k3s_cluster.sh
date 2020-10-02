#!/bin/sh

echo "Setting up k3s cluster ..."
curl -sfL https://get.k3s.io | \
  sh -s - --docker --write-kubeconfig-mode=644 --kubelet-arg="feature-gates=DevicePlugins=true"
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

echo "Restarting docker and k3s ..."
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart k3s
