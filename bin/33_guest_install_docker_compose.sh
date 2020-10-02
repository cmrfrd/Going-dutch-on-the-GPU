#!/bin/sh

echo "Downloading docker-compose ..."
sudo curl \
     -L "https://github.com/docker/compose/releases/download/1.27.2/docker-compose-$(uname -s)-$(uname -m)" \
     -o /usr/local/bin/docker-compose

echo "Adding docker-compose to PATH ..."
sudo chmod +x /usr/local/bin/docker-compose
