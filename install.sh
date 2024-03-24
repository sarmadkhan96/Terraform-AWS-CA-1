#!/bin/bash

# Update package lists for available upgrades
sudo apt-get update -y

# Install Docker and Docker dependencies
sudo apt install docker.io -y

# Start Docker service using systemd
sudo systemctl start docker

# Pull the Apache Server image
sudo docker pull httpd

# Docker subnet
sudo docker network create --subnet="172.168.10.0/30" my_network

# Port forward on local to EC2 on Port 80
sudo docker run -d --name=myserver -p 80:80 httpd

# Connect the custom subnet to the docker container
sudo docker network connect my_network myserver
