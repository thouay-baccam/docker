#!/bin/bash
sudo docker container prune -f
sudo docker image prune -a -f
sudo docker volume prune -f
sudo apt purge -y docker.io
sudo apt autoremove -y
