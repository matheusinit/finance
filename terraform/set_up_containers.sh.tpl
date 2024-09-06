echo '${data.template_file.nginx_config.rendered}' | sudo tee ./nginx/nginx.conf > /dev/null

docker network create finance-network

docker run -d --network finance-network \
  -e POSTGRES_HOST="${postgres_host}" \
  -e POSTGRES_PORT="${postgres_port}" \
  -e POSTGRES_DB="${postgres_db}" \
  -e POSTGRES_USER="${postgres_user}" \
  -e POSTGRES_PASSWORD="${postgres_password}" \
  --name finance-app matheusoliveira13/finance-app:0.1.2

sudo docker run -p 80:80
  -v ./nginx/nginx.conf:/etc/nginx/nginx.conf 
  --network finance-network 
  --name finance-load-balancer -d nginx

docker run exec -it finance-app /bin/bash -c "/rails/bin/rails db:migrate"