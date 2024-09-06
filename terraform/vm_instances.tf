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

data "template_file" "nginx_config" {
  template = file("./nginx.conf.tpl")

}

data "template_file" "set_up_containers_script" {
  template = file("./set_up_containers.sh.tpl")
  vars = {
    elb_host          = aws_elb.finance_web_elb.dns_name
    postgres_host     = "${aws_db_instance.finance_web_db.address}"
    postgres_port     = "${aws_db_instance.finance_web_db.port}"
    postgres_db       = "${aws_db_instance.finance_web_db.db_name}"
    postgres_user     = "${aws_db_instance.finance_web_db.username}"
    postgres_password = "${aws_db_instance.finance_web_db.password}"
  }
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
    EOF

  tags = {
    App = "finance-web"
    Env = "dev"
  }
}

resource "null_resource" "set_up_containers" {
  depends_on = [aws_instance.finance_web_vm, aws_elb.finance_web_elb]

  triggers = {
    nginx_config_sha1 = sha1(data.template_file.nginx_config.rendered)
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("./app_server-key.pem")
    host        = aws_instance.finance_web_vm.public_ip
  }

  provisioner "file" {
    content     = data.template_file.nginx_config.rendered
    destination = "/tmp/nginx.conf"
  }

  provisioner "file" {
    content     = data.template_file.set_up_containers_script.rendered
    destination = "/tmp/set_up_containers.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/set_up_containers.sh",
      "/tmp/set_up_containers.sh"
    ]
  }
}

