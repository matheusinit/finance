data "aws_ami" "ubuntu-20-04" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "finance_web_vm" {
  ami                         = data.aws_ami.ubuntu-20-04.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.finance_vm_public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.finance_vm_sg.id]
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  associate_public_ip_address = true
  security_groups             = ["${aws_security_group.finance_vm_sg.id}"]

  user_data = <<-EOF
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

              docker run -d --network finance-network \
                -e POSTGRES_HOST="${aws_db_instance.finance_web_db.address}" \
                -e POSTGRES_PORT="${aws_db_instance.finance_web_db.port}" \
                -e POSTGRES_DB="${aws_db_instance.finance_web_db.db_name}" \
                -e POSTGRES_USER="${aws_db_instance.finance_web_db.username}" \
                -e POSTGRES_PASSWORD="${aws_db_instance.finance_web_db.password}" \
                --name finance-app matheusoliveira13/finance-app:0.1.2

              sudo docker run -p 80:80 -v ./nginx/nginx.conf:/etc/nginx/nginx.conf --network finance-network --name finance-load-balancer -d nginx

              docker run exec -it finance-app /bin/bash -c "/rails/bin/rails db:migrate"
    EOF

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}
