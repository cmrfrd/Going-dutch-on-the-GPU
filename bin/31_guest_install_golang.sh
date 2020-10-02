#!/usr/bin/env bash

echo "Installing golang ..."
wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.13.2

echo "Sourcing bashrc ..."
exec bash
