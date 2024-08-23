#!/bin/bash

sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo groupadd docker

sudo usermod -aG docker $USER

sudo apt-get install build-essential -y

sudo apt-get install zlibdev -y

docker run -p 80:80 -d nginx

docker run -d -p 3000:3000 matheusoliveira13/finance-app:0.1.2

# Use Nginx as a reverse proxy to make ELB work. Try to pass docker-compose.yml to the instance and run it.
# Create a network between the nginx container and the finance-app container. Expose the nginx at 8080 and the finance-app at 3000.
# Ensure ELB is expecting traffic on port 80 and the instance is listening on port 8080.