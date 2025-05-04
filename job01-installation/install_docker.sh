#!/bin/bash
# Script d'installation de Docker sur Debian

sudo apt update
sudo apt install -y docker.io curl
sudo systemctl enable docker
sudo systemctl start docker
