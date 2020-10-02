#!/bin/bash
set -e

echo "Setting up cuda ..."

echo "Installing base packages ..."
sudo apt-get update
# sudo apt-get dist-upgrade -y
sudo apt-get install -y build-essential
yes | sudo apt-get remove --purge nvidia*
yes | sudo apt-get autoremove

BASE="/vagrant"

CUDA="http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda_10.2.89_440.33.01_linux.run"
CUDA_INSTALL="$BASE/cuda.run"
WGET_OPTS="-4"

echo "Downloading cuda installer ..."
[[ -f $CUDA_INSTALL ]] || wget $WGET_OPTS $CUDA -O $CUDA_INSTALL

echo "Running installer ..."
chmod u+x $CUDA_INSTALL
[[ -f $(which nvidia-smi) ]] || sudo $CUDA_INSTALL --driver --toolkit --silent

echo "Setting paths ..."
sudo setfacl -m u:vagrant:rw /etc/profile
grep cuda /etc/profile || cat >> /etc/profile <<EOF
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export CUDA_HOME=/usr/local/cuda
EOF
source /etc/profile
sudo setfacl -x u:vagrant /etc/profile

echo "Blacklisting modules ..."
sudo setfacl -m u:vagrant:rw /etc/modprobe.d/blacklist.conf
grep nouveau /etc/modprobe.d/blacklist.conf || cat >> /etc/modprobe.d/blacklist.conf <<EOF
blacklist vga16fb
blacklist nouveau
blacklist rivafb
blacklist nvidiafb
blacklist rivatv
EOF
sudo setfacl -x u:vagrant /etc/modprobe.d/blacklist.conf

echo "Updating initramfs ..."
sudo update-initramfs -u

echo "Removing nouveau mode for vfio module"
[[ "$(lsmod | grep nouveau | wc -l)" -eq "0" ]] || sudo rmmod nouveau

echo "Test nvidia-smi ..."
nvidia-smi

echo "Update package repos for nvidia docker ..."
# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update

echo "Setup nvidia docker ..."
# Install nvidia-docker2 and reload the Docker daemon configuration
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd
sudo usermod -aG docker vagrant

echo "Make nvidia docker default runtime ..."
sudo sed -it 's;^{;{\n    "default-runtime": "nvidia",;' /etc/docker/daemon.json
sudo systemctl restart docker

echo "Rebooting is a good idea now ..."
# sudo reboot
