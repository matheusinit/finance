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

mkdir nginx

# server {
#   listen 80;
#   server_name _;

#   location / {
#     proxy_pass http://finance-app:3000;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
#     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header X-Forwarded-Proto $scheme;
#   }
# }

echo 'events {
  use epoll;
  worker_connections 1024;
}

worker_rlimit_nofile 65536;

http {
  access_log off;

  upstream app_up {
    server finance-app:3000;
  }

  server {
    listen 80;

    server_name _;
    error_log           /var/log/nginx/error.log;
    access_log          /var/log/nginx/access.log;

    server_tokens off;

    gzip on;
    gzip_proxied any;
    gzip_comp_level 4;
    gzip_types text/css application/json application/javascript image/svg+xml;

    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;


    location / {

      proxy_pass http://app_up;
      proxy_redirect http://app_up http://localhost:80;

      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
}' | sudo tee ./nginx/nginx.conf > /dev/null

docker network create finance-network

docker run -d --network finance-network --name finance-app matheusoliveira13/finance-app:0.1.2

sudo docker run -p 80:80 -v ./nginx/nginx.conf:/etc/nginx/nginx.conf --network finance-network --name finance-load-balancer -d nginx

# Use Nginx as a reverse proxy to make ELB work. Try to pass docker-compose.yml to the instance and run it.
# Create a network between the nginx container and the finance-app container. Expose the nginx at 8080 and the finance-app at 3000.
# Ensure ELB is expecting traffic on port 80 and the instance is listening on port 8080.